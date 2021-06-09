create or replace NONEDITIONABLE PACKAGE BODY PKG_VISIT AS

--PROCEDURE START

    --INSERT / UPDATE
    PROCEDURE PROC_MOD_VISIT 
    (
    IN_VISIT_ID IN      VARCHAR2,
    IN_P_ID     IN      VARCHAR2,
    IN_B_ID     IN      VARCHAR2,
    IN_CHECK_IN    IN      VARCHAR2,
    IN_CHECK_OUT   IN      VARCHAR2,
    IN_V_TEM       IN      NUMBER
    )
    AS 
    V_VISIT_ID  CHAR(7);

    BEGIN
    
      --1.VISIT_ID �ڵ����� �����
        SELECT 'VI' || TO_CHAR(TO_NUMBER(NVL(SUBSTR(MAX(VISIT_ID),3),0) +1),'FM00000')
        INTO V_VISIT_ID
        FROM VISIT_TBL
        ;
      
      --2.MERGE INTO
      
        MERGE INTO VISIT_TBL
        USING DUAL
        ON(VISIT_ID=IN_VISIT_ID)
        
        
        --2.1 VI_ID�� �����ϸ� ������Ʈ �ض�
        WHEN MATCHED THEN
        UPDATE 
        SET P_ID=IN_P_ID , B_ID=IN_B_ID ,CHECK_IN=TO_DATE(IN_CHECK_IN,'YYYYMMDD HH24:MI:SS') 
        , CHECK_OUT=TO_DATE(IN_CHECK_OUT,'YYYYMMDD HH24:MI:SS') , V_TEM=IN_V_TEM
    
        
        WHEN NOT MATCHED THEN
        --2.2  VI_ID�� �������������� �μ�Ʈ ����(*�������� �ʴ� P_ID�� B_ID�� �� �� ����*)
        INSERT
        (VISIT_ID, P_ID, B_ID, CHECK_IN, CHECK_OUT, V_TEM)
        VALUES
        (V_VISIT_ID, IN_P_ID, IN_B_ID, TO_DATE(IN_CHECK_IN,'YYYYMMDD HH24:MI:SS'), TO_DATE(IN_CHECK_OUT,'YYYYMMDD HH24:MI:SS') , IN_V_TEM)
        ;    
      
    END PROC_MOD_VISIT;
  
    --DELETE
    PROCEDURE PROC_DEL_VISIT 
    (
        IN_VISIT_ID     IN      VARCHAR2
    ) 
    AS

    BEGIN
    
        --1. ���̵� �Է��ϸ� ����
        DELETE FROM VISIT_TBL
        WHERE VISIT_ID=IN_VISIT_ID
        ;
       
      
    END PROC_DEL_VISIT;
  
    --SELECT
    PROCEDURE PROC_SEL_VISIT
    (
        IN_VISIT_ID     IN      VARCHAR2,
        IN_P_ID         IN      VARCHAR2,
        IN_B_ID         IN      VARCHAR2,
        IN_CHECK_IN     IN      VARCHAR2,
        IN_CHECK_OUT    IN      VARCHAR2,
        IN_V_TEM        IN      NUMBER,
        O_CUR       OUT     SYS_REFCURSOR
    )
    AS 

    BEGIN

    --1. VISIT_TBL ��ȸ
    OPEN O_CUR FOR
  
        SELECT * 
        FROM VISIT_TBL
            --�Ű����� ���Ե� �κ� ��ȸ ����
        WHERE VISIT_ID LIKE '%'||IN_VISIT_ID||'%' AND
        P_ID LIKE '%'|| IN_P_ID ||'%' AND
        B_ID LIKE '%'|| IN_B_ID ||'%' AND
        CHECK_IN LIKE '%'|| IN_CHECK_IN ||'%' AND
        CHECK_OUT LIKE '%'|| IN_CHECK_OUT ||'%' AND
        V_TEM LIKE '%'|| IN_V_TEM ||'%'
        ;
  
    END PROC_SEL_VISIT;

END PKG_VISIT;