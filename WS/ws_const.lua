local ws_const = {};

ws_const.FRAME_FLAG_MASK   = 0x80;
ws_const.MAX_HEADER_LENGTH = 14;
ws_const.WS_SERVER = 0;
ws_const.WS_CLIENT = 1;
ws_const.FRAME_FLAG_FIN  = 0x80;
ws_const.FRAME_FLAG_RSV1 = 0x40;
ws_const.FRAME_FLAG_RSV2 = 0x20;
ws_const.FRAME_FLAG_RSV3 = 0x10;
ws_const.FRAME_OP_CONT    = 0x00;
ws_const.FRAME_OP_TEXT    = 0x01;
ws_const.FRAME_OP_BINARY  = 0x02;
ws_const.FRAME_OP_CLOSE   = 0x08;
ws_const.FRAME_OP_PING    = 0x09;
ws_const.FRAME_OP_PONG    = 0x0a;
ws_const.FRAME_OP_BITMASK = 0x0f;
ws_const.FRAME_OP_SETRAW  = 0x100
ws_const.FRAME_TEXT   = ws_const.FRAME_FLAG_FIN | ws_const.FRAME_OP_TEXT;
ws_const.FRAME_BINARY = ws_const.FRAME_FLAG_FIN | ws_const.FRAME_OP_BINARY;
ws_const.WS_NORMAL_CLOSE            = 1000;
ws_const.WS_ENDPOINT_GOING_AWAY     = 1001;
ws_const.WS_PROTOCOL_ERROR          = 1002;
ws_const.WS_PAYLOAD_NOT_ACCEPTABLE  = 1003;
ws_const.WS_RESERVED                = 1004;
ws_const.WS_RESERVED_NO_STATUS_CODE = 1005;
ws_const.WS_RESERVED_ABNORMAL_CLOSE = 1006;
ws_const.WS_MALFORMED_PAYLOAD       = 1007;
ws_const.WS_POLICY_VIOLATION        = 1008;
ws_const.WS_PAYLOAD_TOO_BIG         = 1009;
ws_const.WS_EXTENSION_REQUIRED      = 1010;
ws_const.WS_UNEXPECTED_CONDITION    = 1011;
ws_const.WS_RESERVED_TLS_FAILURE    = 1015;
ws_const.WS_ERR_NO_HANDSHAKE                   = 1;
ws_const.WS_ERR_HANDSHAKE_NO_VERSION           = 2;
ws_const.WS_ERR_HANDSHAKE_UNSUPPORTED_VERSION  = 3;
ws_const.WS_ERR_HANDSHAKE_NO_KEY               = 4;
ws_const.WS_ERR_HANDSHAKE_ACCEPT               = 5;
ws_const.WS_ERR_UNAUTHORIZED                   = 6;
ws_const.WS_ERR_PAYLOAD_TOO_BIG                = 10;
ws_const.WS_ERR_INCOMPLETE_FRAME               = 11;

ws_const.TO_BE_CLOSED            = -1;

return ws_const;
