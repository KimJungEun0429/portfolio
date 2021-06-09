create or replace NONEDITIONABLE PACKAGE BODY PKG_BUILDING AS

  PROCEDURE PROC_MOD_BUILDING_TBL
(
          IN_B_ID               IN      VARCHAR2,
          IN_B_NAME             IN      VARCHAR2, 
          IN_B_TEL              IN      VARCHAR2, 
          IN_B_ADD              IN      VARCHAR2
) 
  AS
  
        V_B_ID      CHAR(5);
  
  BEGIN
  
    --등록, 수정
    SELECT 'B' || TO_CHAR(NVL(SUBSTR(MAX(B_ID),2),0) +1,'FM0000')
    INTO V_B_ID
    FROM BUILDING_TBL
    ;
    
    MERGE INTO BUILDING_TBL
    USING DUAL
    ON(B_ID = IN_B_ID)
    
    WHEN MATCHED THEN
    
    UPDATE 
    SET B_NAME = IN_B_NAME , B_TEL = IN_B_TEL, B_ADD = IN_B_ADD

    WHEN NOT MATCHED THEN
    INSERT (B_ID, B_NAME, B_TEL, B_ADD)
    VALUES (V_B_ID, IN_B_NAME, IN_B_TEL, IN_B_ADD)
    ;
  END PROC_MOD_BUILDING_TBL;

--조회
  PROCEDURE PROC_SEL_BUILDING_TBL
(
          IN_B_ID             IN      VARCHAR2,
          O_CUR               OUT     SYS_REFCURSOR
) 

  AS
  BEGIN
  
    OPEN O_CUR FOR
    SELECT *
    FROM BUILDING_TBL
    WHERE B_ID = IN_B_ID
    ;
    
  END PROC_SEL_BUILDING_TBL;

--삭제
  PROCEDURE PROC_DEL_BUILDING_TBL
(
          IN_B_ID             IN      VARCHAR2
) 

    AS
    
    BEGIN
    
    DELETE FROM BUILDING_TBL
    WHERE B_ID = IN_B_ID
    ;
    
  END PROC_DEL_BUILDING_TBL;

END PKG_BUILDING;