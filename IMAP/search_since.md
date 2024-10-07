To fetch emails from a specified date using an IMAP client, the `SEARCH` command is the key. IMAP provides a set of search criteria that allow you to filter emails by various attributes, including date.

Here, the `SINCE` keyword is used to fetch emails from a certain date onwards (inclusive). To get emails on a specific date, you can use the `ON` keyword.

### IMAP Command Syntax

#### To fetch emails **since** a specific date:
```
A001 SEARCH SINCE dd-mmm-yyyy
```

#### To fetch emails **on** a specific date:
```
A002 SEARCH ON dd-mmm-yyyy
```

Where `dd-mmm-yyyy` is the date in format `day-month-year`. For example, `01-Oct-2024` represents October 1, 2024.

### Example IMAP Commands to Fetch Mails Since a Specific Date

Here’s a breakdown of the process:

1. **Login** to the IMAP server.
2. **Select** the desired mailbox (e.g., INBOX).
3. **Search** for emails using the `SEARCH` command with the `SINCE` or `ON` keyword.
4. **Fetch** the emails based on the search results.

---

### Test-Driven Development Approach

Before implementing the full IMAP interaction, let’s first define test cases for fetching emails since a specific date:

#### Test 1: Fetch Emails Since a Date

- **Given**: We have a valid IMAP session and can select a mailbox.
- **When**: We issue a `SEARCH SINCE` command with a valid date.
- **Then**: The server should return the sequence numbers of the emails received since the given date.

```c
// Pseudo-test code (no IMAP implementation here)
void test_fetch_mails_since_date() {
    char *command = "A001 SEARCH SINCE 01-Oct-2024";
    char *expected_response = "* SEARCH 1 3 5";
    
    // Send SEARCH command
    send_command(command);
    
    // Receive response
    char *response = receive_response();
    
    // Check if the response contains the expected sequence numbers
    assert(strcmp(response, expected_response) == 0);
}
```

#### Test 2: Fetch Emails on a Specific Date

- **Given**: A valid session and mailbox.
- **When**: We issue a `SEARCH ON` command with a specific date.
- **Then**: The server should return emails received on that date.

```c
// Pseudo-test code (no IMAP implementation here)
void test_fetch_mails_on_specific_date() {
    char *command = "A002 SEARCH ON 01-Oct-2024";
    char *expected_response = "* SEARCH 2 4";
    
    // Send SEARCH command
    send_command(command);
    
    // Receive response
    char *response = receive_response();
    
    // Check if the response matches expected sequence numbers for that date
    assert(strcmp(response, expected_response) == 0);
}
```

---

### Actual IMAP Command Implementation

Now that we’ve defined test cases, let's implement the actual IMAP commands in an IMAP client to fetch emails based on date:

#### Fetch Emails Since a Date (Example Implementation):

```c
#include <stdio.h>
#include <string.h>

// Function to send command to server
void send_command(int sockfd, const char *cmd) {
    printf("Sending: %s", cmd);
    if (send(sockfd, cmd, strlen(cmd), 0) == -1) {
        perror("Error sending command");
        exit(EXIT_FAILURE);
    }
}

// Function to receive response from server
void receive_response(int sockfd) {
    char buffer[1024];
    int bytes_received = recv(sockfd, buffer, sizeof(buffer) - 1, 0);
    if (bytes_received < 0) {
        perror("Error receiving response");
        exit(EXIT_FAILURE);
    }
    buffer[bytes_received] = '\0';
    printf("Received: %s\n", buffer);
}

// Function to search for emails since a specific date
void fetch_emails_since(int sockfd, const char *date) {
    char buffer[1024];
    snprintf(buffer, sizeof(buffer), "A001 SEARCH SINCE %s\r\n", date);
    
    // Send SEARCH command
    send_command(sockfd, buffer);
    
    // Receive and print the search results
    receive_response(sockfd);
}

int main() {
    int sockfd = 0; // Assume a valid socket connection is established
    
    // Fetch emails since 01-Oct-2024
    fetch_emails_since(sockfd, "01-Oct-2024");
    
    return 0;
}
```

### Fetch Emails on a Specific Date (Example Implementation):

```c
// Function to search for emails on a specific date
void fetch_emails_on(int sockfd, const char *date) {
    char buffer[1024];
    snprintf(buffer, sizeof(buffer), "A002 SEARCH ON %s\r\n", date);
    
    // Send SEARCH command
    send_command(sockfd, buffer);
    
    // Receive and print the search results
    receive_response(sockfd);
}

int main() {
    int sockfd = 0; // Assume a valid socket connection is established
    
    // Fetch emails on 01-Oct-2024
    fetch_emails_on(sockfd, "01-Oct-2024");
    
    return 0;
}
```

---

### Full IMAP Session Example

Here’s how a full IMAP session would look when fetching emails from a specified date:

```
S: * OK IMAP4rev1 Service Ready
C: A001 LOGIN john@example.com password
S: A001 OK LOGIN completed
C: A002 SELECT INBOX
S: * FLAGS (\Answered \Flagged \Deleted \Seen \Draft)
S: * 5 EXISTS
S: * OK [UIDVALIDITY 12345] UID validity
S: A002 OK [READ-WRITE] INBOX selected
C: A003 SEARCH SINCE 01-Oct-2024
S: * SEARCH 2 4 5
C: A004 FETCH 2,4,5 (BODY[HEADER])
S: * 2 FETCH (BODY[HEADER] {342} ...)
S: * 4 FETCH (BODY[HEADER] {350} ...)
S: * 5 FETCH (BODY[HEADER] {300} ...)
S: A004 OK FETCH completed
C: A005 LOGOUT
S: * BYE IMAP4rev1 Server logging out
S: A005 OK LOGOUT completed
```

### Summary:
- **SEARCH SINCE** retrieves emails from a specific date onwards.
- **SEARCH ON** retrieves emails from a specific date.
- Both are efficient and can be used in conjunction with FETCH to retrieve message details like headers or body.

These commands form the core of fetching emails based on date, providing a powerful way to handle messages programmatically.
