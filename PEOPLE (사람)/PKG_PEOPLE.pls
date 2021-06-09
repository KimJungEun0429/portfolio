create or replace NONEDITIONABLE PACKAGE PKG_PEOPLE AS 

  PROCEDURE PROC_MOD_PEOPLE_TBL
(
          IN_P_ID               IN      VARCHAR2,
          IN_P_NAME             IN      VARCHAR2,
          IN_P_GENDER           IN      VARCHAR2, 
          IN_P_TEL              IN      VARCHAR2, 
          IN_P_BIRTH            IN      DATE,
          IN_P_ADD              IN      VARCHAR2
);

PROCEDURE PROC_SEL_PEOPLE_TBL
(
          IN_P_ID             IN      VARCHAR2,
          O_CUR               OUT     SYS_REFCURSOR
);

PROCEDURE PROC_DEL_PEOPLE_TBL
(
          IN_P_ID             IN      VARCHAR2
);



END PKG_PEOPLE;