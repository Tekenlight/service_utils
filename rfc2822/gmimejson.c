/*


gmimejson.c
    ↓
libgmimejson.so  (exports: luaopen_gmimejson)
    ↓
Lua:
    local gmime = require("gmimejson")
    local json_string = gmime.parse(email)


Raw email (RFC 2822)
    ↓ GMimeParser
GMimeMessage
    ↓ recursive walk
Gmail-like JSON structure (cJSON)
    ↓
UTF-8 JSON string → Lua


gcc -shared -fPIC \
  gmimejson.c -o gmimejson.so \
  $(pkg-config --cflags --libs gmime-3.0 lua5.1) \
  -lcjson


local gmime = require("gmimejson")

local raw = io.open("mail.eml"):read("*a")

local json = gmime.parse(raw)

print(json)


{
  "mimeType": "multipart/mixed",
  "headers": [
    { "name": "Subject", "value": "Hello" },
    { "name": "From", "value": "a@b.com" }
  ],
  "parts": [
    {
      "mimeType": "text/plain",
      "body": { "data": "Hello world" }
    },
    {
      "mimeType": "text/html",
      "body": { "data": "<p>Hello</p>" }
    }
  ]
}


Required:

GMime 3.x (libgmime-3.0-dev)

cJSON (or Jansson) for JSON building

Lua 5.1/5.2/5.3 C API

You can substitute cJSON with Jansson if needed.
 */

#include <lua.h>
#include <lauxlib.h>

#include <gmime/gmime.h>
#include <gmime/gmime-content-type.h>
#include <gmime/gmime-filter-basic.h>
#include <gmime/gmime-stream-filter.h>

#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <stdbool.h>

#include "cjson/cJSON.h"

#include "base64.h"

struct header { char *name; char *value; };
struct header_list { struct header *items; int count; };

const char *known_headers[] = {
    "Return-Path",
    "Received",
    "Delivered-To",
    "From",
    "Sender",
    "Reply-To",
    "To",
    "Cc",
    "Bcc",
    "Subject",
    "Date",
    "Message-ID",
    "In-Reply-To",
    "References",
    "MIME-Version",
    "Content-Type",
    "Content-Transfer-Encoding",
    "X-Mailer",
    "User-Agent",
    "DKIM-Signature",
    "Authentication-Results",
    NULL
};

/* Trim leading and trailing whitespace */
static char *trim(char *s)
{
    while (g_ascii_isspace(*s)) s++;
    char *end = s + strlen(s);
    while (end > s && g_ascii_isspace(*(end-1))) end--;
    *end = '\0';
    return s;
}

/* Cleanup */
void free_header_list(struct header_list *hl)
{
    for (int i = 0; i < hl->count; i++) {
        g_free(hl->items[i].name);
        g_free(hl->items[i].value);
    }
    free(hl->items);
    hl->items = NULL;
    hl->count = 0;
}

struct header_list get_message_headers(const char *raw, size_t len, cJSON *node)
{
    struct header_list out = {0};

    /* 1) Find header/body separator (CRLFCRLF OR LFLF) */
    const char *sep = NULL;

    for (size_t i = 0; i + 3 < len; i++) {
        /* check for \r\n\r\n */
        if (raw[i] == '\r' && raw[i+1] == '\n' && raw[i+2] == '\r' && raw[i+3] == '\n') {
            sep = raw + i + 4;
            break;
        }
        /* check for \n\n */
        if (raw[i] == '\n' && raw[i+1] == '\n') {
            sep = raw + i + 2;
            break;
        }
    }

    if (!sep)
        return out; /* malformed mail */

    size_t header_len = sep - raw;

    /* 2) Copy header block and normalize CRLF to LF */
    char *hdr = malloc(header_len + 1);
    size_t k = 0;

    for (size_t i = 0; i < header_len; i++) {
        if (raw[i] == '\r') continue; /* drop CR */
        hdr[k++] = raw[i];
    }
    hdr[k] = '\0';

