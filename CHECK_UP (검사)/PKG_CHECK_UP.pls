create or replace NONEDITIONABLE PACKAGE PKG_CHECK_UP AS 

  PROCEDURE PROC_SEL_CHECKUP(
       IN_CHK_ID        IN          VARCHAR2,
       O_TBL            OUT         SYS_REFCURSOR
  );
  
  PROCEDURE PROC_MOD_CHECKUP(
        IN_CHK_ID       IN          VARCHAR2,
        IN_SM_ID        IN          VARCHAR2,
        IN_C_YN         IN          VARCHAR2,
        IN_CHK_DATE     IN          VARCHAR2
  );
  
  PROCEDURE PROC_DEL_CHECKUP(
        IN_CHK_ID       IN          VARCHAR2
  );
END PKG_CHECK_UP;