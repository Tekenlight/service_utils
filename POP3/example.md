Here's an example implementation of a POP3 client using SSL in C. This code demonstrates how to establish an SSL connection to a POP3 server, send commands, and read responses.

The code relies on the OpenSSL library, which is a popular open-source implementation for SSL/TLS in C. You need to install OpenSSL if it’s not already installed.

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <openssl/ssl.h>
#include <openssl/err.h>

#define BUFFER_SIZE 1024

void handle_error(const char *msg) {
    perror(msg);
    exit(EXIT_FAILURE);
}

void print_ssl_error() {
    ERR_print_errors_fp(stderr);
    exit(EXIT_FAILURE);
}

int create_socket(const char *hostname, int port) {
    int sockfd;
    struct hostent *host;
    struct sockaddr_in server_addr;

    // Resolve the hostname to an IP address
    if ((host = gethostbyname(hostname)) == NULL) {
        handle_error("gethostbyname");
    }

    // Create the socket
    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
        handle_error("socket");
    }

    // Setup server address structure
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(port);
    server_addr.sin_addr = *((struct in_addr *)host->h_addr);
    memset(&(server_addr.sin_zero), 0, 8);

    // Connect to the server
    if (connect(sockfd, (struct sockaddr *)&server_addr, sizeof(struct sockaddr)) == -1) {
        handle_error("connect");
    }

    return sockfd;
}

SSL_CTX* init_ssl() {
    SSL_CTX *ctx;

    // Initialize SSL libraries
    SSL_load_error_strings();
    OpenSSL_add_ssl_algorithms();

    // Create SSL context
    ctx = SSL_CTX_new(SSLv23_client_method());
    if (!ctx) {
        print_ssl_error();
    }

    return ctx;
}

SSL* create_ssl_connection(SSL_CTX *ctx, int sockfd) {
    SSL *ssl = SSL_new(ctx);
    if (!ssl) {
        print_ssl_error();
    }

    // Bind the SSL connection with the socket file descriptor
    SSL_set_fd(ssl, sockfd);

    // Initiate the SSL handshake
    if (SSL_connect(ssl) != 1) {
        print_ssl_error();
    }

    printf("SSL connection established.\n");
    return ssl;
}

void send_pop3_command(SSL *ssl, const char *command) {
    char buffer[BUFFER_SIZE];
    snprintf(buffer, sizeof(buffer), "%s\r\n", command);
    SSL_write(ssl, buffer, strlen(buffer));
}

void read_pop3_response(SSL *ssl) {
    char buffer[BUFFER_SIZE];
    int bytes_read = SSL_read(ssl, buffer, sizeof(buffer) - 1);

    if (bytes_read > 0) {
        buffer[bytes_read] = '\0';
        printf("Server response: %s\n", buffer);
    } else {
        printf("Error reading server response.\n");
    }
}

int main(int argc, char *argv[]) {
    if (argc != 4) {
        fprintf(stderr, "Usage: %s <hostname> <port> <email>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    const char *hostname = argv[1];
    int port = atoi(argv[2]);
    const char *email = argv[3];

    // Initialize OpenSSL
    SSL_CTX *ssl_ctx = init_ssl();

    // Create a socket and connect to the POP3 server
    int sockfd = create_socket(hostname, port);

    // Create an SSL connection
    SSL *ssl = create_ssl_connection(ssl_ctx, sockfd);

    // Read server's initial response
    read_pop3_response(ssl);

    // Send USER command
    char user_command[BUFFER_SIZE];
    snprintf(user_command, sizeof(user_command), "USER %s", email);
    send_pop3_command(ssl, user_command);
    read_pop3_response(ssl);

    // Send PASS command (replace this with a real password)
    char pass_command[BUFFER_SIZE];
    snprintf(pass_command, sizeof(pass_command), "PASS yourpassword");
    send_pop3_command(ssl, pass_command);
    read_pop3_response(ssl);

    // Send QUIT command to close the session
    send_pop3_command(ssl, "QUIT");
    read_pop3_response(ssl);

    // Close the SSL connection and cleanup
    SSL_shutdown(ssl);
    SSL_free(ssl);
    close(sockfd);
    SSL_CTX_free(ssl_ctx);
    EVP_cleanup();

    return 0;
}
```

### Steps to Compile and Run:

1. Make sure you have the OpenSSL development library installed:
   - On Ubuntu/Debian: `sudo apt install libssl-dev`
   - On CentOS/Fedora: `sudo yum install openssl-devel`
   
2. Compile the program using the following command:
   ```bash
   gcc -o pop3_ssl_client pop3_ssl_client.c -lssl -lcrypto
   ```

3. Run the program:
   ```bash
   ./pop3_ssl_client <hostname> <port> <email>
   ```

### Explanation:
- **SSL Initialization**: The OpenSSL library is initialized, and a secure SSL context is created.
- **Socket Creation**: A TCP connection to the POP3 server is established using a socket.
- **SSL Handshake**: The SSL handshake is initiated over the TCP connection.
- **POP3 Communication**: POP3 commands (`USER`, `PASS`, `QUIT`) are sent to the server, and the server's responses are read.
- **SSL Cleanup**: After communication, the SSL connection is terminated, and the resources are cleaned up.

Make sure to replace `"yourpassword"` in the `PASS` command with the actual password, and use the correct hostname and port for your POP3 server (typically port 995 for SSL).
