//ADJDAILY JOB (ACCT),'DAILY ADJUST',CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//* Input generation is populated by the upstream API adapter before submit.
//BATCH    EXEC ADJBATCH,DB2SSID=DB2T,PLAN=ADJPLAN
//* Run only after the DB2 batch step completes successfully.
//REPORT   EXEC PGM=ADJRPT01,COND=(0,NE,BATCH.RUN)
//STEPLIB  DD  DSN=DEMO.LOAD,DISP=SHR
//ADJOUT   DD  DSN=DEMO.ADJOUT(0),DISP=SHR
//RPTOUT   DD  SYSOUT=*
//SYSOUT   DD  SYSOUT=*