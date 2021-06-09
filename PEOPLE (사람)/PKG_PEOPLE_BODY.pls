create or replace NONEDITIONABLE PACKAGE BODY PKG_PEOPLE AS

  PROCEDURE PROC_MOD_PEOPLE_TBL
(
          IN_P_ID               IN      VARCHAR2,
          IN_P_NAME             IN      VARCHAR2,
          IN_P_GENDER           IN      VARCHAR2, 
          IN_P_TEL              IN      VARCHAR2, 
          IN_P_BIRTH            IN      DATE,
          IN_P_ADD              IN      VARCHAR2
) 
  
  AS
  
            V_P_ID      CHAR(5);
  
  BEGIN
    
    --등록, 수정
    SELECT 'P' || TO_CHAR(NVL(SUBSTR(MAX(P_ID),2),0) +1,'FM0000')
    INTO V_P_ID
    FROM PEOPLE_TBL
    ;
   
    MERGE INTO PEOPLE_TBL
    USING DUAL
    ON(P_ID = IN_P_ID)
    
    WHEN MATCHED THEN
    
    UPDATE 
    SET P_NAME = IN_P_NAME , P_GENDER = IN_P_GENDER , P_TEL = IN_P_TEL, P_BIRTH = IN_P_BIRTH, P_ADD = IN_P_ADD

    WHEN NOT MATCHED THEN
    INSERT (P_ID, P_NAME, P_GENDER, P_TEL, P_BIRTH, P_ADD)
    VALUES (V_P_ID, IN_P_NAME, IN_P_GENDER, IN_P_TEL, IN_P_BIRTH, IN_P_ADD)
    ;
  
    
  END PROC_MOD_PEOPLE_TBL;

 --조회
  PROCEDURE PROC_SEL_PEOPLE_TBL
(
          IN_P_ID             IN      VARCHAR2,
          O_CUR               OUT     SYS_REFCURSOR
) AS
  BEGIN
    
    OPEN O_CUR FOR
    SELECT *
    FROM PEOPLE_TBL
    WHERE P_ID = IN_P_ID
    ;
    
  END PROC_SEL_PEOPLE_TBL;

 --삭제
  PROCEDURE PROC_DEL_PEOPLE_TBL
(
          IN_P_ID             IN      VARCHAR2
) 
    AS
            
    BEGIN
    DELETE FROM PEOPLE_TBL
    WHERE P_ID = IN_P_ID
    ;

  END PROC_DEL_PEOPLE_TBL;

END PKG_PEOPLE;