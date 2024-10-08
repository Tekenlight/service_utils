IMAP (Internet Message Access Protocol) is a standard email protocol that allows email clients to access messages stored on a mail server. IMAP commands are used by clients to interact with the server to perform actions such as retrieving, deleting, or moving emails. Here's a list of some common IMAP commands:

### Connection and Authentication
1. **LOGIN**  
   `LOGIN username password`  
   Authenticates the user with a username and password.

2. **LOGOUT**  
   `LOGOUT`  
   Ends the IMAP session and logs out.

3. **CAPABILITY**  
   `CAPABILITY`  
   Requests the server to list its capabilities (e.g., supported extensions).

4. **STARTTLS**  
   `STARTTLS`  
   Initiates a secure (encrypted) connection.

### Mailbox Selection and Management
5. **SELECT**  
   `SELECT mailbox`  
   Opens a mailbox in read-write mode.

6. **EXAMINE**  
   `EXAMINE mailbox`  
   Opens a mailbox in read-only mode.

7. **CREATE**  
   `CREATE mailbox`  
   Creates a new mailbox.

8. **DELETE**  
   `DELETE mailbox`  
   Deletes a mailbox.

9. **RENAME**  
   `RENAME oldmailbox newmailbox`  
   Renames a mailbox.

10. **LIST**  
    `LIST reference mailbox`  
    Lists mailboxes based on a given reference (e.g., `LIST "" "*"` to list all mailboxes).

11. **LSUB**  
    `LSUB reference mailbox`  
    Lists subscribed mailboxes.

12. **SUBSCRIBE**  
    `SUBSCRIBE mailbox`  
    Subscribes to a mailbox.

13. **UNSUBSCRIBE**  
    `UNSUBSCRIBE mailbox`  
    Unsubscribes from a mailbox.

### Message Retrieval and Management
14. **FETCH**  
    `FETCH message-set data-items`  
    Retrieves message data like headers, body, etc.

15. **SEARCH**  
    `SEARCH criteria`  
    Searches messages based on criteria (e.g., `SEARCH FROM "example@example.com"`).

16. **STORE**  
    `STORE message-set data-item value`  
    Alters data for a message (e.g., marking a message as read).

17. **COPY**  
    `COPY message-set mailbox`  
    Copies messages to a specified mailbox.

18. **UID**  
    `UID command`  
    Executes a command based on unique message IDs (UIDs), e.g., `UID FETCH`, `UID COPY`.

### Flag Management
19. **FLAGS**  
    Flags are used with `STORE` to mark messages:
   - `\Seen`: Message has been read.
   - `\Answered`: Message has been replied to.
   - `\Flagged`: Message is marked for special attention.
   - `\Deleted`: Message is marked for deletion.
   - `\Draft`: Message is a draft.
   - `\Recent`: Message is recent (server-set).

20. **NOOP**  
    `NOOP`  
    No operation; often used to keep the connection alive.

21. **EXPUNGE**  
    `EXPUNGE`  
    Permanently removes messages marked with the `\Deleted` flag.

22. **CLOSE**  
    `CLOSE`  
    Closes the selected mailbox and expunges messages marked for deletion.

### Namespace and Quota Management
23. **NAMESPACE**  
    `NAMESPACE`  
    Retrieves information about the available namespaces for the user.

24. **GETQUOTAROOT**  
    `GETQUOTAROOT mailbox`  
    Retrieves quota information for a specified mailbox.

25. **GETQUOTA**  
    `GETQUOTA resource`  
    Retrieves quota information for a specified resource (e.g., storage).

26. **SETQUOTA**  
    `SETQUOTA resource limit`  
    Sets a quota limit for a specified resource.

These commands form the basis of interaction between an email client and server over IMAP, enabling the client to access, manipulate, and organize email messages.
