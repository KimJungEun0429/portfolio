create or replace NONEDITIONABLE PACKAGE BODY PKG_GET_IN AS

--PROCEDURE START

    -- UPDATE / INSERT
    PROCEDURE PROC_MOD_GET_IN
    (
        IN_GET_IN_ID        IN      VARCHAR2,
        IN_P_ID             IN      VARCHAR2,
        IN_T_ID             IN      VARCHAR2,
        IN_CHECK_IN         IN      VARCHAR2,
        IN_CHECK_OUT        IN      VARCHAR2
    )
    AS

    V_GET_IN_ID     CHAR(7); --GET_IN_ID 변수

    BEGIN
    
      --1. V_GET_IN_ID 생성
        SELECT 'GID'||TO_CHAR(TO_NUMBER(NVL(SUBSTR(MAX(GET_IN_ID),4),0))+1,'FM0000')
        INTO V_GET_IN_ID
        FROM GET_IN_TBL
        ;
      
      --2. MERGE INTO
        MERGE INTO GET_IN_TBL
        USING DUAL
        ON(GET_IN_ID=IN_GET_IN_ID)
        
        --2.1 이미 IN_GET_IN_ID 있으면 UPDATE
            WHEN MATCHED THEN
            UPDATE
            SET P_ID=IN_P_ID, T_ID=IN_T_ID, CHECK_IN=TO_DATE(IN_CHECK_IN,'YYYYMMDD HH24:MI')
            , CHECK_OUT=TO_DATE(IN_CHECK_OUT,'YYYYMMDD HH24:MI')
            
        --2.2 IN_GET_IN_ID 없으면 INSERT
            WHEN NOT MATCHED THEN
            INSERT
            (GET_IN_ID, P_ID, T_ID, CHECK_IN, CHECK_OUT)
            VALUES
            (V_GET_IN_ID, IN_P_ID, IN_T_ID, TO_DATE(IN_CHECK_IN,'YYYYMMDD HH24:MI'), TO_DATE(IN_CHECK_OUT,'YYYYMMDD HH24:MI'))
            ;
      
    END PROC_MOD_GET_IN;


    --DELETE
    PROCEDURE PROC_DEL_GET_IN 
    (
        IN_GET_IN_ID        IN      VARCHAR2
    )
    AS 

    BEGIN
    
      --1. 데이터 삭제
        DELETE FROM GET_IN_TBL
        WHERE GET_IN_ID=IN_GET_IN_ID
        ;
      
 
      
    END PROC_DEL_GET_IN;

    --SELECT
    PROCEDURE PROC_SEL_GET_IN 
    (
        IN_GET_IN_ID        IN      VARCHAR2,
        IN_P_ID             IN      VARCHAR2,
        IN_T_ID             IN      VARCHAR2,
        IN_CHECK_IN         IN      VARCHAR2,
        IN_CHECK_OUT        IN      VARCHAR2,
        O_CUR               OUT     SYS_REFCURSOR
    )
    AS

    BEGIN
    
      OPEN O_CUR  FOR
      
        SELECT *
        FROM GET_IN_TBL
        WHERE GET_IN_ID LIKE '%'||IN_GET_IN_ID ||'%' AND
        P_ID LIKE '%'||IN_P_ID ||'%' AND 
        T_ID LIKE '%'||IN_T_ID ||'%' AND 
        TO_CHAR(CHECK_IN,'YYYYMMDD HH24:MI') LIKE '%'||IN_CHECK_IN ||'%' AND 
        TO_CHAR(CHECK_OUT,'YYYYMMDD HH24:MI') LIKE '%'||IN_CHECK_OUT ||'%'
        ;
        
      
    END PROC_SEL_GET_IN;

--PROCEDURE END

END PKG_GET_IN;