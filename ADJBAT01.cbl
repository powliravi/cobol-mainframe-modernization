       IDENTIFICATION DIVISION.
       PROGRAM-ID. ADJBAT01.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ADJUSTMENT-IN ASSIGN TO ADJIN
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-IN-FILE-STATUS.
           SELECT ADJUSTMENT-OUT ASSIGN TO ADJOUT
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-OUT-FILE-STATUS.
       DATA DIVISION.
       FILE SECTION.
       FD  ADJUSTMENT-IN
           RECORD CONTAINS 80 CHARACTERS.
       01  ADJUSTMENT-IN-RECORD           PIC X(80).
       FD  ADJUSTMENT-OUT
           RECORD CONTAINS 80 CHARACTERS.
       01  ADJUSTMENT-OUT-RECORD          PIC X(80).
       WORKING-STORAGE SECTION.
           COPY ADJREC.
           COPY CUSTBAL.
           EXEC SQL INCLUDE SQLCA END-EXEC.
       77  WS-IN-FILE-STATUS              PIC XX.
       77  WS-OUT-FILE-STATUS             PIC XX.
       77  WS-EOF                         PIC X VALUE 'N'.
       77  WS-NEW-BALANCE                 PIC S9(7)V99 COMP-3.
       77  WS-ROW-FOUND                   PIC X.
       PROCEDURE DIVISION.
       MAIN-PROCESS.
           OPEN INPUT ADJUSTMENT-IN
           IF WS-IN-FILE-STATUS NOT = '00'
               MOVE 12 TO RETURN-CODE
               GOBACK
           END-IF
           OPEN OUTPUT ADJUSTMENT-OUT
           IF WS-OUT-FILE-STATUS NOT = '00'
               CLOSE ADJUSTMENT-IN
               MOVE 12 TO RETURN-CODE
               GOBACK
           END-IF
           PERFORM UNTIL WS-EOF = 'Y'
               READ ADJUSTMENT-IN INTO WS-INPUT-RECORD
                   AT END MOVE 'Y' TO WS-EOF
                   NOT AT END PERFORM PROCESS-ADJUSTMENT
               END-READ
           END-PERFORM
           CLOSE ADJUSTMENT-IN ADJUSTMENT-OUT
           IF WS-IN-FILE-STATUS NOT = '00'
               OR WS-OUT-FILE-STATUS NOT = '00'
               MOVE 12 TO RETURN-CODE
           END-IF
           GOBACK.
       PROCESS-ADJUSTMENT.
           MOVE WS-IN-ACCOUNT TO WS-OUT-ACCOUNT
           MOVE ZERO TO WS-OUT-BALANCE WS-NEW-BALANCE
           MOVE 'ER' TO WS-OUT-STATUS
           IF WS-IN-TYPE NOT = 'CR' AND WS-IN-TYPE NOT = 'DB'
               PERFORM WRITE-RESULT
               EXIT PARAGRAPH
           END-IF
           IF WS-IN-AMOUNT < ZERO
               PERFORM WRITE-RESULT
               EXIT PARAGRAPH
           END-IF
           MOVE 'N' TO WS-ROW-FOUND
           EXEC SQL
               SELECT BALANCE, ACTIVE_FLAG
                 INTO :HV-BALANCE, :HV-ACTIVE-FLAG
                 FROM DEMO.CUSTOMER_BALANCE
                WHERE ACCOUNT_ID = :WS-IN-ACCOUNT
           END-EXEC
           EVALUATE SQLCODE
               WHEN 0
                   MOVE 'Y' TO WS-ROW-FOUND
               WHEN 100
                   MOVE 'NF' TO WS-OUT-STATUS
               WHEN OTHER
                   MOVE 12 TO RETURN-CODE
           END-EVALUATE
           IF WS-ROW-FOUND = 'N'
               PERFORM WRITE-RESULT
               EXIT PARAGRAPH
           END-IF
           IF HV-ACTIVE-FLAG NOT = 'Y'
               MOVE 'ER' TO WS-OUT-STATUS
               PERFORM WRITE-RESULT
               EXIT PARAGRAPH
           END-IF
           IF WS-IN-TYPE = 'CR'
               COMPUTE WS-NEW-BALANCE = HV-BALANCE + WS-IN-AMOUNT
           ELSE
               COMPUTE WS-NEW-BALANCE = HV-BALANCE - WS-IN-AMOUNT
           END-IF
           IF WS-NEW-BALANCE < ZERO OR WS-NEW-BALANCE > 9999999.99
               MOVE 'ER' TO WS-OUT-STATUS
               PERFORM WRITE-RESULT
               EXIT PARAGRAPH
           END-IF
           EXEC SQL
               UPDATE DEMO.CUSTOMER_BALANCE
                  SET BALANCE = :WS-NEW-BALANCE
                WHERE ACCOUNT_ID = :WS-IN-ACCOUNT
           END-EXEC
           IF SQLCODE = 0
               EXEC SQL COMMIT END-EXEC
               IF SQLCODE = 0
                   MOVE 'OK' TO WS-OUT-STATUS
                   MOVE WS-NEW-BALANCE TO WS-OUT-BALANCE
               ELSE
                   MOVE 12 TO RETURN-CODE
                   MOVE 'ER' TO WS-OUT-STATUS
               END-IF
           ELSE
               MOVE 12 TO RETURN-CODE
               MOVE 'ER' TO WS-OUT-STATUS
           END-IF
           PERFORM WRITE-RESULT.
       WRITE-RESULT.
           MOVE SPACES TO WS-OUTPUT-RECORD
           MOVE WS-OUT-ACCOUNT TO WS-OUTPUT-RECORD(1:10)
           MOVE WS-OUT-STATUS TO WS-OUTPUT-RECORD(11:2)
           MOVE WS-OUT-BALANCE TO WS-OUTPUT-RECORD(13:12)
           WRITE ADJUSTMENT-OUT-RECORD FROM WS-OUTPUT-RECORD
           IF WS-OUT-FILE-STATUS NOT = '00'
               MOVE 12 TO RETURN-CODE
           END-IF.