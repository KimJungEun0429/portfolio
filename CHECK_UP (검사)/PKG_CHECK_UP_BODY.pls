create or replace NONEDITIONABLE PACKAGE BODY PKG_CHECK_UP AS

  PROCEDURE PROC_SEL_CHECKUP(
       IN_CHK_ID        IN          VARCHAR2,
       O_TBL            OUT         SYS_REFCURSOR
  ) AS
  BEGIN
    OPEN O_TBL FOR
        SELECT * FROM CHECK_UP_TBL
        WHERE CHK_ID = IN_CHK_ID;
  END PROC_SEL_CHECKUP;

  PROCEDURE PROC_MOD_CHECKUP(
        IN_CHK_ID       IN          VARCHAR2,
        IN_SM_ID        IN          VARCHAR2,
        IN_C_YN         IN          VARCHAR2,
        IN_CHK_DATE     IN          VARCHAR2
  ) AS
    V_CHK_ID            CHAR(7);
  BEGIN 
        SELECT 'CHK' || TO_CHAR(TO_NUMBER(SUBSTR(NVL(MAX(CHK_ID),'CHK0000'),4)) + 1,'FM0000')
        INTO V_CHK_ID
        FROM CHECK_UP_TBL
        ;
        
        MERGE INTO CHECK_UP_TBL
        USING DUAL
        ON(CHK_ID = IN_CHK_ID)
        WHEN MATCHED THEN
            UPDATE SET SM_ID = IN_SM_ID,
                        C_YN = IN_C_YN,
                        CHK_DATE = IN_CHK_DATE
        WHEN NOT MATCHED THEN
            INSERT (CHK_ID,SM_ID,C_YN,CHK_DATE) VALUES(V_CHK_ID,IN_SM_ID,IN_C_YN,TO_DATE(IN_CHK_DATE,'YYYYMMDD'));
        
  END PROC_MOD_CHECKUP;

  PROCEDURE PROC_DEL_CHECKUP(
        IN_CHK_ID       IN          VARCHAR2
  ) AS
        EXCEPT_NO_DEL           EXCEPTION;
        V_CNT                   NUMBER(3);
  BEGIN
  
     DELETE FROM CHECK_UP_TBL WHERE CHK_ID = IN_CHK_ID;
     
     SELECT COUNT(*)
     INTO V_CNT
     FROM CONTAGION_TBL
     WHERE CHK_ID = IN_CHK_ID;
     
     IF V_CNT = 0 THEN
        NULL;
        
     ELSE
        RAISE EXCEPT_NO_DEL;
     END IF;
     
     EXCEPTION
        WHEN EXCEPT_NO_DEL THEN
            ROLLBACK;
        
  END PROC_DEL_CHECKUP;

END PKG_CHECK_UP;