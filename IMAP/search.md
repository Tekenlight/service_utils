The **IMAP SEARCH** command allows you to search for messages within a selected mailbox based on various criteria. The search returns a list of message sequence numbers that match the specified conditions. It is a powerful way to filter emails, and the criteria can be combined for more specific searches.

### Basic Syntax
```
SEARCH [criteria]
```
- The search can be combined with multiple criteria to refine the results.
- The command must be run on a mailbox that is currently selected using the `SELECT` or `EXAMINE` commands.

### Common Criteria
Here are some of the commonly used search criteria:

1. **ALL**  
   `SEARCH ALL`  
   Returns all messages in the mailbox.

2. **FROM**  
   `SEARCH FROM "example@example.com"`  
   Finds messages sent by the specified email address.

3. **TO**  
   `SEARCH TO "example@example.com"`  
   Finds messages sent to the specified recipient.

4. **SUBJECT**  
   `SEARCH SUBJECT "meeting"`  
   Finds messages that contain the specified word or phrase in the subject line.

5. **BODY**  
   `SEARCH BODY "agenda"`  
   Finds messages that contain the specified word or phrase in the body.

6. **TEXT**  
   `SEARCH TEXT "update"`  
   Searches for a word or phrase in both the header and body of the message.

7. **SINCE**  
   `SEARCH SINCE 01-Oct-2023`  
   Finds messages sent on or after the specified date.

8. **BEFORE**  
   `SEARCH BEFORE 01-Oct-2023`  
   Finds messages sent before the specified date.

9. **ON**  
   `SEARCH ON 01-Oct-2023`  
   Finds messages sent on a specific date.

10. **SEEN**  
    `SEARCH SEEN`  
    Finds messages that have been read.

11. **UNSEEN**  
    `SEARCH UNSEEN`  
    Finds messages that have not been read.

12. **ANSWERED**  
    `SEARCH ANSWERED`  
    Finds messages that have been replied to.

13. **UNANSWERED**  
    `SEARCH UNANSWERED`  
    Finds messages that have not been replied to.

14. **DELETED**  
    `SEARCH DELETED`  
    Finds messages that are marked for deletion.

15. **DRAFT**  
    `SEARCH DRAFT`  
    Finds messages that are marked as drafts.

16. **FLAGGED**  
    `SEARCH FLAGGED`  
    Finds messages marked for special attention (e.g., starred).

17. **UNFLAGGED**  
    `SEARCH UNFLAGGED`  
    Finds messages that are not marked for special attention.

18. **LARGER**  
    `SEARCH LARGER 10000`  
    Finds messages larger than the specified size (in bytes).

19. **SMALLER**  
    `SEARCH SMALLER 10000`  
    Finds messages smaller than the specified size (in bytes).

### Combining Criteria
You can combine multiple search criteria to refine the search results. For example:
- **AND** (Default behavior):  
  `SEARCH FROM "example@example.com" SUBJECT "report"`  
  Finds messages from "example@example.com" that contain "report" in the subject line.
  
- **OR** (Explicitly using the `OR` keyword):  
  `SEARCH OR FROM "user1@example.com" FROM "user2@example.com"`  
  Finds messages from either "user1@example.com" or "user2@example.com".

### Example Searches
1. Find unread emails from a specific sender:
   ```
   SEARCH UNSEEN FROM "boss@example.com"
   ```
2. Find emails containing the word "invoice" sent before October 1, 2023:
   ```
   SEARCH BEFORE 01-Oct-2023 BODY "invoice"
   ```
3. Find emails larger than 1MB that are marked as flagged:
   ```
   SEARCH LARGER 1048576 FLAGGED
   ```

The **SEARCH** command is a versatile tool in IMAP for narrowing down messages based on a wide range of criteria. It helps to efficiently find the emails you need without having to download the entire mailbox.
