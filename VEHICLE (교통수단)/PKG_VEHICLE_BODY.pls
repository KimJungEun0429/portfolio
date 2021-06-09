create or replace NONEDITIONABLE PACKAGE BODY PKG_VEHICLE AS

--PROCEDURE START

    --INSERT / UPDATE
    PROCEDURE PROC_MOD_VEHICLE 
    (   
        IN_VEHICLE_ID       IN      VARCHAR2,
        IN_VEHICLE_NAME     IN      VARCHAR2
    )
    AS

    V_VEHICLE_ID      CHAR(7); --Ż�� ���̵� �ڵ� �ο�
    
    BEGIN
    
        --1. VEHECLE_ID ����
        SELECT 'VE'||TO_CHAR(TO_NUMBER(NVL(SUBSTR(MAX(VEHICLE_ID),3),0)+1),'FM00000')
        INTO V_VEHICLE_ID
        FROM VEHICLE_TBL
        ;
        
        --2. MERGE INTO
        MERGE INTO  VEHICLE_TBL
        USING   DUAL
        ON(VEHICLE_ID= IN_VEHICLE_ID)
            --2.1 ������ �����ϸ� ������Ʈ
            WHEN MATCHED THEN
            UPDATE
            SET VEHICLE_NAME = IN_VEHICLE_NAME
            
            --2.2 ���� ������ �μ�Ʈ
            WHEN NOT MATCHED THEN
            INSERT
            (VEHICLE_ID, VEHICLE_NAME)
            VALUES
            (V_VEHICLE_ID,IN_VEHICLE_NAME)
            ;
            
    END PROC_MOD_VEHICLE;

    --DELETE
    PROCEDURE PROC_DEL_VEHICLE
    (
        IN_VEHICLE_ID       IN      VARCHAR2
    )
    AS 

    BEGIN

        --1. ���� ���̵� ���� ������ ����
        DELETE FROM VEHICLE_TBL
        WHERE VEHICLE_ID=IN_VEHICLE_ID
        ;
        
      
    
    END PROC_DEL_VEHICLE;

    --SELECT
    PROCEDURE PROC_SEL_VEHICLE
    (   
        IN_VEHICLE_ID   IN      VARCHAR2,
        IN_VEHICLE_NAME IN      VARCHAR2,
        O_CUR           OUT     SYS_REFCURSOR
    )
    AS 

    BEGIN
    
      OPEN O_CUR FOR
        SELECT *
        FROM VEHICLE_TBL
        WHERE VEHICLE_ID LIKE '%'||IN_VEHICLE_ID||'%' AND
        VEHICLE_NAME LIKE '%'||IN_VEHICLE_NAME||'%'
        ;
      
    END PROC_SEL_VEHICLE;

--PROCEDURE END

END PKG_VEHICLE;