    /* 3) Parse header lines */
    char *saveptr = NULL;
    char *line = strtok_r(hdr, "\n", &saveptr);

    char *cur_name = NULL;
    char *cur_value = NULL;

    while (line) {
        /* Continuation line */
        if ((line[0] == ' ' || line[0] == '\t') && cur_value) {
            char *tmp = g_strconcat(cur_value, " ", trim(line), NULL);
            g_free(cur_value);
            cur_value = tmp;
        } else {
            /* Save previous header */
            if (cur_name && cur_value) {
                out.items = realloc(out.items, sizeof(struct header) * (out.count + 1));
                out.items[out.count].name  = cur_name;
                out.items[out.count].value = cur_value;
                //printf("%s:%d name=[%s] value = [%s]\n", __FILE__, __LINE__, cur_name, cur_value);
                out.count++;
            }

            /* Start new header */
            char *colon = strchr(line, ':');
            if (colon) {
                *colon = '\0';
                cur_name  = g_strdup(trim(line));
                cur_value = g_strdup(trim(colon + 1));
            } else {
                /* Invalid header line */
                cur_name = NULL;
                cur_value = NULL;
            }
        }

        line = strtok_r(NULL, "\n", &saveptr);
    }

    /* 4) Add final header */
    if (cur_name && cur_value) {
        out.items = realloc(out.items, sizeof(struct header) * (out.count + 1));
        out.items[out.count].name  = cur_name;
        out.items[out.count].value = cur_value;
        //printf("%s:%d name=[%s] value = [%s]\n", __FILE__, __LINE__, cur_name, cur_value);
        out.count++;
    }

    free(hdr);
    return out;
}

static char * extract_filename_from_header(const char *header_value)
{
    if (!header_value)
        return NULL;

    const char *p = strcasestr(header_value, "filename=");
    if (!p)
        p = strcasestr(header_value, "name=");
    if (!p)
        return NULL;

    p = strchr(p, '=');   // move to '='
    if (!p)
        return NULL;
    p++;

    // remove surrounding quotes
    if (*p == '"') {
        p++;
        const char *end = strchr(p, '"');
        if (end)
            return g_strndup(p, end - p);
    }

    // unquoted
    const char *end = strpbrk(p, " ;\t\r\n");
    if (end)
        return g_strndup(p, end - p);

    return g_strdup(p);
}

char * get_filename_from_disposition(GMimeObject *object)
{
    const char *raw = g_mime_object_get_header(object, "Content-Disposition");
    return extract_filename_from_header(raw);
}

char * get_filename_from_content_type(GMimeObject *object)
{
    const char *raw = g_mime_object_get_header(object, "Content-Type");
    return extract_filename_from_header(raw);
}

char * get_filename(GMimeObject *object)
{
    char *fn;

    fn = get_filename_from_disposition(object);
    if (fn)
        return fn;

    fn = get_filename_from_content_type(object);
    if (fn)
        return fn;

    return NULL;
}


