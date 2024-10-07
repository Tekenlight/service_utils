To create a simple IMAP client with SSL enabled in C, you'll need to use the OpenSSL library to establish a secure connection. This is especially important when communicating with email servers, as plain-text IMAP (port 143) is not secure. IMAP over SSL usually runs on port 993.

### Prerequisites

1. Install OpenSSL on your system.
   - On Linux, you can install it with:
     ```
     sudo apt-get install libssl-dev
     ```
2. Link the OpenSSL library when compiling:
   ```
   gcc -o imap_ssl_client imap_ssl_client.c -lssl -lcrypto
   ```

### IMAP Client with SSL in C

This program demonstrates how to establish an SSL-secured connection to an IMAP server, login, and fetch the list of mailboxes.

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <openssl/ssl.h>
#include <openssl/err.h>

#define SERVER_PORT 993
#define BUFFER_SIZE 1024

void error(const char *msg) {
    perror(msg);
    exit(EXIT_FAILURE);
}

void send_command(SSL *ssl, const char *cmd) {
    printf("Sending: %s", cmd);
    if (SSL_write(ssl, cmd, strlen(cmd)) <= 0) {
        error("Error sending command");
    }
}

void receive_response(SSL *ssl) {
    char buffer[BUFFER_SIZE];
    int bytes_received = SSL_read(ssl, buffer, sizeof(buffer) - 1);
    if (bytes_received <= 0) {
        error("Error receiving response");
    }
    buffer[bytes_received] = '\0';
    printf("Received: %s\n", buffer);
}

int main() {
    int sockfd;
    struct sockaddr_in server_addr;
    struct hostent *server;
    SSL_CTX *ctx;
    SSL *ssl;
    char buffer[BUFFER_SIZE];

    // IMAP server details (modify these)
    const char *server_name = "imap.example.com";
    const char *username = "your_username";
    const char *password = "your_password";

    // Initialize OpenSSL
    SSL_library_init();
    OpenSSL_add_all_algorithms();
    SSL_load_error_strings();
    const SSL_METHOD *method = SSLv23_client_method();
    ctx = SSL_CTX_new(method);
    if (ctx == NULL) {
        ERR_print_errors_fp(stderr);
        exit(EXIT_FAILURE);
    }

    // Create socket
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) {
        error("Error opening socket");
    }

    // Get server IP
    server = gethostbyname(server_name);
    if (server == NULL) {
        error("No such host");
    }

    // Set server address
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(SERVER_PORT);
    memcpy(&server_addr.sin_addr.s_addr, server->h_addr, server->h_length);

    // Connect to server
    if (connect(sockfd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
        error("Error connecting");
    }

    // Establish SSL connection
    ssl = SSL_new(ctx);
    SSL_set_fd(ssl, sockfd);
    if (SSL_connect(ssl) <= 0) {
        ERR_print_errors_fp(stderr);
        error("Error establishing SSL connection");
    }

    printf("Connected with %s encryption\n", SSL_get_cipher(ssl));

    // Receive initial server greeting
    receive_response(ssl);

    // Send login command
    snprintf(buffer, sizeof(buffer), "A001 LOGIN %s %s\r\n", username, password);
    send_command(ssl, buffer);

    // Receive login response
    receive_response(ssl);

    // Send LIST command to get all mailboxes
    snprintf(buffer, sizeof(buffer), "A002 LIST \"\" \"*\"\r\n");
    send_command(ssl, buffer);

    // Receive list response
    receive_response(ssl);

    // Send LOGOUT command
    snprintf(buffer, sizeof(buffer), "A003 LOGOUT\r\n");
    send_command(ssl, buffer);

    // Receive logout response
    receive_response(ssl);

    // Clean up
    SSL_free(ssl);
    close(sockfd);
    SSL_CTX_free(ctx);

    return 0;
}
```

### Key Changes for SSL Support:

1. **OpenSSL Initialization:**
   - OpenSSL is initialized using `SSL_library_init()`, `OpenSSL_add_all_algorithms()`, and `SSL_load_error_strings()`.
   - `SSL_CTX_new()` creates a new context for the SSL connection using `SSLv23_client_method()`, which is compatible with most SSL and TLS versions.

2. **SSL Connection Setup:**
   - After establishing the socket connection to the server, we create an SSL object using `SSL_new()` and associate it with the socket using `SSL_set_fd()`.
   - `SSL_connect()` is used to establish the SSL connection.

3. **Sending and Receiving Data Over SSL:**
   - Instead of using `send()` and `recv()` for plain TCP communication, we use `SSL_write()` and `SSL_read()` to send and receive data securely over the encrypted connection.

4. **Clean Up:**
   - The SSL connection is freed using `SSL_free()`, and the socket is closed using `close()`. Finally, the SSL context is cleaned up with `SSL_CTX_free()`.

### Compilation:

Make sure to link against the OpenSSL libraries when compiling this program. Use the following command:

```bash
gcc imap_ssl_client.c -o imap_ssl_client -lssl -lcrypto
```

### Output Example:

```
Connected with AES256-SHA encryption
Received: * OK [CAPABILITY IMAP4rev1 ...] Dovecot ready.
Sending: A001 LOGIN your_username your_password
Received: A001 OK [CAPABILITY IMAP4rev1 ...] Logged in
Sending: A002 LIST "" "*"
Received: * LIST (\HasNoChildren) "/" "INBOX"
Received: A002 OK LIST completed
Sending: A003 LOGOUT
Received: * BYE IMAP4rev1 Server logging out
Received: A003 OK LOGOUT completed
```

### Notes:

1. **SSL Certificates**:
   - This example does not perform SSL certificate validation for simplicity. In a production environment, you should verify the server’s certificate to prevent man-in-the-middle attacks.
   - You can use `SSL_CTX_set_verify()` to enforce peer certificate verification.

2. **Error Handling**:
   - OpenSSL functions return error codes on failure. Use `ERR_print_errors_fp()` to print the error stack if necessary.

3. **Thread Safety**:
   - OpenSSL is not thread-safe by default. If you're planning to use this client in a multi-threaded environment, make sure to initialize OpenSSL for thread safety.

This code demonstrates how to securely communicate with an IMAP server using SSL in C. You can expand this to handle more IMAP commands or even use TLS with STARTTLS if needed.
