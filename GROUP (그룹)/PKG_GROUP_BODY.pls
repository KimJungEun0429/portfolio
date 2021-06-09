create or replace NONEDITIONABLE PACKAGE BODY PKG_GROUP AS

--수정,등록
  PROCEDURE PROC_MOD_GROUP_TBL
(
    IN_G_ID               IN      VARCHAR2,
    IN_GROUP_NAME         IN      VARCHAR2
) 

  AS
  
    V_G_ID          CHAR(5);
  
  BEGIN
  
    SELECT 'G' || TO_CHAR(NVL(SUBSTR(MAX(G_ID),2),0) +1,'FM0000')
    INTO V_G_ID
    FROM GROUP_TBL
    ;
    
    MERGE INTO GROUP_TBL
    USING DUAL
    ON(G_ID = IN_G_ID)
    
    WHEN MATCHED THEN
    
    UPDATE 
    SET GROUP_NAME = IN_GROUP_NAME

    WHEN NOT MATCHED THEN
    INSERT (G_ID, GROUP_NAME)
    VALUES (V_G_ID ,IN_GROUP_NAME)
    ;
    
    END PROC_MOD_GROUP_TBL;
    
    --조회
  PROCEDURE PROC_SEL_GROUP_TBL
(
          IN_G_ID             IN      VARCHAR2,
          O_CUR               OUT     SYS_REFCURSOR
) 

  AS
  BEGIN
  
    OPEN O_CUR FOR
    SELECT *
    FROM GROUP_TBL
    WHERE G_ID = IN_G_ID
    ;
    
  END PROC_SEL_GROUP_TBL;

--삭제
  PROCEDURE PROC_DEL_GROUP_TBL
(
          IN_G_ID             IN      VARCHAR2
) 

    AS
    
    BEGIN
    
    DELETE FROM GROUP_TBL
    WHERE G_ID = IN_G_ID
    ;


    
  END PROC_DEL_GROUP_TBL;
   
   
    
  

END PKG_GROUP;