static void walk_mime_object (GMimeObject *object, int depth)
{
    if (!object)
        return;

    const char *indent = "    "; // indent by 2 spaces per level
    for (int i = 0; i < depth; i++)
        printf("%s", indent);

    /* Print MIME type */
    GMimeContentType *ctype = g_mime_object_get_content_type(object);
    printf("Part: %s/%s",
           g_mime_content_type_get_media_type(ctype),
           g_mime_content_type_get_media_subtype(ctype));

    /* Print Content-Disposition, if present */
    GMimeContentDisposition *disp = g_mime_object_get_content_disposition(object);
    if (disp) {
        const char *d = g_mime_content_disposition_get_disposition(disp);
        printf(", disposition=%s", d ? d : "NULL");

        GMimeParamList *params = g_mime_content_disposition_get_parameters(disp);
        const char * filename = get_filename(object);
        if (filename)
            printf(", filename=%s", filename);
    } else {
        printf(", disposition=<missing => inline>");
    }

    printf("\n");

    /* Case 1: multipart container */
    if (GMIME_IS_MULTIPART(object)) {
        GMimeMultipart *mp = GMIME_MULTIPART(object);
        int count = g_mime_multipart_get_count(mp);

        for (int i = 0; i < count; i++) {
            GMimeObject *child = g_mime_multipart_get_part(mp, i);
            walk_mime_object(child, depth + 1);
        }
    }
    /* Case 2: message/rfc822 (embedded email) */
    else if (GMIME_IS_MESSAGE_PART(object)) {
        GMimeMessagePart *mp = GMIME_MESSAGE_PART(object);
        GMimeMessage *msg = g_mime_message_part_get_message(mp);
        if (msg) {
            GMimeObject *child = g_mime_message_get_mime_part(msg);
            walk_mime_object(child, depth + 1);
        }
    }
    /* Case 3: leaf GMimePart (text, attachment, image, etc.) */
    else if (GMIME_IS_PART(object)) {
        /* Leaf node — content is not printed here */
    }
}

//
// MIME TYPE
//
static cJSON* json_for_mime(GMimeObject *obj)
{
    GMimeContentType *ct = g_mime_object_get_content_type(obj);

    // GMime 3.0 combined type: "text/plain"
    const char *mime_full = g_mime_content_type_get_mime_type(ct);

    cJSON *node = cJSON_CreateObject();
    cJSON_AddStringToObject(node, "mimeType", mime_full);
    return node;
}

//
// HEADERS
//
static void add_headers(GMimeObject *obj, cJSON *node)
{
    GMimeHeaderList *list = g_mime_object_get_header_list(obj);
    if (!list) return;

    int count = g_mime_header_list_get_count(list);

    cJSON *arr = cJSON_CreateArray();
    cJSON_AddItemToObject(node, "headers", arr);

    for (int i = 0; i < count; i++) {
        GMimeHeader *hdr = g_mime_header_list_get_header_at(list, i);
        if (!hdr) continue;

        const char *name  = g_mime_header_get_name(hdr);
        const char *value = g_mime_header_get_value(hdr);

        cJSON *h = cJSON_CreateObject();
        cJSON_AddStringToObject(h, "name", name);
        cJSON_AddStringToObject(h, "value", value);
        cJSON_AddItemToArray(arr, h);
    }
}

//
// BODY (GMime 3.0)
//
static void add_body(GMimeObject *obj, cJSON *node)
{
    if (!GMIME_IS_PART(obj))
        return;

    GMimePart *part = GMIME_PART(obj);

    GMimeDataWrapper *wrapper = g_mime_part_get_content(part);
    if (!wrapper) return;

    GMimeStream *raw = g_mime_data_wrapper_get_stream(wrapper);

    //
    // Create memory output stream
    //
    GMimeStream *mem = g_mime_stream_mem_new();

    //
    // Create filter stream
    //
    GMimeStream *filter_stream = g_mime_stream_filter_new(mem);

    //
    // Create decoder filter using correct GMime 3.0 API
    //
    GMimeContentEncoding enc = g_mime_part_get_content_encoding(part);
    GMimeFilter *filter = g_mime_filter_basic_new(enc, FALSE);
    g_mime_stream_filter_add(GMIME_STREAM_FILTER(filter_stream), filter);

    //
    // Process
    //
    g_mime_stream_write_to_stream(raw, filter_stream);

    //
    // Extract bytes
    //
    GByteArray *buf = g_mime_stream_mem_get_byte_array((GMimeStreamMem*)mem);
    if (buf && buf->data && buf->len > 0) {

        char *tmp = malloc(buf->len + 1);
        memcpy(tmp, buf->data, buf->len);
        tmp[buf->len] = '\0';
        size_t out_len;
        char * b64_tmp = url_base64_encode(tmp, buf->len, &out_len, 0);

        cJSON *body = cJSON_CreateObject();
        cJSON_AddStringToObject(body, "data", b64_tmp);
        cJSON_AddNumberToObject(body, "size", (double)out_len);
        cJSON_AddItemToObject(node, "body", body);

        free(tmp);
        free(b64_tmp);
    }

    g_object_unref(filter);
    g_object_unref(filter_stream);
    g_object_unref(mem);
}

