IMAP (Internet Message Access Protocol) defines a set of commands that allow clients to interact with mail servers. These commands enable actions like retrieving, searching, deleting, or organizing emails. IMAP uses plain-text commands and responses, which makes it easy to understand and implement in clients.

Here’s a list of common IMAP commands:

### 1. **LOGIN**
Used to authenticate the user with a username and password.

**Syntax**:
```
A001 LOGIN username password
```

**Example**:
```
A001 LOGIN john@example.com mypassword
```

**Response**:
- `OK` if login is successful.
- `NO` if login failed.

### 2. **LIST**
Lists the mailboxes available on the server. You can specify a pattern to filter which mailboxes are returned.

**Syntax**:
```
A002 LIST reference mailbox_pattern
```

- `reference`: Base for mailbox hierarchy (use `""` for root).
- `mailbox_pattern`: Mailbox pattern (use `*` for all mailboxes).

**Example**:
```
A002 LIST "" "*"
```

**Response**:
- A list of mailboxes and their attributes.
- Example: `* LIST (\HasNoChildren) "/" "INBOX"`

### 3. **SELECT**
Selects a mailbox to access its messages. The mailbox must exist, and the client can only access one mailbox at a time.

**Syntax**:
```
A003 SELECT mailbox_name
```

**Example**:
```
A003 SELECT INBOX
```

**Response**:
- Mailbox status (number of messages, recent messages, UID validity, etc.).
- Example: `* OK [UIDVALIDITY 123456]`

### 4. **FETCH**
Retrieves specific data from messages. You can fetch entire messages, headers, or specific parts of messages.

**Syntax**:
```
A004 FETCH message_set message_data_item
```

- `message_set`: A range of messages (e.g., `1`, `2:4`, `1:*`).
- `message_data_item`: What part of the message to fetch (e.g., `BODY[]`, `BODY[HEADER]`, `FLAGS`, `UID`).

**Example**:
```
A004 FETCH 1 (BODY[])
```

**Response**:
- The content of the specified messages.

### 5. **STORE**
Changes the flags (e.g., read, deleted) associated with messages in the selected mailbox.

**Syntax**:
```
A005 STORE message_set +FLAGS (flag)
```

- `message_set`: A range of messages.
- `+FLAGS`: Add a flag to the messages.
- `flag`: The flag to apply (e.g., `\Seen`, `\Deleted`, `\Flagged`).

**Example**:
```
A005 STORE 1 +FLAGS (\Seen)
```

**Response**:
- A confirmation of the flag change.

### 6. **SEARCH**
Searches for messages that match certain criteria.

**Syntax**:
```
A006 SEARCH search_criteria
```

- `search_criteria`: Defines how to search for messages. You can search by date, flags, subject, body content, etc. Criteria include `ALL`, `UNSEEN`, `FROM`, `SUBJECT`, `BODY`, etc.

**Example**:
```
A006 SEARCH UNSEEN
```

**Response**:
- A list of matching message sequence numbers.
- Example: `* SEARCH 2 4 6`

### 7. **NOOP**
This command does nothing but can be used to keep the connection alive and check for new server updates (such as new emails arriving in the mailbox).

**Syntax**:
```
A007 NOOP
```

**Response**:
- No change, or updates from the server.

### 8. **EXPUNGE**
Permanently removes messages marked with the `\Deleted` flag.

**Syntax**:
```
A008 EXPUNGE
```

**Response**:
- A list of messages that were permanently removed.
- Example: `* 1 EXPUNGE`

### 9. **LOGOUT**
Ends the IMAP session and closes the connection.

**Syntax**:
```
A009 LOGOUT
```

**Response**:
- Server goodbye message.
- Example: `* BYE IMAP4rev1 Server logging out`

### 10. **CAPABILITY**
Returns a list of capabilities supported by the server. This is often one of the first commands issued to understand what features the server offers.

**Syntax**:
```
A010 CAPABILITY
```

**Response**:
- A list of supported features such as `IMAP4rev1`, `STARTTLS`, `LOGINDISABLED`, etc.
- Example: `* CAPABILITY IMAP4rev1 STARTTLS AUTH=PLAIN`

### 11. **UID**
UID (Unique Identifier) commands are used to retrieve messages using their unique IDs (instead of sequence numbers). UIDs are assigned by the server and are permanent for a message.

**Syntax**:
```
A011 UID FETCH uid_set message_data_item
```

**Example**:
```
A011 UID FETCH 1234 (BODY[])
```

**Response**:
- The message data of the specified UIDs.

### 12. **APPEND**
Adds a new message to a specified mailbox.

**Syntax**:
```
A012 APPEND mailbox_name (flags) "dd-mmm-yyyy hh:mm:ss +0000" {size}
message_body
```

**Example**:
```
A012 APPEND INBOX (\Seen) "12-Oct-2024 10:00:00 +0000" {50}
From: john@example.com
To: jane@example.com
Subject: Test
Message content
```

**Response**:
- OK if the message was successfully added.

### 13. **COPY**
Copies one or more messages to a specified mailbox.

**Syntax**:
```
A013 COPY message_set mailbox_name
```

**Example**:
```
A013 COPY 1:3 Archive
```

**Response**:
- OK if the copy operation was successful.

---

### IMAP Response Codes

- **OK**: The command was successful.
- **NO**: The command failed (e.g., incorrect login credentials).
- **BAD**: The command was rejected as syntactically invalid.
- **BYE**: The server is closing the connection.
- **PREAUTH**: The user is already authenticated.

### Example Session

Here’s a simple example of an IMAP session:

```
S: * OK IMAP server ready
C: A001 LOGIN john@example.com secretpassword
S: A001 OK LOGIN completed
C: A002 SELECT INBOX
S: * 5 EXISTS
S: * 2 RECENT
S: * OK [UIDVALIDITY 3857529045] UIDs valid
S: A002 OK [READ-WRITE] INBOX selected
C: A003 FETCH 1:2 (BODY[HEADER])
S: * 1 FETCH (BODY[HEADER] {342}
   Date: Tue, 13 Jul 2021 14:58:12 +0000
   From: alice@example.com
   To: john@example.com
   Subject: Test email
   )
S: * 2 FETCH (BODY[HEADER] {322}
   Date: Tue, 13 Jul 2021 15:10:21 +0000
   From: bob@example.com
   To: john@example.com
   Subject: Meeting
   )
S: A003 OK FETCH completed
C: A004 LOGOUT
S: * BYE IMAP server logging out
S: A004 OK LOGOUT completed
```

This interaction shows logging in, selecting the `INBOX` mailbox, fetching message headers, and logging out.

---

These are the most common IMAP commands used in client-server communication. You can extend and use these commands to implement more complex functionality like filtering, organizing emails, or managing multiple mailboxes.
