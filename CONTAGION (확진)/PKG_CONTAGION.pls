create or replace NONEDITIONABLE PACKAGE PKG_CONTAGION AS 

  PROCEDURE PROC_SEL_CONTAGION(
        IN_CON_ID               IN              VARCHAR2,
        O_TBL                   OUT             SYS_REFCURSOR
  );
  
  PROCEDURE PROC_MOD_CONTAGION(
        IN_CON_ID               IN              VARCHAR2,
        IN_CHK_ID               IN              VARCHAR2,
        IN_CON_DATE             IN              VARCHAR2
  );
  
  PROCEDURE PROC_DEL_CONTAGION(
        IN_CON_ID               IN              VARCHAR2
  );

END PKG_CONTAGION;