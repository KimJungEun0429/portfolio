create or replace NONEDITIONABLE PACKAGE PKG_MSG AS 

--�޼��� �Է� ���ν���
PROCEDURE PROC_MOD_MSG_TBL
  (
        IN_MSG_ID           IN          VARCHAR2,
        IN_MSG_VALUE        IN          VARCHAR2
  );
  
--�޼��� ��ȸ ���ν���
PROCEDURE PROC_SEL_MSG_TBL
(
          IN_MSG_ID              IN      VARCHAR2,
          O_CUR                  OUT     SYS_REFCURSOR
);

--�޼��� ���� ���ν���
PROCEDURE PROC_DEL_MSG_TBL
(
          IN_MSG_ID             IN      VARCHAR2
);


END PKG_MSG;