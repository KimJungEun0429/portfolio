create or replace NONEDITIONABLE PACKAGE PKG_VISIT AS 

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
    );
    
    --DELETE
    PROCEDURE PROC_DEL_VISIT 
    (
        IN_VISIT_ID     IN      VARCHAR2
    );
    
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
    );
  
--PROCEDURE END

END PKG_VISIT;