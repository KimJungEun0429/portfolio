create or replace NONEDITIONABLE PACKAGE BODY PKG_ADDRESS AS

  PROCEDURE PROC_MOD_ADDRESS_TBL
(
          IN_A_ID             IN      VARCHAR2,
          IN_A_VAL            IN      VARCHAR2, 
          IN_A_LVL            IN      NUMBER, 
          IN_A_PARENT_ID      IN      VARCHAR2,
          IN_GROUP_ID             IN      VARCHAR2
) 
  AS
  
        V_A_ID      CHAR(5);
  
  BEGIN
  
     --등록, 수정
    SELECT 'A' || TO_CHAR(NVL(SUBSTR(MAX(A_ID),2),0) +1,'FM0000')
    INTO V_A_ID
    FROM ADDRESS_TBL
    ;
    
    MERGE INTO ADDRESS_TBL
    USING DUAL
    ON(A_ID = IN_A_ID)
    
    WHEN MATCHED THEN
    
    UPDATE 
    SET A_VAL = IN_A_VAL, A_LVL = IN_A_LVL, A_PARENT_ID = IN_A_PARENT_ID, GROUP_ID = IN_GROUP_ID

    WHEN NOT MATCHED THEN
    INSERT (A_ID, A_VAL, A_LVL, A_PARENT_ID,GROUP_ID)
    VALUES (V_A_ID ,IN_A_VAL,IN_A_LVL, IN_A_PARENT_ID, IN_GROUP_ID)
    ;
   
  END PROC_MOD_ADDRESS_TBL;

  PROCEDURE PROC_SEL_ADDRESS_TBL
(
          IN_A_ID             IN      VARCHAR2,
          O_CUR               OUT     SYS_REFCURSOR
) 

  AS
  BEGIN
  
    --조회
    OPEN O_CUR FOR
    SELECT *
    FROM ADDRESS_TBL
    WHERE A_ID = IN_A_ID
    ;
    
  END PROC_SEL_ADDRESS_TBL;

  PROCEDURE PROC_DEL_ADDRESS_TBL
(
          IN_A_ID             IN      VARCHAR2
) 
  AS
  BEGIN
  
  --삭제
    DELETE FROM ADDRESS_TBL
    WHERE A_ID = IN_A_ID
    ;
    
   
    
  END PROC_DEL_ADDRESS_TBL;

END PKG_ADDRESS;