Here is a list of common POP3 (Post Office Protocol version 3) commands:

### 1. **USER**  
   - **Usage**: `USER <username>`
   - **Description**: Provides the username of the email account to the POP3 server.
   - **Example**: `USER john.doe@example.com`

### 2. **PASS**  
   - **Usage**: `PASS <password>`
   - **Description**: Provides the password for the email account after the `USER` command.
   - **Example**: `PASS password123`

### 3. **STAT**  
   - **Usage**: `STAT`
   - **Description**: Returns the number of messages in the mailbox and the total size (in octets).
   - **Example Response**: `+OK 3 3200` (3 messages, total size 3200 octets)

### 4. **LIST**  
   - **Usage**: `LIST [message-number]`
   - **Description**: Lists the size of each message. If a message number is specified, only that message's size is returned.
   - **Example**:
     - `LIST` (list all messages)
     - `LIST 1` (list message 1)
   - **Example Response**: `+OK 1 1200` (Message 1, size 1200 octets)

### 5. **RETR**  
   - **Usage**: `RETR <message-number>`
   - **Description**: Retrieves and displays the full content of the specified message.
   - **Example**: `RETR 1` (retrieves message 1)

### 6. **DELE**  
   - **Usage**: `DELE <message-number>`
   - **Description**: Marks the specified message for deletion. The message will be deleted from the server when the session ends.
   - **Example**: `DELE 1` (marks message 1 for deletion)

### 7. **NOOP**  
   - **Usage**: `NOOP`
   - **Description**: Does nothing. This command is used to keep the connection alive.
   - **Example**: `NOOP`

### 8. **RSET**  
   - **Usage**: `RSET`
   - **Description**: Resets the session, undoing any deletions marked with the `DELE` command.
   - **Example**: `RSET`

### 9. **TOP**  
   - **Usage**: `TOP <message-number> <lines>`
   - **Description**: Retrieves the headers and a specified number of lines from the body of the message.
   - **Example**: `TOP 1 10` (retrieves the headers and first 10 lines of message 1)

### 10. **QUIT**  
   - **Usage**: `QUIT`
   - **Description**: Ends the session and logs out from the server. Any messages marked for deletion with the `DELE` command will be permanently removed.
   - **Example**: `QUIT`

### 11. **APOP**  
   - **Usage**: `APOP <username> <digest>`
   - **Description**: Authenticates a user without sending the password in clear text by using a hash of the username and timestamp.
   - **Example**: `APOP john.doe d55e6fa1b7c20dbbbdf2e07f61e18a2b`

### 12. **UIDL**  
   - **Usage**: `UIDL [message-number]`
   - **Description**: Returns a unique identifier for each message. If a message number is specified, it returns the UID for that message only.
   - **Example**:
     - `UIDL` (list all messages and their UIDs)
     - `UIDL 1` (get UID of message 1)
   - **Example Response**: `+OK 1 Wk8pIEhPLdUo` (Message 1, UID `Wk8pIEhPLdUo`)

---

These are the standard POP3 commands used to interact with the server. POP3 uses a simple, command/response model where each command is typically followed by a response from the server, either positive (`+OK`) or negative (`-ERR`).