//
// MIME WALKER
//
static cJSON* convert(GMimeObject *obj, bool start)
{
    cJSON *node = json_for_mime(obj);
    if (!start) {
        add_headers(obj, node);
    }

    if (GMIME_IS_MULTIPART(obj)) {
        GMimeMultipart *mp = GMIME_MULTIPART(obj);

        int count = g_mime_multipart_get_count(mp);
        cJSON *arr = cJSON_CreateArray();
        cJSON_AddItemToObject(node, "parts", arr);

        for (int i = 0; i < count; i++) {
            GMimeObject *sub = g_mime_multipart_get_part(mp, i);
            cJSON_AddItemToArray(arr, convert(sub, false));
        }
        return node;
    }

    if (GMIME_IS_MESSAGE_PART(obj)) {
        GMimeMessagePart *mp = GMIME_MESSAGE_PART(obj);
        GMimeMessage *msg    = g_mime_message_part_get_message(mp);
        GMimeObject *sub     = g_mime_message_get_mime_part(msg);

        cJSON *arr = cJSON_CreateArray();
        cJSON_AddItemToObject(node, "parts", arr);
        cJSON_AddItemToArray(arr, convert(sub, false));

        return node;
    }

    add_body(obj, node);

    if (GMIME_IS_PART(obj)) {
        const char *fn = g_mime_part_get_filename(GMIME_PART(obj));
        if (fn)
            cJSON_AddStringToObject(node, "filename", fn);
    }

    return node;
}

char *decode_header(const char *hdr)
{
    GMimeParserOptions *opts = g_mime_parser_options_get_default();

    char *decoded = g_mime_utils_header_decode_text(opts, hdr);

    /* opts not freed because it is created using g_mime_parser_options_get_default */

    return decoded;   // free with g_free()
}

//
// LUA WRAPPER
//
static int l_parse(lua_State *L)
{
    size_t len;
    const char *raw = luaL_checklstring(L, 1, &len);

    g_mime_init();

    GMimeStream *stream = g_mime_stream_mem_new_with_buffer(raw, len);

    GMimeParserOptions *opts = g_mime_parser_options_get_default();
    GMimeParser *parser = g_mime_parser_new_with_stream(stream);

    GMimeMessage *msg = g_mime_parser_construct_message(parser, opts);

    GMimeObject *root = g_mime_message_get_mime_part(msg);
    //walk_mime_object(root, 0);

    cJSON *json = convert(root, true);

    cJSON *ha = cJSON_CreateArray();
    cJSON_AddItemToObject(json, "headers", ha);
    struct header_list headers = get_message_headers(raw, len, json);
    for (int i=0; i<headers.count; i++) {
        cJSON *h = cJSON_CreateObject();
        cJSON_AddStringToObject(h, "name", headers.items[i].name);
        char * decoded_value = decode_header(headers.items[i].value);
        cJSON_AddStringToObject(h, "value", decoded_value);
        g_free(decoded_value);
        cJSON_AddItemToArray(ha, h);
    }
    free_header_list(&headers);

    char *out = cJSON_Print(json);

    lua_pushstring(L, out);

    free(out);
    cJSON_Delete(json);
    g_object_unref(msg);
    g_object_unref(parser);
    g_object_unref(stream);

    /* opts not freed because it is created using g_mime_parser_options_get_default */
    /* root not freed because it is part of msg and not an owned object */

    return 1;
}

int luaopen_service_utils_gmimejson(lua_State *L)
{
    lua_newtable(L);
    lua_pushcfunction(L, l_parse);
    lua_setfield(L, -2, "parse");
    return 1;
}

