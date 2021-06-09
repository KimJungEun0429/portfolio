create or replace NONEDITIONABLE PACKAGE PKG_PROCESS AS 
    
    -- 1. Ȯ���ڿ� ���������� ã�� ���� ���ڹ߼� ���̺� INSERT�ϴ� ���ν��� ����
    PROCEDURE PROC_INS_CONTACT_CONTAGION(
        IN_CON_ID         IN          VARCHAR2 
    );
    --Ȯ���ڿ� ���������� ã�� ���� ���ڹ߼� ���̺� INSERT�ϴ� ���ν��� ����
    
    -- 2. Ȯ���ڰ� ���ƴٴ� ���� ã�Ƴ��� ���ν��� ����
    PROCEDURE PROC_FIND_PLACE(
        O_CUR            OUT            SYS_REFCURSOR 
    );
    --Ȯ���ڰ� ���ƴٴ� ���� ã�Ƴ��� ���ν��� ����
    
    --3. ����Ȯ���ڿ� ������ ��� ���� ã�� ���ڹ߼� ���̺� INSERT�ϴ� ���ν��� ����
    PROCEDURE PROC_FIRST_CONTAGION(
        IN_CON_ID           IN              VARCHAR2
    );
    -- ����Ȯ���ڿ� ������ ��� ���� ã�� ���ڹ߼� ���̺� INSERT�ϴ� ���ν��� ����
    
    --4. ���� ���� Ȯ���� �� ã�Ƴ��� ���ν��� ����
    PROCEDURE PROC_GENDER(
        O_CUR          OUT             SYS_REFCURSOR
    );
    --���� ���� Ȯ���� �� ã�Ƴ��� ���ν��� ����
    
    
    --5. ������ ���� ���� ��� ã�Ƴ��� ���ν��� ����
    PROCEDURE PROC_MANY_TRAKING(
        O_CUR         OUT         SYS_REFCURSOR
    );
    -- ������ ���� ���� ��� ã�Ƴ��� ���ν��� ����
    
    
    --6. �ڰ��ݸ��� ã�Ƴ��� ���ν��� ����
    PROCEDURE PROC_SELF_ISOLATION_LIST(
        O_CUR         OUT         SYS_REFCURSOR
    );
    -- �ڰ��ݸ��� ã�Ƴ��� ���ν��� ����
    
    
    --7. Ȯ���� ��� ���� ���ϴ� ���ν��� ����
    PROCEDURE PROC_CON_AVG_AGE(
        O_CUR         OUT             SYS_REFCURSOR
    );
    --Ȯ���� ��� ���� ���ϴ� ���ν��� ����
    
    --8. Ȯ���ڰ� �湮���� �ӹ� �ð����ϴ� ���ν��� ����
    PROCEDURE PROC_CON_STAY_TIME(
        O_CUR           OUT           SYS_REFCURSOR
    );
    --Ȯ���ڰ� �湮���� �ӹ� �ð����ϴ� ���ν��� ����
    
    
    --9. �ڷγ� �˻縦 �޾����� ����� ������ ����� ���ϴ� ���ν��� ����
    PROCEDURE PROC_SEL_CHECK_UP_N(
        O_CUR       OUT     SYS_REFCURSOR
    );
    -- �ڷγ� �˻縦 �޾����� �ܷΰ��� ������ ����� ���ϴ� ���ν��� ����
    
    --10. �Ű������� �޾ƿͼ� ��¥��/������/������ܺ� Ȯ���� �߻��� �˻��ϴ� ���ν��� ����
    PROCEDURE PROC_SEL_CON(
        O_CUR   OUT     SYS_REFCURSOR,
        IN_CLICK    IN      VARCHAR2
    );
    --�Ű������� �޾ƿͼ� ��¥��/������/������ܺ� Ȯ���� �߻��� �˻��ϴ� ���ν��� ����
    
    --11. ��¥�� Ȯ���� �߻� ���� Ȱ���Ͽ� ���� ��� Ȯ���� ���� ���� �����ִ� ���ν��� ����
    PROCEDURE PROC_SEL_CON_PLUS(
         O_CUR       OUT         SYS_REFCURSOR
    );
    --��¥�� Ȯ���� �߻� ���� Ȱ���Ͽ� ���� ��� Ȯ���� ���� ���� �����ִ� ���ν��� ����
    
    --12.�˻� ���̺��� �˻��� ����� ��¥���� �˻� ���, Ȯ�� ��� �����͸� �����ͼ� ��¥�� Ȯ���� ���ϴ� ���ν��� ����
    PROCEDURE PROC_SEL_CON_RATE(
        IN_CHK_DATE     IN      VARCHAR2,
        O_CUR           OUT     SYS_REFCURSOR
    );
    -- �˻� ���̺��� �˻��� ����� ��¥���� �˻� ���, Ȯ�� ��� �����͸� �����ͼ� ��¥�� Ȯ���� ���ϴ� ���ν��� ����
    
    --13.  Ȯ���ڰ� �߻��� �ǹ� ��� �߿��� ������ġ �̻� Ȯ���ڰ� �߻��� �ǹ��� ���� ���� �߻����� �����ϰ�, ���� ���� �߻����� �˻��� �� �ִ� ���ν��� ����
    PROCEDURE PROC_SEL_INFECTION_BUILDINGS(
        O_CUR       OUT     SYS_REFCURSOR
    );
    --Ȯ���ڰ� �߻��� �ǹ� ��� �߿��� ������ġ �̻� Ȯ���ڰ� �߻��� �ǹ��� ���� ���� �߻����� �����ϰ�, ���� ���� �߻����� �˻��� �� �ִ� ���ν��� ����
    
    --14. Ȯ���ڿ� �����Ͽ� �ڷγ� �˻� ��� ���������� ���� �˻���� ��� ���̺� ������� ���� ����� �˻��ϴ� ���ν��� ����
    PROCEDURE PROC_SEL_NOT_CHK(
        O_CUR       OUT     SYS_REFCURSOR
    );
    --Ȯ���ڿ� �����Ͽ� �ڷγ� �˻� ��� ���������� ���� �˻���� ��� ���̺� ������� ���� ����� �˻��ϴ� ���ν��� ����
END PKG_PROCESS;