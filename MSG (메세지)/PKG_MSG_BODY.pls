create or replace NONEDITIONABLE PACKAGE BODY PKG_MSG AS

--메세지 입력,수정 프로시저
  PROCEDURE PROC_MOD_MSG_TBL
  (
        IN_MSG_ID            IN          VARCHAR2,
        IN_MSG_VALUE         IN          VARCHAR2
  ) 
  
  AS
            V_MSG_ID        CHAR(5);
  BEGIN
    
    SELECT 'MSG' || TO_CHAR(NVL(MAX(MSG_ID),''))
    INTO V_MSG_ID
    FROM MSG_TBL
    ;
    
    MERGE INTO MSG_TBL
    USING DUAL
    ON(MSG_ID = IN_MSG_ID)
    WHEN MATCHED THEN
    UPDATE SET MSG_VALUE = IN_MSG_VALUE
    WHEN NOT MATCHED THEN
    INSERT (MSG_ID, MSG_VALUE)
    VALUES (V_MSG_ID, IN_MSG_VALUE)
    ;
    
  END PROC_MOD_MSG_TBL;
  
 --메세지 조회 프로시저
 PROCEDURE PROC_SEL_MSG_TBL
(
          IN_MSG_ID              IN      VARCHAR2,
          O_CUR                  OUT     SYS_REFCURSOR
)
AS
BEGIN
    OPEN O_CUR FOR
    SELECT *
    FROM MSG_TBL
    WHERE MSG_ID = IN_MSG_ID
    ;
    
END PROC_SEL_MSG_TBL;
 --메세지 삭제 프로시저
 PROCEDURE PROC_DEL_MSG_TBL
(
          IN_MSG_ID             IN      VARCHAR2
)
AS
BEGIN
    DELETE FROM MSG_TBL
    WHERE MSG_ID = IN_MSG_ID
    ;

END PROC_DEL_MSG_TBL;


END PKG_MSG;