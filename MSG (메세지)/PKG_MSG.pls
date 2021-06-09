create or replace NONEDITIONABLE PACKAGE PKG_MSG AS 

--메세지 입력 프로시저
PROCEDURE PROC_MOD_MSG_TBL
  (
        IN_MSG_ID           IN          VARCHAR2,
        IN_MSG_VALUE        IN          VARCHAR2
  );
  
--메세지 조회 프로시저
PROCEDURE PROC_SEL_MSG_TBL
(
          IN_MSG_ID              IN      VARCHAR2,
          O_CUR                  OUT     SYS_REFCURSOR
);

--메세지 삭제 프로시저
PROCEDURE PROC_DEL_MSG_TBL
(
          IN_MSG_ID             IN      VARCHAR2
);


END PKG_MSG;