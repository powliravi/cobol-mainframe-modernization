       01  WS-INPUT-RECORD.
           05  WS-INPUT-RAW              PIC X(80).
           05  WS-INPUT-FIELDS REDEFINES WS-INPUT-RAW.
               10  WS-IN-ACCOUNT         PIC X(10).
               10  WS-IN-TYPE            PIC X(2).
               10  WS-IN-AMOUNT          PIC S9(7)V99 COMP-3.
               10  FILLER                PIC X(63).
       01  WS-OUTPUT-RECORD.
           05  WS-OUT-ACCOUNT            PIC X(10).
           05  WS-OUT-STATUS             PIC XX.
           05  WS-OUT-BALANCE             PIC 9(9).99.
           05  FILLER                    PIC X(56).