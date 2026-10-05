       IDENTIFICATION DIVISION.
       PROGRAM-ID. ADJRPT01.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ADJUSTMENT-IN ASSIGN TO ADJOUT
               ORGANIZATION IS SEQUENTIAL
               FILE STATUS IS WS-FILE-STATUS.
       DATA DIVISION.
       FILE SECTION.
       FD  ADJUSTMENT-IN
           RECORD CONTAINS 80 CHARACTERS.
       01  ADJUSTMENT-RECORD               PIC X(80).
       WORKING-STORAGE SECTION.
       77  WS-FILE-STATUS                  PIC XX.
       77  WS-EOF                          PIC X VALUE 'N'.
       77  WS-OK-COUNT                     PIC 9(7) VALUE ZERO.
       77  WS-NF-COUNT                     PIC 9(7) VALUE ZERO.
       77  WS-ER-COUNT                     PIC 9(7) VALUE ZERO.
       PROCEDURE DIVISION.
       MAIN-PROCESS.
           OPEN INPUT ADJUSTMENT-IN
           IF WS-FILE-STATUS NOT = '00'
               MOVE 12 TO RETURN-CODE
               GOBACK
           END-IF
           PERFORM UNTIL WS-EOF = 'Y'
               READ ADJUSTMENT-IN
                   AT END MOVE 'Y' TO WS-EOF
                   NOT AT END PERFORM COUNT-RESULT
               END-READ
           END-PERFORM
           CLOSE ADJUSTMENT-IN
           DISPLAY 'ADJUSTMENT RECONCILIATION'
           DISPLAY 'OK=' WS-OK-COUNT
                   ' NF=' WS-NF-COUNT
                   ' ER=' WS-ER-COUNT
           IF WS-FILE-STATUS NOT = '00'
               MOVE 12 TO RETURN-CODE
           END-IF
           GOBACK.
       COUNT-RESULT.
           EVALUATE ADJUSTMENT-RECORD(11:2)
               WHEN 'OK' ADD 1 TO WS-OK-COUNT
               WHEN 'NF' ADD 1 TO WS-NF-COUNT
               WHEN 'ER' ADD 1 TO WS-ER-COUNT
               WHEN OTHER MOVE 12 TO RETURN-CODE
           END-EVALUATE.