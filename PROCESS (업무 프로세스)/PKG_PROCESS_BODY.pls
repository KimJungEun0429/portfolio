create or replace NONEDITIONABLE PACKAGE BODY PKG_PROCESS AS

    -- 1. Ȯ���ڿ� ���������� ã�� ���� ���ڹ߼� ���̺� INSERT�ϴ� ���ν��� ����
    PROCEDURE PROC_INS_CONTACT_CONTAGION(
        IN_CON_ID         IN          VARCHAR2 
    )AS
        V_VISIT_ID          CHAR(7);
    BEGIN
        SELECT VISIT_ID
        INTO V_VISIT_ID
        FROM CONTAGION_TBL T1, CHECK_UP_TBL T2,SEND_MSG_TBL T3
        WHERE T1.CHK_ID = T2.CHK_ID AND T2.SM_ID = T3.SM_ID AND T1.CON_ID = IN_CON_ID;      --SEND_MSG_TBL���� VISIT_ID�� NULL����
        
        IF V_VISIT_ID IS NULL THEN
            
                
                INSERT INTO SEND_MSG_TBL
                SELECT 'SM' || TO_CHAR((SELECT TO_NUMBER(SUBSTR(NVL(MAX(SM_ID), 'SM00000'), 3)) FROM SEND_MSG_TBL) + ROW_NUMBER() OVER(ORDER BY SYSDATE), 'FM00000')
                    AS SM_ID,NULL,'MSG02',DD,GET_IN_ID           -- Ȯ���ڿ� ���� ��������� �ִ� ����� ���ڹ߼� ���̺� INSERT
                FROM (SELECT  
                        GET_IN_ID,'MSG02',TO_DATE(TO_CHAR(BCHECK_IN,'YYYYMMDD') + 1) AS DD,NULL 
                    FROM (
                            SELECT A.P_ID AS CON_ID1 ,A.CHECK_IN AS ACHECK_IN ,A.CHECK_OUT AS ACHECK_OUT ,B.GET_IN_ID, B.P_ID AS TLT_PID, B.T_ID,B.CHECK_IN AS BCHECK_IN,B.CHECK_OUT AS BCHECK_OUT
                            FROM (
                                SELECT P_ID,T_ID,CHECK_IN,CHECK_OUT,TO_CHAR(CHECK_IN,'YYYYMMDD') AS D
                                FROM GET_IN_TBL
                                WHERE P_ID = (
                                            SELECT P_ID
                                            FROM CONTAGION_TBL T1, CHECK_UP_TBL T2, SEND_MSG_TBL T3,GET_IN_TBL T4
                                            WHERE T1.CHK_ID = T2.CHK_ID AND T2.SM_ID = T3.SM_ID AND T3.GET_IN_ID = T4.GET_IN_ID AND T1.CON_ID = IN_CON_ID
                                           )
                                )A ,GET_IN_TBL B
                            WHERE A.T_ID = B.T_ID AND D = TO_CHAR(B.CHECK_IN,'YYYYMMDD')  -- Ȯ���ڿ� ���� ��¥�� ���� ��ۼ��ܿ� �־��� ����� ã�� ���ǹ�
                        )
                    WHERE ((BCHECK_IN <= ACHECK_IN AND BCHECK_OUT >= ACHECK_OUT) OR    -- ������¥�� ���� ��ۼ��ܿ� �־��� ����� �� ���� �ð��뿡 �־��� ����� ã��
                                                                        ((BCHECK_IN <= ACHECK_IN AND ACHECK_IN < BCHECK_OUT) AND (ACHECK_IN < BCHECK_OUT AND BCHECK_OUT <= ACHECK_OUT)) OR
                                                                        ((ACHECK_IN <= BCHECK_IN AND BCHECK_IN < ACHECK_OUT) AND (BCHECK_IN < ACHECK_OUT AND ACHECK_OUT <= BCHECK_OUT)) OR 
                                                                        (ACHECK_IN <= BCHECK_IN AND BCHECK_OUT <= ACHECK_OUT))  AND CON_ID1 != TLT_PID );
            
            
        ELSE
            
                INSERT INTO SEND_MSG_TBL
                SELECT  'SM' || TO_CHAR((SELECT TO_NUMBER(SUBSTR(NVL(MAX(SM_ID), 'SM00000'), 3)) FROM SEND_MSG_TBL) + ROW_NUMBER() OVER(ORDER BY DD), 'FM00000')
                        AS SM_ID ,VISIT_ID,'MSG02',DD,NULL   -- Ȯ���ڿ� ���� ��������� �ִ� ����� ���ڹ߼� ���̺� INSERT
                FROM (SELECT  
                        VISIT_ID,'MSG02',TO_DATE(TO_CHAR(BCHECK_IN,'YYYYMMDD') + 1) AS DD,NULL 
                    FROM (
                            SELECT A.P_ID AS CON_ID ,A.CHECK_IN AS ACHECK_IN ,A.CHECK_OUT AS ACHECK_OUT ,B.VISIT_ID, B.P_ID AS TLT_PID, B.B_ID,B.CHECK_IN AS BCHECK_IN,B.CHECK_OUT AS BCHECK_OUT
                            FROM (
                                SELECT P_ID,B_ID,CHECK_IN,CHECK_OUT,TO_CHAR(CHECK_IN,'YYYYMMDD') AS D
                                FROM VISIT_TBL
                                WHERE P_ID IN (
                                            SELECT P_ID
                                            FROM CONTAGION_TBL T1, CHECK_UP_TBL T2, SEND_MSG_TBL T3,VISIT_TBL T4
                                            WHERE T1.CHK_ID = T2.CHK_ID AND T2.SM_ID = T3.SM_ID AND T3.VISIT_ID = T4.VISIT_ID AND T1.CON_ID = IN_CON_ID
                                           )
                                )A ,VISIT_TBL B
                            WHERE A.B_ID = B.B_ID AND D = TO_CHAR(B.CHECK_IN,'YYYYMMDD')  -- Ȯ���ڿ� ���� ��¥�� �����ǹ��� �־��� ����� ã�� ���ǹ�
                        )
                    WHERE ((BCHECK_IN <= ACHECK_IN AND BCHECK_OUT >= ACHECK_OUT) OR   -- ������¥�� ���� �ǹ��� �־��� ����� �� ���� �ð��뿡 �־��� ����� ã��
                                                                        ((BCHECK_IN <= ACHECK_IN AND ACHECK_IN < BCHECK_OUT) AND (ACHECK_IN < BCHECK_OUT AND BCHECK_OUT <= ACHECK_OUT)) OR
                                                                        ((ACHECK_IN <= BCHECK_IN AND BCHECK_IN < ACHECK_OUT) AND (BCHECK_IN < ACHECK_OUT AND ACHECK_OUT <= BCHECK_OUT)) OR 
                                                                        (ACHECK_IN <= BCHECK_IN AND BCHECK_OUT <= ACHECK_OUT))  AND CON_ID != TLT_PID )
                
             ;
        END IF;
    END PROC_INS_CONTACT_CONTAGION;
    --Ȯ���ڿ� ���������� ã�� ���� ���ڹ߼� ���̺� INSERT�ϴ� ���ν��� ����
    
    
    -- 2. Ȯ���ڰ� ���ƴٴ� ���� ã�Ƴ��� ���ν��� ����
    
    PROCEDURE PROC_FIND_PLACE(
        O_CUR            OUT            SYS_REFCURSOR 
    )AS
    BEGIN
        OPEN O_CUR FOR
    -----------------------------------------------------------------------------------Ȯ������ �湮���
        SELECT *
        FROM (
            SELECT A.P_ID,ADDR || ' '|| B.B_NAME AS PLACE, TO_CHAR(A.CHECK_IN,'YYYY/MM/DD HH24:MI:SS') AS IN_TIME,TO_CHAR(A.CHECK_OUT,'YYYY/MM/DD HH24:MI:SS') AS OUT_TIME
        FROM (
            SELECT P_ID,B_ID,CHECK_IN,CHECK_OUT         --Ȯ���ڰ� �湮�ߴ� �ǹ��� üũ��,üũ�ƿ� �ð�
            FROM VISIT_TBL
            WHERE P_ID IN (
                            SELECT T4.P_ID                      
                            FROM CONTAGION_TBL T1, CHECK_UP_TBL T2, SEND_MSG_TBL T3,VISIT_TBL T4
                            WHERE T1.CHK_ID = T2.CHK_ID AND T2.SM_ID = T3.SM_ID AND GET_IN_ID IS NULL AND T3.VISIT_ID = T4.VISIT_ID
                           )
            ) A, BUILDING_TBL B,
            (
                SELECT T3.A_ID, T1.A_VAL ||' '|| T2.A_VAL||' '|| T3.A_VAL AS ADDR
                FROM ADDRESS_TBL T1, ADDRESS_TBL T2,ADDRESS_TBL T3
                WHERE T1.A_ID(+) = T2.A_PARENT_ID AND T2.A_ID(+) = T3.A_PARENT_ID       --���������� �Ǿ��ִ� �ּҸ� ���ٷ� ��Ÿ���� ���� ����
            ) C
            WHERE A.B_ID = B.B_ID AND B.B_ADD = C.A_ID
            --------------------------------------------------------------------------------Ȯ������ �湮���
            UNION
            --------------------------------------------------------------------------------Ȯ������ �������
            SELECT A.P_ID,C.VEHICLE_NAME AS PLACE, TO_CHAR(A.CHECK_IN,'YYYY/MM/DD HH24:MI:SS') AS IN_TIME,TO_CHAR(A.CHECK_OUT,'YYYY/MM/DD HH24:MI:SS') AS OUT_TIME
            FROM (
                SELECT P_ID,T_ID,CHECK_IN,CHECK_OUT                 --Ȯ���ڰ� ž���ߴ� ��ۼ��ܰ� �����ð�,�����ð�
                FROM GET_IN_TBL
                WHERE P_ID IN (
                                SELECT T4.P_ID
                                FROM CONTAGION_TBL T1, CHECK_UP_TBL T2, SEND_MSG_TBL T3,GET_IN_TBL T4
                                WHERE T1.CHK_ID = T2.CHK_ID AND T2.SM_ID = T3.SM_ID AND VISIT_ID IS NULL AND T3.GET_IN_ID = T4.GET_IN_ID
                               )
                ) A, TIME_TBL B,VEHICLE_TBL C
            WHERE A.T_ID = B.T_ID AND B.VEHICLE_ID = C.VEHICLE_ID
        )
        ORDER BY P_ID , IN_TIME;
        
            --------------------------------------------------------------------------------Ȯ������ �������
    END PROC_FIND_PLACE;
    
    --Ȯ���ڰ� ���ƴٴ� ���� ã�Ƴ��� ���ν��� ����
    
    
    --3. ����Ȯ���ڿ� ������ ��� ���� ã�� ���ڹ߼� ���̺� INSERT�ϴ� ���ν��� ����
    PROCEDURE PROC_FIRST_CONTAGION(
        IN_CON_ID           IN              VARCHAR2
    )AS
    BEGIN
            INSERT INTO SEND_MSG_TBL
            SELECT  'SM' || TO_CHAR((SELECT TO_NUMBER(SUBSTR(NVL(MAX(SM_ID), 'SM00000'), 3)) FROM SEND_MSG_TBL) + ROW_NUMBER() OVER(ORDER BY DD), 'FM00000')
                    AS SM_ID ,VISIT_ID,'MSG02',DD,NULL                  --�湮��Ͽ��� Ȯ���ڿ� ���� �ǹ��� �ִ� ����� ���ڹ߼� ���̺� INSERT
            FROM (SELECT  
                    VISIT_ID,'MSG02',TO_DATE(TO_CHAR(BCHECK_IN,'YYYYMMDD') + 1) AS DD,NULL
                FROM (
                        SELECT A.P_ID AS CON_ID ,A.CHECK_IN AS ACHECK_IN ,A.CHECK_OUT AS ACHECK_OUT ,B.VISIT_ID, B.P_ID AS TLT_PID, B.B_ID,B.CHECK_IN AS BCHECK_IN,B.CHECK_OUT AS BCHECK_OUT
                        FROM (
                            SELECT P_ID,B_ID,CHECK_IN,CHECK_OUT,TO_CHAR(CHECK_IN,'YYYYMMDD') AS D
                            FROM VISIT_TBL
                            WHERE P_ID IN (
                                        SELECT P_ID
                                        FROM CONTAGION_TBL T1, CHECK_UP_TBL T2, SEND_MSG_TBL T3,VISIT_TBL T4
                                        WHERE T1.CHK_ID = T2.CHK_ID AND T2.SM_ID = T3.SM_ID AND T3.VISIT_ID = T4.VISIT_ID AND T1.CON_ID = IN_CON_ID
                                       )
                            )A ,VISIT_TBL B
                        WHERE A.B_ID = B.B_ID AND D = TO_CHAR(B.CHECK_IN,'YYYYMMDD') -- Ȯ���ڿ� ���� ��¥�� �����ǹ��� �־��� ����� ã�� ���ǹ�
                    )
                WHERE ((BCHECK_IN <= ACHECK_IN AND BCHECK_OUT >= ACHECK_OUT) OR          -- ������¥�� ���� �ǹ��� �־��� ����� �� ���� �ð��뿡 �־��� ����� ã��
                                                                    ((BCHECK_IN <= ACHECK_IN AND ACHECK_IN < BCHECK_OUT) AND (ACHECK_IN < BCHECK_OUT AND BCHECK_OUT <= ACHECK_OUT)) OR
                                                                    ((ACHECK_IN <= BCHECK_IN AND BCHECK_IN < ACHECK_OUT) AND (BCHECK_IN < ACHECK_OUT AND ACHECK_OUT <= BCHECK_OUT)) OR 
                                                                    (ACHECK_IN <= BCHECK_IN AND BCHECK_OUT <= ACHECK_OUT))  AND CON_ID != TLT_PID );
        -----------------------------------------------------------------------------�ǹ� ����    
        
        -----------------------------------------------------------------------------���� ����
        INSERT INTO SEND_MSG_TBL(SM_ID,VISIT_ID,MSG_ID,SM_DATE,GET_IN_ID)
        SELECT 'SM' || TO_CHAR((SELECT TO_NUMBER(SUBSTR(NVL(MAX(SM_ID), 'SM00000'), 3)) FROM SEND_MSG_TBL) + ROW_NUMBER() OVER(ORDER BY SYSDATE), 'FM00000')
                AS SM_ID,NULL,'MSG02',BCHECK_OUT + 1,GET_IN_ID      -- Ȯ���ڿ� ���� ��������� �ִ� ����� ���ڹ߼� ���̺� INSERT
        FROM(
                 SELECT A.P_ID AS CON_ID1 ,A.CHECK_IN AS ACHECK_IN,A.CHECK_OUT AS ACHECK_OUT,B.GET_IN_ID,B.P_ID AS TLT_ID,B.CHECK_IN AS BCHECK_IN,B.CHECK_OUT AS BCHECK_OUT
                 FROM (
                         SELECT P_ID,T_ID, TO_CHAR(CHECK_IN,'YYYYMMDD') AS D1,CHECK_IN,CHECK_OUT
                         FROM GET_IN_TBL
                         WHERE P_ID = (                         
                                 SELECT P_ID
                                 FROM CONTAGION_TBL T1, CHECK_UP_TBL T2 , SEND_MSG_TBL T3,VISIT_TBL T4
                                 WHERE T1.CON_ID = IN_CON_ID AND T1.CHK_ID = T2.CHK_ID AND T2.SM_ID = T3.SM_ID AND T3.VISIT_ID = T4.VISIT_ID
                          )
                      ) A,
                      GET_IN_TBL B
                 WHERE A.T_ID = B.T_ID AND D1 = TO_CHAR(B.CHECK_IN,'YYYYMMDD') -- Ȯ���ڿ� ���� ��¥�� ���� ��ۼ��ܿ� �־��� ����� ã�� ���ǹ�
            )
        WHERE ((BCHECK_IN <= ACHECK_IN AND BCHECK_OUT >= ACHECK_OUT) OR         -- ������¥�� ���� ��ۼ��ܿ� �־��� ����� �� ���� �ð��뿡 �־��� ����� ã��
                                                                    ((BCHECK_IN <= ACHECK_IN AND ACHECK_IN < BCHECK_OUT) AND (ACHECK_IN < BCHECK_OUT AND BCHECK_OUT <= ACHECK_OUT)) OR
                                                                    ((ACHECK_IN <= BCHECK_IN AND BCHECK_IN < ACHECK_OUT) AND (BCHECK_IN < ACHECK_OUT AND ACHECK_OUT <= BCHECK_OUT)) OR 
                                                                    (ACHECK_IN <= BCHECK_IN AND BCHECK_OUT <= ACHECK_OUT))  AND CON_ID1 != TLT_ID 
        ;
    END PROC_FIRST_CONTAGION;
    -- ����Ȯ���ڿ� ������ ��� ���� ã�� ���ڹ߼� ���̺� INSERT�ϴ� ���ν��� ����
    
    
    --4. ���� ���� Ȯ���� �� ã�Ƴ��� ���ν��� ����
    PROCEDURE PROC_GENDER(
        O_CUR          OUT             SYS_REFCURSOR
    )AS
    BEGIN
         OPEN O_CUR FOR
         SELECT DECODE(P_GENDER,'F','����','����') AS GENDER ,COUNT(*) AS CNT       --������� ������ ���� ���ϱ�
         FROM (
                SELECT T5.*                                 --������ ����� �������
                FROM CONTAGION_TBL T1, CHECK_UP_TBL T2, SEND_MSG_TBL T3,GET_IN_TBL T4,PEOPLE_TBL T5
                WHERE T1.CHK_ID = T2.CHK_ID AND T2.SM_ID = T3.SM_ID AND T3.VISIT_ID IS NULL AND T3.GET_IN_ID = T4.GET_IN_ID AND T4.P_ID = T5.P_ID 
                
                UNION
                
                SELECT T5.*                                 --������ ����� �湮���
                FROM CONTAGION_TBL T1, CHECK_UP_TBL T2, SEND_MSG_TBL T3,VISIT_TBL T4,PEOPLE_TBL T5
                WHERE T1.CHK_ID = T2.CHK_ID AND T2.SM_ID = T3.SM_ID AND T3.GET_IN_ID IS NULL AND T3.VISIT_ID = T4.VISIT_ID AND T4.P_ID = T5.P_ID 
             )
         GROUP BY P_GENDER;
    END PROC_GENDER;
    --���� ���� Ȯ���� �� ã�Ƴ��� ���ν��� ����
    
    
    --5. ������ ���� ���� ��� ã�Ƴ��� ���ν��� ����
    PROCEDURE PROC_MANY_TRAKING(
        O_CUR         OUT         SYS_REFCURSOR
    )AS
    BEGIN
        OPEN O_CUR FOR
        
          SELECT E.CON_ID, E.P_ID, E.P_NAME, E.ALL_SUM, E.RNK
          FROM
                (
                    SELECT D.CON_ID,C.P_ID, C.P_NAME, C.ALL_SUM
                        ,RANK() OVER(ORDER BY C.ALL_SUM DESC) AS RNK
                    FROM
                    (
                        SELECT A.P_ID, A.P_NAME, NVL(A.V_CNT,0) + NVL(B.G_CNT,0) AS ALL_SUM
                        FROM
                        (
                            SELECT T1.P_ID, T2.P_NAME, COUNT(T1.VISIT_ID) AS V_CNT
                            FROM VISIT_TBL T1, PEOPLE_TBL T2
                            WHERE T1.P_ID = T2.P_ID
                            GROUP BY T1.P_ID, T2.P_NAME
                        )A,
                        (
                            SELECT T1.P_ID, T2.P_NAME, COUNT(T1.GET_IN_ID) AS G_CNT
                            FROM GET_IN_TBL T1, PEOPLE_TBL T2
                            WHERE T1.P_ID = T2.P_ID
                            GROUP BY T1.P_ID, T2.P_NAME
                        )B
                        WHERE A.P_ID = B.P_ID(+)
                    )C, ALL_CONTAGION_TBL D
                    WHERE C.P_ID = D.P_ID OR C.P_ID = D.G_P_ID
                )E
                WHERE E.RNK = 1
                ;
    END PROC_MANY_TRAKING;
    -- ������ ���� ���� ��� ã�Ƴ��� ���ν��� ����
    
    
    --6. �ڰ��ݸ��� ã�Ƴ��� ���ν��� ����
    PROCEDURE PROC_SELF_ISOLATION_LIST(
        O_CUR         OUT         SYS_REFCURSOR
    )AS
    BEGIN
        OPEN O_CUR FOR
                
                SELECT DISTINCT A1.P_NAME, A1.P_TEL, A1.P_GENDER, A1.P_BIRTH, A2.SI, A2.GU, A2.DONG
                FROM
                    (
                        SELECT T3.P_ID, T3.P_NAME, T3.P_TEL, T3.P_GENDER, T3.P_BIRTH, T3.P_ADD
                        FROM SEND_MSG_TBL T1, VISIT_TBL T2, PEOPLE_TBL T3
                        WHERE T1.VISIT_ID = T2.VISIT_ID
                        AND T2.P_ID = T3.P_ID
                        ORDER BY T1.SM_ID
                    )A1,--�ǹ� ���� �ڰ��ݸ��� 
                    (
                        SELECT T3.A_ID,T1.A_VAL AS SI, T2.A_VAL AS GU, T3.A_VAL AS DONG
                        FROM ADDRESS_TBL T1 , ADDRESS_TBL T2, ADDRESS_TBL T3
                        WHERE T1.A_ID = T2.A_PARENT_ID
                        AND T2.A_ID = T3.A_PARENT_ID
                    )A2--�ּ� ��������
                    WHERE A1.P_ADD = A2.A_ID
                    
                
                UNION ALL
                
                    SELECT DISTINCT A1.P_NAME, A1.P_TEL, A1.P_GENDER, A1.P_BIRTH, A2.SI, A2.GU, A2.DONG
                    FROM
                    (
                        SELECT T3.P_ID,T3.P_NAME, T3.P_TEL, T3.P_GENDER, T3.P_BIRTH, T3.P_ADD
                        FROM SEND_MSG_TBL T1, GET_IN_TBL T2, PEOPLE_TBL T3
                        WHERE T1.GET_IN_ID = T2.GET_IN_ID
                        AND T2.P_ID = T3.P_ID
                        ORDER BY T1.SM_ID
                    )A1,--������� ���� �ڰ��ݸ��� 
                    (
                        SELECT T3.A_ID,T1.A_VAL AS SI, T2.A_VAL AS GU, T3.A_VAL AS DONG
                        FROM ADDRESS_TBL T1 , ADDRESS_TBL T2, ADDRESS_TBL T3
                        WHERE T1.A_ID = T2.A_PARENT_ID
                        AND T2.A_ID = T3.A_PARENT_ID
                    )A2--�ּ� ��������
                    WHERE A1.P_ADD = A2.A_ID
                    ;
    END PROC_SELF_ISOLATION_LIST;
    -- �ڰ��ݸ��� ã�Ƴ��� ���ν��� ����
    
    
    --7. Ȯ���� ��� ���� ���ϴ� ���ν��� ����
    PROCEDURE PROC_CON_AVG_AGE(
        O_CUR         OUT             SYS_REFCURSOR
    )AS
    BEGIN
        OPEN O_CUR FOR
                
                SELECT AVG(TO_NUMBER(TO_CHAR(SYSDATE,'YYYY')) - TO_NUMBER(TO_CHAR(A.P_BIRTH,'YYYY'))) AS AVG_AGE
                FROM
                    (
                        SELECT T3.P_ID, T3.P_NAME, T3.P_TEL, T3.P_GENDER, T3.P_BIRTH, T3.P_ADD
                        FROM SEND_MSG_TBL T1, VISIT_TBL T2, PEOPLE_TBL T3, CHECK_UP_TBL T4
                        WHERE T1.VISIT_ID = T2.VISIT_ID
                        AND T2.P_ID = T3.P_ID
                        AND  T4.SM_ID = T1.SM_ID 
                        AND T4.C_YN = 'Y'
                        
                  
                    UNION ALL
                
                        SELECT T3.P_ID,T3.P_NAME, T3.P_TEL, T3.P_GENDER, T3.P_BIRTH, T3.P_ADD
                        FROM SEND_MSG_TBL T1, GET_IN_TBL T2, PEOPLE_TBL T3, CHECK_UP_TBL T4
                        WHERE T1.GET_IN_ID = T2.GET_IN_ID
                        AND T2.P_ID = T3.P_ID
                        AND  T4.SM_ID = T1.SM_ID 
                        AND T4.C_YN = 'Y'
                  )A
                  ;
    END PROC_CON_AVG_AGE;
    --Ȯ���� ��� ���� ���ϴ� ���ν��� ����
    
    --8. Ȯ���ڰ� �湮���� �ӹ� �ð����ϴ� ���ν��� ����
    PROCEDURE PROC_CON_STAY_TIME(
        O_CUR           OUT           SYS_REFCURSOR
    )AS
    BEGIN
        OPEN O_CUR FOR
            SELECT A.P_ID, A.P_NAME,A.NEW_NAME,A.AL_BTID,
                  ((TO_CHAR(A_OUT,'HH24')* 60 + TO_CHAR(A_OUT,'MI')+TO_CHAR(A_OUT,'SS')*1/60) - (TO_CHAR(A_IN,'HH24')* 60 + TO_CHAR(A_IN,'MI')+TO_CHAR(A_IN,'SS')*1/60))/60 AS STAR_TIME
                --(üũ�ƿ��ð�) - (üũ�νð�)���� Ȯ���ڰ� �ӹ��� �ð� ���
            FROM
            (
                SELECT B3.P_ID, B3.P_NAME, B3.A_IN, B3.A_OUT, B4.B_NAME AS NEW_NAME, B3.AL_BTID
                FROM
                (
                    SELECT B1.CON_ID, B1.P_ID, B1.P_NAME, B1.VISIT_ID AS VI_ID, B1.CHECK_IN AS A_IN, B1.CHECK_OUT AS A_OUT, B1.AL_BTID
                    FROM
                    (
                        SELECT T1.CON_ID,T4.P_ID, T5.P_NAME, T4.VISIT_ID, T4.CHECK_IN, T4.CHECK_OUT, T4.B_ID AS AL_BTID
                        FROM CONTAGION_TBL T1, CHECK_UP_TBL T2, SEND_MSG_TBL T3, VISIT_TBL T4, PEOPLE_TBL T5
                        WHERE T1.CHK_ID = T2.CHK_ID
                        AND T2.SM_ID = T3.SM_ID
                        AND T3.VISIT_ID = T4.VISIT_ID
                        AND T4.P_ID = T5.P_ID
                    )B1, VISIT_TBL B2
                    WHERE B1.P_ID = B2.P_ID
                  )B3, BUILDING_TBL B4
                  WHERE B3.AL_BTID = B4.B_ID
                  --Ȯ������ ��ü���� �湮 ���
                UNION ALL
                
                
                SELECT B5.P_ID, B5.P_NAME, B5.A_IN ,B5.A_OUT, B6.VEHICLE_NAME AS NEW_NAME, B5.AL_BTID
                FROM
                (
                    SELECT B3.P_ID, B3.P_NAME, B3.A_IN, B3.A_OUT,B4.T_ID, B4.VEHICLE_ID, B3.AL_BTID
                    FROM
                    (
                        SELECT B1.CON_ID, B1.P_ID, B1.P_NAME, B1.GET_IN_ID AS VI_ID, B2.CHECK_IN AS A_IN, B2.CHECK_OUT AS A_OUT,B2.T_ID AS AL_BTID
                        FROM
                        (
                            SELECT T1.CON_ID,T4.P_ID, T5.P_NAME, T4.GET_IN_ID, T4.CHECK_IN, T4.CHECK_OUT, T4.T_ID AS AL_BTID 
                            FROM CONTAGION_TBL T1, CHECK_UP_TBL T2, SEND_MSG_TBL T3, GET_IN_TBL T4, PEOPLE_TBL T5
                            WHERE T1.CHK_ID = T2.CHK_ID
                            AND T2.SM_ID = T3.SM_ID
                            AND T3.GET_IN_ID = T4.GET_IN_ID
                            AND T4.P_ID = T5.P_ID
                        )B1, GET_IN_TBL B2
                        WHERE B1.P_ID = B2.P_ID 
                   )B3, TIME_TBL B4
                   WHERE B3.AL_BTID = B4.T_ID
                )B5, VEHICLE_TBL B6
                WHERE B5.VEHICLE_ID = B6.VEHICLE_ID
                --Ȯ������ ��ü���� ������� ž�� ���
              )A
            ;

    END PROC_CON_STAY_TIME;
    --Ȯ���ڰ� �湮���� �ӹ� �ð����ϴ� ���ν��� ����
    
    
    --9. �ڷγ� �˻縦 �޾����� ����� ������ ����� ���ϴ� ���ν��� ����
    PROCEDURE PROC_SEL_CHECK_UP_N(
        O_CUR       OUT     SYS_REFCURSOR
    )AS
    BEGIN
         --2.	�˻����� ������ ��� ã��
        OPEN O_CUR FOR
        
        SELECT T1.*, T2.A_VAL1||' '|| T2.A_VAL2||' '|| T2.A_VAL3 AS A_VAL 
        FROM
            (
            SELECT D.P_ID, D.P_NAME, D.P_GENDER, D.P_TEL, D.P_BIRTH, D.P_ADD
            FROM CHECK_UP_TBL A, SEND_MSG_TBL B, VISIT_TBL C, PEOPLE_TBL D
            WHERE A.C_YN='N' AND B.SM_ID=A.SM_ID AND C.VISIT_ID=B.VISIT_ID AND D.P_ID=C.P_ID
            ) T1, --���� ����� ���� ��� �����͸� �����ֱ� ���ؼ� C_YN='N'�̸鼭 �˻縦 ���� ����� �Ż� ������ �����ֱ� ���ؼ� PEOPEL_TBL���� JOINȰ��
                  --�����Ͱ� VISIT_TBL�� GET_IN_TBL ������ ���̺� ����ֱ� ������ ������ ���Ͽ� UNION���� �ѹ��� SELECT�Ѵ�.
            (
            SELECT C.A_ID, A.A_VAL AS A_VAL1, B.A_VAL AS A_VAL2, C.A_VAL AS A_VAL3, A.GROUP_ID, C.A_PARENT_ID
            FROM ADDRESS_TBL A, ADDRESS_TBL B, ADDRESS_TBL C
            WHERE A.A_ID(+)=B.A_PARENT_ID AND B.A_ID(+)=C.A_PARENT_ID
            ORDER BY C.A_ID
            ) T2 --�ּ� ���̺� ���������� �̷���������Ƿ� SELF JOIN �� OUTER JOIN���� ó������ �� �������� �ѹ��� ������ �� �ֵ��� �ۼ�.
        WHERE T1.P_ADD=T2.A_ID
        
        UNION ALL   --������ϰ� �湮��� �� ���� ��츦 ���� ���Ͽ� �ѹ��� �����ֱ� ���� UNION ALL ���
        
        SELECT T1.*, T2.A_VAL1||' '|| T2.A_VAL2||' '|| T2.A_VAL3 AS A_VAL 
        FROM
            (
            SELECT D.P_ID, D.P_NAME, D.P_GENDER, D.P_TEL, D.P_BIRTH, D.P_ADD
            FROM CHECK_UP_TBL A, SEND_MSG_TBL B, GET_IN_TBL C, PEOPLE_TBL D
            WHERE A.C_YN='N' AND B.SM_ID=A.SM_ID AND C.GET_IN_ID=B.GET_IN_ID AND D.P_ID=C.P_ID
            ) T1,
            (
            SELECT C.A_ID, A.A_VAL AS A_VAL1, B.A_VAL AS A_VAL2, C.A_VAL AS A_VAL3, A.GROUP_ID, C.A_PARENT_ID
            FROM ADDRESS_TBL A, ADDRESS_TBL B, ADDRESS_TBL C
            WHERE A.A_ID(+)=B.A_PARENT_ID AND B.A_ID(+)=C.A_PARENT_ID
            ORDER BY C.A_ID
            ) T2
        WHERE T1.P_ADD=T2.A_ID
       ;
    END PROC_SEL_CHECK_UP_N;
    -- �ڷγ� �˻縦 �޾����� �ܷΰ��� ������ ����� ���ϴ� ���ν��� ����
    
    --10. �Ű������� �޾ƿͼ� ��¥��/������/������ܺ� Ȯ���� �߻��� �˻��ϴ� ���ν��� ����
    PROCEDURE PROC_SEL_CON(
        O_CUR   OUT     SYS_REFCURSOR,
        IN_CLICK    IN      VARCHAR2
    )AS
    BEGIN
         /* 
    ��¥�� ��������� 'DATE' �Է�, ������ ��������� 'ADDRESS' �Է�, ������ܺ� ��������� 'VEHICLE' �Է�
    ���� ��¥�� SYSDATE �� �� �޸� ������ ������ 
    */
    
        IF IN_CLICK = 'DATE' THEN
        OPEN O_CUR FOR
        --5�� ��ü ��¥�� Ȯ���� �߻� ��
        SELECT T2.MDATE, NVL(T1.CNT,0) AS CON_CNT
        FROM
            (
            SELECT CON_DATE, COUNT(*) AS CNT
            FROM CONTAGION_TBL
            GROUP BY CON_DATE
            ) T1, --Ȯ���� ���̺��� ��¥�� Ȯ���� ���� GROUP BY�� SELECT �Ѵ�.
            (
            SELECT TRUNC(SYSDATE,'MM') + (LEVEL-1) AS MDATE
            FROM DUAL
            CONNECT BY LEVEL <= 31
            ) T2 --SYSDATE�� LEVEL�� Ȱ���Ͽ� �� ���� ��¥�� ��� SELECT�Ѵ�.
        WHERE T1.CON_DATE(+)=T2.MDATE --OUTER JOIN�� Ȱ���Ͽ� ���ϸ��� Ȯ���ڼ��� ������ �� �ֵ��� �Ѵ�.
        ORDER BY T2.MDATE ;
        
        
         --������ Ȯ���� ��
        ELSIF IN_CLICK ='ADDRESS' THEN
        
        OPEN O_CUR FOR
        SELECT TT2.A_VAL, NVL(TT1.CON_CNT,0) AS CON_CNT
        FROM
        (
            SELECT *
            FROM
                (
                SELECT A_VAL1||' '||A_VAL2||' '||A_VAL3 AS A_VAL, COUNT(*) AS CON_CNT
                FROM
                    (
                    SELECT D.P_ID, D.P_NAME, D.P_GENDER, D.P_TEL, D.P_BIRTH, D.P_ADD
                    FROM CHECK_UP_TBL A, SEND_MSG_TBL B, VISIT_TBL C, PEOPLE_TBL D, CONTAGION_TBL E
                    WHERE E.CHK_ID=A.CHK_ID AND B.SM_ID=A.SM_ID AND C.VISIT_ID=B.VISIT_ID AND D.P_ID=C.P_ID
                    ) T1, --�湮����� �����Ͽ� �˻�ްԵ� �˻� ����� Ȯ���� ���̺� �����ϴ� Ȯ��ID�� ���� ����� SELECT.
                    
                    (
                   SELECT C.A_ID, A.A_VAL AS A_VAL1, B.A_VAL AS A_VAL2, C.A_VAL AS A_VAL3, A.GROUP_ID, C.A_PARENT_ID
                    FROM ADDRESS_TBL A, ADDRESS_TBL B, ADDRESS_TBL C
                    WHERE A.A_ID(+)=B.A_PARENT_ID AND B.A_ID(+)=C.A_PARENT_ID
                    ORDER BY C.A_ID
                    ) T2 --�ּ� ���̺��� SELF JOIN�ؼ� �ּҸ� �� �������� �����ش�.
                    
                WHERE T1.P_ADD=T2.A_ID
                GROUP BY A_VAL1||' '||A_VAL2||' '||A_VAL3 --���� �ּҿ� �����ϴ� Ȯ���ڳ��� GROUP BY �Ͽ� COUNT�� ����.
                
        UNION ALL --VISIT�� GET_IN �������� ���谡 �̷���� �ֱ⶧���� �� ��츦 ���ؼ� UNION.
        
                SELECT A_VAL1||' '||A_VAL2||' '||A_VAL3 AS A_VAL, COUNT(*) AS CON_CNT
                FROM
                    (
                    SELECT D.P_ID, D.P_NAME, D.P_GENDER, D.P_TEL, D.P_BIRTH, D.P_ADD
                    FROM CHECK_UP_TBL A, SEND_MSG_TBL B, GET_IN_TBL C, PEOPLE_TBL D, CONTAGION_TBL E
                    WHERE E.CHK_ID=A.CHK_ID AND B.SM_ID=A.SM_ID AND C.GET_IN_ID=B.GET_IN_ID AND D.P_ID=C.P_ID
                    ) T1, --��������� �����Ͽ� �˻�ްԵ� �˻� ����� Ȯ���� ���̺� �����ϴ� Ȯ��ID�� ���� ����� SELECT.
                    
                    (
                   SELECT C.A_ID, A.A_VAL AS A_VAL1, B.A_VAL AS A_VAL2, C.A_VAL AS A_VAL3, A.GROUP_ID, C.A_PARENT_ID
                    FROM ADDRESS_TBL A, ADDRESS_TBL B, ADDRESS_TBL C
                    WHERE A.A_ID(+)=B.A_PARENT_ID AND B.A_ID(+)=C.A_PARENT_ID
                    ORDER BY C.A_ID
                    ) T2 --�ּ� ���̺��� SELF JOIN�ؼ� �ּҸ� �� �������� �����ش�.
                    
                WHERE T1.P_ADD=T2.A_ID
                GROUP BY A_VAL1||' '||A_VAL2||' '||A_VAL3
                )
        ) TT1, --�� �ּҺ��� Ȯ���ڵ��� �����ϴ� ���ڸ� ��Ÿ����.
        
        (
            SELECT A.A_VAL||' '||B.A_VAL||' '||C.A_VAL AS A_VAL
            FROM ADDRESS_TBL A, ADDRESS_TBL B, ADDRESS_TBL C
            WHERE A.A_ID(+)=B.A_PARENT_ID AND B.A_ID(+)=C.A_PARENT_ID AND C.A_LVL=3
            ORDER BY C.A_ID
        ) TT2 --��� �ּҸ� ��Ÿ����.
        
        WHERE TT1.A_VAL(+)=TT2.A_VAL 
        --OUTER JOIN�� ���ؼ� Ȯ���ڰ� �������� �ʾ� NULL�� �ּҵ� ��� �����ֹǷ� NULL�� ��� NVL�� ���� 0���� ������ش�
        ;
        
        ELSIF IN_CLICK='VEHICLE' THEN
        
        OPEN O_CUR FOR
       
        --���� ���ܺ� Ȯ���� ��
        SELECT T2.VEHICLE_ID, T2.VEHICLE_NAME, NVL(T1.CNT,0) AS CNT
        FROM
        (
        SELECT F.VEHICLE_ID, F.VEHICLE_NAME, COUNT(*) AS CNT
        FROM CONTAGION_TBL A, CHECK_UP_TBL B, SEND_MSG_TBL C, GET_IN_TBL D, TIME_TBL E, VEHICLE_TBL F
        WHERE A.CHK_ID=B.CHK_ID AND B.SM_ID=C.SM_ID AND C.GET_IN_ID=D.GET_IN_ID AND D.T_ID=E.T_ID AND E.VEHICLE_ID=F.VEHICLE_ID
        GROUP BY F.VEHICLE_ID, F.VEHICLE_NAME
        ) T1, --JOIN�� ���ؼ� ���� ����� �ִ� Ȯ���ڵ��� � ��������� �̿��ߴ��� ������� ���� COUNT �Ѵ�.
        (
        SELECT VEHICLE_ID, VEHICLE_NAME
        FROM VEHICLE_TBL
        ) T2
        
        WHERE T1.VEHICLE_ID(+)=T2.VEHICLE_ID --������� �� Ȯ���� ���� ������ �� �ֵ��� WHERE�� ����.
        ORDER BY T2.VEHICLE_ID
        ;
        
        ELSE
        
            NULL;
            
        END IF;
    END PROC_SEL_CON;
    --�Ű������� �޾ƿͼ� ��¥��/������/������ܺ� Ȯ���� �߻��� �˻��ϴ� ���ν��� ����
    
    --11. ��¥�� Ȯ���� �߻� ���� Ȱ���Ͽ� ���� ��� Ȯ���� ���� ���� �����ִ� ���ν��� ����
    PROCEDURE PROC_SEL_CON_PLUS(
         O_CUR       OUT         SYS_REFCURSOR
    )AS
    BEGIN
        OPEN O_CUR FOR
    
            --���ں� Ȯ���� ���� �� ���ϱ�
            --5�� ��ü ��¥�� Ȯ���� �߻� ��
            SELECT TT2.MDATE, TT2.CON_CNT AS TODAY_CON, DECODE(TT2.CON_CNT-TT1.CON_CNT,NULL,'-',TT2.CON_CNT-TT1.CON_CNT) AS TODAY_INCREASE
            FROM
                (
                SELECT T2.MDATE, NVL(T1.CNT,0) AS CON_CNT
                FROM
                    (
                    SELECT CON_DATE, COUNT(*) AS CNT
                    FROM CONTAGION_TBL
                    GROUP BY CON_DATE
                    ) T1,
                    (
                    SELECT TRUNC(SYSDATE,'MM') + (LEVEL-1) AS MDATE
                    FROM DUAL
                    CONNECT BY LEVEL <= 31
                    ) T2
                WHERE T1.CON_DATE(+)=T2.MDATE
                ORDER BY T2.MDATE
                ) TT1,
                -- TT1 ���� �� Ȯ���� ��
                
                (
                SELECT T2.MDATE, NVL(T1.CNT,0) AS CON_CNT
                FROM
                    (
                    SELECT CON_DATE, COUNT(*) AS CNT
                    FROM CONTAGION_TBL
                    GROUP BY CON_DATE
                    ) T1,
                    (
                    SELECT TRUNC(SYSDATE,'MM') + (LEVEL-1) AS MDATE
                    FROM DUAL
                    CONNECT BY LEVEL <= 31
                    ) T2
                WHERE T1.CON_DATE(+)=T2.MDATE
                ORDER BY T2.MDATE
                ) TT2 --TT2�� ���ں� Ȯ���� ��
                
            WHERE TT1.MDATE(+) = TT2.MDATE -1 
            /*
            ���� ���� �� Ȯ���� �� ����� JOIN�� �� ������ ��¥�� -1 �Ͽ� �Ϸ� �� ��¥�� ���ٴ� ������ �־�
            ���ϰ� ���� �����͸� �� ROW�� �����ͼ� Ȯ���� ���� ������ ������ �� �ְ� �Ͽ���.
            */
            ;
    END PROC_SEL_CON_PLUS;
    --��¥�� Ȯ���� �߻� ���� Ȱ���Ͽ� ���� ��� Ȯ���� ���� ���� �����ִ� ���ν��� ����
    
    --12.�˻� ���̺��� �˻��� ����� ��¥���� �˻� ���, Ȯ�� ��� �����͸� �����ͼ� ��¥�� Ȯ���� ���ϴ� ���ν��� ����
    PROCEDURE PROC_SEL_CON_RATE(
        IN_CHK_DATE     IN      VARCHAR2,
        O_CUR           OUT     SYS_REFCURSOR
    )AS
    BEGIN
         
    OPEN O_CUR FOR
    
        SELECT TT2.MDATE, NVL(TT1.CON_RATE,0)||'%' AS CON_RATE
        FROM
            (
            SELECT T1.CHK_DATE,ROUND((CNT_CON / CNT_CHK_UP) * 100 , 2) AS CON_RATE
            FROM
                (
                SELECT CHK_DATE,COUNT(*) AS CNT_CHK_UP--5.3���� �˻� ��
                FROM CHECK_UP_TBL
                --WHERE CHK_DATE=IN_CHK_DATE ��¥ �Ű������� ������ �� Ư���� �Ϸ��� Ȯ������ �� �� �ִ�.
                GROUP BY CHK_DATE
                ) T1, --��¥�� �� �˻� ��
                
                (
                SELECT CHK_DATE,COUNT(*) AS CNT_CON
                FROM CHECK_UP_TBL
                WHERE C_YN='Y'
                --AND CHK_DATE=IN_CHK_DATE
                GROUP BY CHK_DATE
                ) T2 --��¥�� �� Ȯ�� ��
                
            WHERE T1.CHK_DATE=T2.CHK_DATE
            ) TT1,
            (
            SELECT TRUNC(SYSDATE,'MM') + (LEVEL-1) AS MDATE
            FROM DUAL
            CONNECT BY LEVEL <= 31
            )TT2 --SYSDATE, LEVEL�� Ȱ���ؼ� �� ���� ��¥�� ��� ��ȸ
        WHERE TT1.CHK_DATE(+)=TT2.MDATE
        ORDER BY TT2.MDATE
        ;
    END PROC_SEL_CON_RATE;
    -- �˻� ���̺��� �˻��� ����� ��¥���� �˻� ���, Ȯ�� ��� �����͸� �����ͼ� ��¥�� Ȯ���� ���ϴ� ���ν��� ����
    
    --13.  Ȯ���ڰ� �߻��� �ǹ� ��� �߿��� ������ġ �̻� Ȯ���ڰ� �߻��� �ǹ��� ���� ���� �߻����� �����ϰ�, ���� ���� �߻����� �˻��� �� �ִ� ���ν��� ����
    PROCEDURE PROC_SEL_INFECTION_BUILDINGS(
        O_CUR       OUT     SYS_REFCURSOR
    )AS 
    BEGIN
         /*
    ���� ���� �߻��� ���ϱ�(���� ���� �߻� 3�� �̻��� ���� ������)
    ��ĥ ���� �߻��ߴ����� �������� �ʾ���.
    */
    
    OPEN O_CUR  FOR
    
    SELECT B_ID, B_NAME, CNT
    FROM
    (
    SELECT E.B_ID,E.B_NAME, COUNT(*) AS CNT
    FROM CONTAGION_TBL A, CHECK_UP_TBL B, SEND_MSG_TBL C, VISIT_TBL D, BUILDING_TBL E
    WHERE A.CHK_ID=B.CHK_ID AND B.SM_ID=C.SM_ID AND C.VISIT_ID=D.VISIT_ID AND D.B_ID=E.B_ID
    GROUP BY E.B_ID,E.B_NAME
    )
    WHERE CNT>=3
    ;

    END PROC_SEL_INFECTION_BUILDINGS;
    --Ȯ���ڰ� �߻��� �ǹ� ��� �߿��� ������ġ �̻� Ȯ���ڰ� �߻��� �ǹ��� ���� ���� �߻����� �����ϰ�, ���� ���� �߻����� �˻��� �� �ִ� ���ν��� ����
    
    
    --14. Ȯ���ڿ� �����Ͽ� �ڷγ� �˻� ��� ���������� ���� �˻���� ��� ���̺� ������� ���� ����� �˻��ϴ� ���ν��� ����
    PROCEDURE PROC_SEL_NOT_CHK(
        O_CUR       OUT     SYS_REFCURSOR
    )AS
    BEGIN
        --1.	�˻� �޾ƾ� �ϴµ� �� ���� ��� ã��
        OPEN O_CUR  FOR
        SELECT  T1.*, T2.A_VAL1||' '|| T2.A_VAL2||' '|| T2.A_VAL3 AS A_VAL
            FROM
            (
            SELECT D.P_ID, D.P_NAME, D.P_GENDER, D.P_TEL, D.P_BIRTH, D.P_ADD
            FROM SEND_MSG_TBL A, CHECK_UP_TBL B, GET_IN_TBL C, PEOPLE_TBL D
            WHERE A.SM_ID=B.SM_ID(+) AND C.GET_IN_ID=A.GET_IN_ID AND D.P_ID=C.P_ID AND B.CHK_ID IS NULL
            ORDER BY A.SM_ID
            ) T1, --��������� ���ļ� �˻縦 �޾ƾ� �ϴ� ��� �� ���� �˻縦 ���� ���� ����� OUTER JOIN���� �Ѳ����� JOIN.
                  --B.CHK_ID�� NULL�� �����͸� ã�ƿͼ� �˻� �޾ƾ� �ϴ� ��������� �˻� ���̺� �������� �ʴ� ��� �����͸� �����ش�.
            
            (
            SELECT C.A_ID, A.A_VAL AS A_VAL1, B.A_VAL AS A_VAL2, C.A_VAL AS A_VAL3, A.GROUP_ID, C.A_PARENT_ID
            FROM ADDRESS_TBL A, ADDRESS_TBL B, ADDRESS_TBL C
            WHERE A.A_ID(+)=B.A_PARENT_ID AND B.A_ID(+)=C.A_PARENT_ID
            ORDER BY C.A_ID
            ) T2 --�ּ� ���̺� ���������� �̷���������Ƿ� SELF JOIN �� OUTER JOIN���� ó������ �� �������� �ѹ��� ������ �� �ֵ��� �ۼ�.
            
        WHERE T1.P_ADD = T2.A_ID
    
        UNION ALL--������ϰ� �湮��� �� ���� ��츦 ���� ���Ͽ� �ѹ��� ������� �ؼ� UNION ALL ���
    
        SELECT  T1.*, T2.A_VAL1||' '|| T2.A_VAL2||' '|| T2.A_VAL3 AS A_VAL
        FROM
            (
            SELECT D.P_ID, D.P_NAME, D.P_GENDER, D.P_TEL, D.P_BIRTH, D.P_ADD
            FROM SEND_MSG_TBL A, CHECK_UP_TBL B, VISIT_TBL C, PEOPLE_TBL D
            WHERE A.SM_ID=B.SM_ID(+) AND C.VISIT_ID=A.VISIT_ID AND D.P_ID=C.P_ID AND B.CHK_ID IS NULL
            ORDER BY A.SM_ID
            ) T1,  --�湮����� ���ļ� �˻縦 �޾ƾ� �ϴ� ��� �� ���� �˻縦 ���� ���� ����� OUTER JOIN���� �Ѳ����� JOIN.
                  --B.CHK_ID�� NULL�� �����͸� ã�ƿͼ� �˻� �޾ƾ� �ϴ� ��������� �˻� ���̺� �������� �ʴ� ��� �����͸� �����ش�.
                  
            (
            SELECT C.A_ID, A.A_VAL AS A_VAL1, B.A_VAL AS A_VAL2, C.A_VAL AS A_VAL3, A.GROUP_ID, C.A_PARENT_ID
            FROM ADDRESS_TBL A, ADDRESS_TBL B, ADDRESS_TBL C
            WHERE A.A_ID(+)=B.A_PARENT_ID AND B.A_ID(+)=C.A_PARENT_ID
            ORDER BY C.A_ID
            ) T2
            
        WHERE T1.P_ADD = T2.A_ID
        ;
  
    END PROC_SEL_NOT_CHK;
    --Ȯ���ڿ� �����Ͽ� �ڷγ� �˻� ��� ���������� ���� �˻���� ��� ���̺� ������� ���� ����� �˻��ϴ� ���ν��� ����
END PKG_PROCESS;