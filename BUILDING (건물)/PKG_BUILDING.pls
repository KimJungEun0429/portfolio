create or replace NONEDITIONABLE PACKAGE PKG_BUILDING AS 

 PROCEDURE PROC_MOD_BUILDING_TBL
(
          IN_B_ID               IN      VARCHAR2,
          IN_B_NAME             IN      VARCHAR2, 
          IN_B_TEL              IN      VARCHAR2, 
          IN_B_ADD              IN      VARCHAR2
);

PROCEDURE PROC_SEL_BUILDING_TBL
(
          IN_B_ID             IN      VARCHAR2,
          O_CUR               OUT     SYS_REFCURSOR
);

PROCEDURE PROC_DEL_BUILDING_TBL
(
          IN_B_ID             IN      VARCHAR2
);

END PKG_BUILDING;