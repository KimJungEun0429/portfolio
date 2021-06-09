create or replace NONEDITIONABLE PACKAGE PKG_GROUP AS

PROCEDURE PROC_MOD_GROUP_TBL
(
    IN_G_ID               IN      VARCHAR2,
    IN_GROUP_NAME         IN      VARCHAR2
);

  PROCEDURE PROC_SEL_GROUP_TBL
(
          IN_G_ID             IN      VARCHAR2,
          O_CUR               OUT     SYS_REFCURSOR
);

PROCEDURE PROC_DEL_GROUP_TBL
(
          IN_G_ID             IN      VARCHAR2
);


END PKG_GROUP;