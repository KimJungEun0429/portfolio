create or replace NONEDITIONABLE PACKAGE PKG_GET_IN AS 

--PROCEDURE START

    -- UPDATE / INSERT
    PROCEDURE PROC_MOD_GET_IN
    (
        IN_GET_IN_ID        IN      VARCHAR2,
        IN_P_ID             IN      VARCHAR2,
        IN_T_ID             IN      VARCHAR2,
        IN_CHECK_IN         IN      VARCHAR2,
        IN_CHECK_OUT        IN      VARCHAR2
    );
    
    --DELETE
    PROCEDURE PROC_DEL_GET_IN 
    (
        IN_GET_IN_ID        IN      VARCHAR2
    );
    
    --SELECT
    PROCEDURE PROC_SEL_GET_IN 
    (
        IN_GET_IN_ID        IN      VARCHAR2,
        IN_P_ID             IN      VARCHAR2,
        IN_T_ID             IN      VARCHAR2,
        IN_CHECK_IN         IN      VARCHAR2,
        IN_CHECK_OUT        IN      VARCHAR2,
        O_CUR               OUT     SYS_REFCURSOR
    );
  
  
--PROCEDURE END

END PKG_GET_IN;