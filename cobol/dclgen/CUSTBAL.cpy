           EXEC SQL DECLARE DEMO.CUSTOMER_BALANCE TABLE
           ( ACCOUNT_ID       CHAR(10) NOT NULL,
             BALANCE           DECIMAL(9,2) NOT NULL,
             ACTIVE_FLAG       CHAR(1) NOT NULL
           ) END-EXEC.
       01  DCLCUSTOMER-BALANCE.
           10  HV-ACCOUNT-ID             PIC X(10).
           10  HV-BALANCE                PIC S9(7)V99 COMP-3.
           10  HV-ACTIVE-FLAG            PIC X.