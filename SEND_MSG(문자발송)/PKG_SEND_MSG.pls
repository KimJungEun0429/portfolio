create or replace NONEDITIONABLE PACKAGE PKG_SEND_MSG AS 

  PROCEDURE PROC_INS_SEND_MSG
  (
        IN_VISIT_ID        IN           VARCHAR2,
        IN_MSG_ID          IN           VARCHAR2,
        IN_SM_DATE         IN           VARCHAR2,
        IN_GET_IN_ID       IN           VARCHAR2
  );
  
  PROCEDURE PROC_SEL_SEND_MSG
  (
        IN_SM_ID        IN              VARCHAR2,
        O_CUR           OUT             SYS_REFCURSOR
  );
  
  PROCEDURE PROC_DEL_SEND_MSG
  (
        IN_SM_ID        IN              VARCHAR2
  );
  PROCEDURE PROC_UP_SEND_MSG
  (
        IN_SM_ID        IN              VARCHAR2,
        IN_VISIT_ID        IN           VARCHAR2,
        IN_MSG_ID          IN           VARCHAR2,
        IN_SM_DATE         IN           VARCHAR2,
        IN_GET_IN_ID       IN           VARCHAR2
  );

END PKG_SEND_MSG;