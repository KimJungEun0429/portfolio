create or replace NONEDITIONABLE PACKAGE BODY PKG_SEND_MSG AS

    PROCEDURE PROC_INS_SEND_MSG
      (
            IN_VISIT_ID        IN           VARCHAR2,
            IN_MSG_ID          IN           VARCHAR2,
            IN_SM_DATE         IN           VARCHAR2,
            IN_GET_IN_ID       IN           VARCHAR2
      )
    AS
            V_SM_ID      CHAR(7);
    BEGIN
    	-- 자동 아이디 생성
        SELECT 'SM'|| TO_CHAR(TO_NUMBER(SUBSTR(NVL(MAX(SM_ID),'SM00000'),3)) + 1,'FM00000')
        INTO V_SM_ID
        FROM SEND_MSG_TBL
        ;
        
	
        IF IN_VISIT_ID IS NULL THEN     -- VISIT_ID가 NULL이면 GET_IN_ID를 넣고
            INSERT INTO SEND_MSG_TBL(SM_ID,VISIT_ID,MSG_ID,SM_DATE,GET_IN_ID)
                VALUES(V_SM_ID,IN_VISIT_ID,IN_MSG_ID,TO_DATE(IN_SM_DATE),IN_GET_IN_ID);
        ELSE            --GET_IN_ID가 NULL이면 VISIT_ID를 입력
            INSERT INTO SEND_MSG_TBL(SM_ID,VISIT_ID,MSG_ID,SM_DATE,GET_IN_ID)
                VALUES(V_SM_ID,IN_VISIT_ID,IN_MSG_ID,TO_DATE(IN_SM_DATE),IN_GET_IN_ID);
        END IF;
        
    
    END PROC_INS_SEND_MSG;
    
    
    
    PROCEDURE PROC_SEL_SEND_MSG
  (
        IN_SM_ID        IN              VARCHAR2,
        O_CUR           OUT             SYS_REFCURSOR
  )AS
  
  BEGIN
    OPEN O_CUR FOR
    SELECT * 
    FROM SEND_MSG_TBL
    WHERE SM_ID = IN_SM_ID;
  END PROC_SEL_SEND_MSG;
  
  
   PROCEDURE PROC_DEL_SEND_MSG
  (
        IN_SM_ID        IN              VARCHAR2
  )
  AS
        EXCEPTION_NO_DEL            EXCEPTION;
  BEGIN
        DELETE FROM SEND_MSG_TBL WHERE SM_ID = IN_SM_ID;
        RAISE EXCEPTION_NO_DEL;
        
        EXCEPTION 
        WHEN EXCEPTION_NO_DEL THEN
            ROLLBACK;
  END PROC_DEL_SEND_MSG;
  
  PROCEDURE PROC_UP_SEND_MSG
  (
        IN_SM_ID        IN              VARCHAR2,
        IN_VISIT_ID        IN           VARCHAR2,
        IN_MSG_ID          IN           VARCHAR2,
        IN_SM_DATE         IN           VARCHAR2,
        IN_GET_IN_ID       IN           VARCHAR2
  )AS
  
  BEGIN
    UPDATE SEND_MSG_TBL SET VISIT_ID = IN_VISIT_ID,
                            MSG_ID = IN_MSG_ID,
                            SM_DATE = IN_SM_DATE,
                            GET_IN_ID = IN_GET_IN_ID
        WHERE SM_ID = IN_SM_ID;
  END PROC_UP_SEND_MSG;

END PKG_SEND_MSG;