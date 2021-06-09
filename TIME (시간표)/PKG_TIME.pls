create or replace NONEDITIONABLE PACKAGE PKG_TIME AS 

--PROCEDURE START

    -- INSERT / UPDATE
    PROCEDURE PROC_MOD_TIME 
    (
        IN_T_ID         IN      VARCHAR2,
        IN_T_START      IN      VARCHAR2,
        IN_T_END        IN      VARCHAR2,
        IN_VEHICLE_ID   IN      VARCHAR2
    );
    
    --DELETE
    PROCEDURE PROC_DEL_TIME 
    (
        IN_T_ID     IN      VARCHAR2
    );
    
    --SELECT
    PROCEDURE PROC_SEL_TIME 
    (
        IN_T_ID         IN      VARCHAR2,
        IN_T_START      IN      VARCHAR2,
        IN_T_END        IN      VARCHAR2,
        IN_VEHICLE_ID   IN      VARCHAR2,
        O_CUR           OUT     SYS_REFCURSOR
    );


--PROCEDURE END
  
END PKG_TIME;