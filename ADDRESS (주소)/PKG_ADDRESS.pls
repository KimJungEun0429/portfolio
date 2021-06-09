create or replace NONEDITIONABLE PACKAGE PKG_ADDRESS AS 

  PROCEDURE PROC_MOD_ADDRESS_TBL
(
          IN_A_ID             IN      VARCHAR2,
          IN_A_VAL            IN      VARCHAR2, 
          IN_A_LVL            IN      NUMBER, 
          IN_A_PARENT_ID      IN      VARCHAR2,
          IN_GROUP_ID             IN      VARCHAR2
);
  
  
PROCEDURE PROC_SEL_ADDRESS_TBL
(
          IN_A_ID             IN      VARCHAR2,
          O_CUR               OUT     SYS_REFCURSOR
);


PROCEDURE PROC_DEL_ADDRESS_TBL
(
          IN_A_ID             IN      VARCHAR2
);



END PKG_ADDRESS;