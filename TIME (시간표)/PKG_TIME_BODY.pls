create or replace NONEDITIONABLE PACKAGE BODY PKG_TIME AS

--PROCEDURE START

    --INSERT / UPDATE
    PROCEDURE PROC_MOD_TIME 
    (
        IN_T_ID         IN      VARCHAR2,
        IN_T_START      IN      VARCHAR2,
        IN_T_END        IN      VARCHAR2,
        IN_VEHICLE_ID   IN      VARCHAR2
    ) 
    AS

    V_T_ID      CHAR(5); --T_ID 생성 변수

    BEGIN
    
        --1. V_T_ID 생성
        SELECT 'T'||TO_CHAR(TO_NUMBER(NVL(SUBSTR(MAX(T_ID),2),0))+1,'FM0000')
        INTO V_T_ID
        FROM TIME_TBL
        ;
        
        --2. MERGE INTO
        MERGE INTO TIME_TBL
        USING   DUAL
        ON(T_ID=IN_T_ID)
        
            --2.1 T_ID 존재하면 업데이트
            WHEN MATCHED THEN
            UPDATE
            SET T_START=TO_DATE(IN_T_START,'HH24:MI'), T_END=TO_DATE(IN_T_END,'HH24:MI'), VEHICLE_ID=IN_VEHICLE_ID
            --2.2 T_ID 존재안하면 인서트
            WHEN NOT MATCHED THEN
            INSERT
            (T_ID, T_START, T_END, VEHICLE_ID)
            VALUES
            (V_T_ID, TO_DATE(IN_T_START,'HH24:MI'), TO_DATE(IN_T_END,'HH24:MI'), IN_VEHICLE_ID)
            ;
            
    END PROC_MOD_TIME;

    --DELETE
    PROCEDURE PROC_DEL_TIME 
    (
        IN_T_ID     IN      VARCHAR2
    )
    AS

    BEGIN
      
      --1. T_ID 지정해서 삭제
      DELETE FROM TIME_TBL
      WHERE T_ID=IN_T_ID
      ;
      
     
      
    END PROC_DEL_TIME;

    --SELECT
    PROCEDURE PROC_SEL_TIME 
    (
        IN_T_ID         IN      VARCHAR2,
        IN_T_START      IN      VARCHAR2,
        IN_T_END        IN      VARCHAR2,
        IN_VEHICLE_ID   IN      VARCHAR2,
        O_CUR           OUT     SYS_REFCURSOR
    )
    AS

    BEGIN

      --조회
      OPEN O_CUR FOR
        SELECT *
        FROM TIME_TBL
            --검색 조건
        WHERE T_ID LIKE '%'|| IN_T_ID ||'%' AND 
        TO_CHAR(T_START,'HH24:MI') LIKE '%'|| IN_T_START ||'%' AND 
        TO_CHAR(T_END,'HH24:MI') LIKE '%'|| IN_T_END ||'%' AND 
        VEHICLE_ID LIKE '%'|| IN_VEHICLE_ID ||'%'
        ;
      
    END PROC_SEL_TIME;

--PROCEDURE END

END PKG_TIME;