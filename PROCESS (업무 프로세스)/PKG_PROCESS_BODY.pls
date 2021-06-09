create or replace NONEDITIONABLE PACKAGE BODY PKG_PROCESS AS

    -- 1. 확진자와 밀접접촉자 찾은 다음 문자발송 테이블에 INSERT하는 프로시저 시작
    PROCEDURE PROC_INS_CONTACT_CONTAGION(
        IN_CON_ID         IN          VARCHAR2 
    )AS
        V_VISIT_ID          CHAR(7);
    BEGIN
        SELECT VISIT_ID
        INTO V_VISIT_ID
        FROM CONTAGION_TBL T1, CHECK_UP_TBL T2,SEND_MSG_TBL T3
        WHERE T1.CHK_ID = T2.CHK_ID AND T2.SM_ID = T3.SM_ID AND T1.CON_ID = IN_CON_ID;      --SEND_MSG_TBL에서 VISIT_ID가 NULL인지
        
        IF V_VISIT_ID IS NULL THEN
            
                
                INSERT INTO SEND_MSG_TBL
                SELECT 'SM' || TO_CHAR((SELECT TO_NUMBER(SUBSTR(NVL(MAX(SM_ID), 'SM00000'), 3)) FROM SEND_MSG_TBL) + ROW_NUMBER() OVER(ORDER BY SYSDATE), 'FM00000')
                    AS SM_ID,NULL,'MSG02',DD,GET_IN_ID           -- 확진자와 같은 승차기록이 있는 사람을 문자발송 테이블에 INSERT
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
                            WHERE A.T_ID = B.T_ID AND D = TO_CHAR(B.CHECK_IN,'YYYYMMDD')  -- 확진자와 같은 날짜와 같은 운송수단에 있었던 사람들 찾는 조건문
                        )
                    WHERE ((BCHECK_IN <= ACHECK_IN AND BCHECK_OUT >= ACHECK_OUT) OR    -- 같은날짜와 같은 운송수단에 있었던 사람들 중 같은 시간대에 있었던 사람들 찾기
                                                                        ((BCHECK_IN <= ACHECK_IN AND ACHECK_IN < BCHECK_OUT) AND (ACHECK_IN < BCHECK_OUT AND BCHECK_OUT <= ACHECK_OUT)) OR
                                                                        ((ACHECK_IN <= BCHECK_IN AND BCHECK_IN < ACHECK_OUT) AND (BCHECK_IN < ACHECK_OUT AND ACHECK_OUT <= BCHECK_OUT)) OR 
                                                                        (ACHECK_IN <= BCHECK_IN AND BCHECK_OUT <= ACHECK_OUT))  AND CON_ID1 != TLT_PID );
            
            
        ELSE
            
                INSERT INTO SEND_MSG_TBL
                SELECT  'SM' || TO_CHAR((SELECT TO_NUMBER(SUBSTR(NVL(MAX(SM_ID), 'SM00000'), 3)) FROM SEND_MSG_TBL) + ROW_NUMBER() OVER(ORDER BY DD), 'FM00000')
                        AS SM_ID ,VISIT_ID,'MSG02',DD,NULL   -- 확진자와 같은 승차기록이 있는 사람을 문자발송 테이블에 INSERT
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
                            WHERE A.B_ID = B.B_ID AND D = TO_CHAR(B.CHECK_IN,'YYYYMMDD')  -- 확진자와 같은 날짜와 같은건물에 있었던 사람들 찾는 조건문
                        )
                    WHERE ((BCHECK_IN <= ACHECK_IN AND BCHECK_OUT >= ACHECK_OUT) OR   -- 같은날짜와 같은 건물에 있었던 사람들 중 같은 시간대에 있었던 사람들 찾기
                                                                        ((BCHECK_IN <= ACHECK_IN AND ACHECK_IN < BCHECK_OUT) AND (ACHECK_IN < BCHECK_OUT AND BCHECK_OUT <= ACHECK_OUT)) OR
                                                                        ((ACHECK_IN <= BCHECK_IN AND BCHECK_IN < ACHECK_OUT) AND (BCHECK_IN < ACHECK_OUT AND ACHECK_OUT <= BCHECK_OUT)) OR 
                                                                        (ACHECK_IN <= BCHECK_IN AND BCHECK_OUT <= ACHECK_OUT))  AND CON_ID != TLT_PID )
                
             ;
        END IF;
    END PROC_INS_CONTACT_CONTAGION;
    --확진자와 밀접접촉자 찾은 다음 문자발송 테이블에 INSERT하는 프로시저 종료
    
    
    -- 2. 확진자가 돌아다닌 동선 찾아내는 프로시저 시작
    
    PROCEDURE PROC_FIND_PLACE(
        O_CUR            OUT            SYS_REFCURSOR 
    )AS
    BEGIN
        OPEN O_CUR FOR
    -----------------------------------------------------------------------------------확진자의 방문기록
        SELECT *
        FROM (
            SELECT A.P_ID,ADDR || ' '|| B.B_NAME AS PLACE, TO_CHAR(A.CHECK_IN,'YYYY/MM/DD HH24:MI:SS') AS IN_TIME,TO_CHAR(A.CHECK_OUT,'YYYY/MM/DD HH24:MI:SS') AS OUT_TIME
        FROM (
            SELECT P_ID,B_ID,CHECK_IN,CHECK_OUT         --확진자가 방문했던 건물과 체크인,체크아웃 시간
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
                WHERE T1.A_ID(+) = T2.A_PARENT_ID AND T2.A_ID(+) = T3.A_PARENT_ID       --계층형으로 되었있는 주소를 한줄로 나타내기 위한 쿼리
            ) C
            WHERE A.B_ID = B.B_ID AND B.B_ADD = C.A_ID
            --------------------------------------------------------------------------------확진자의 방문기록
            UNION
            --------------------------------------------------------------------------------확진자의 승차기록
            SELECT A.P_ID,C.VEHICLE_NAME AS PLACE, TO_CHAR(A.CHECK_IN,'YYYY/MM/DD HH24:MI:SS') AS IN_TIME,TO_CHAR(A.CHECK_OUT,'YYYY/MM/DD HH24:MI:SS') AS OUT_TIME
            FROM (
                SELECT P_ID,T_ID,CHECK_IN,CHECK_OUT                 --확진자가 탑승했던 운송수단과 승차시간,하차시간
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
        
            --------------------------------------------------------------------------------확진자의 승차기록
    END PROC_FIND_PLACE;
    
    --확진자가 돌아다닌 동선 찾아내는 프로시저 종료
    
    
    --3. 최초확진자와 접촉한 사람 동선 찾아 문자발송 테이블에 INSERT하는 프로시져 시작
    PROCEDURE PROC_FIRST_CONTAGION(
        IN_CON_ID           IN              VARCHAR2
    )AS
    BEGIN
            INSERT INTO SEND_MSG_TBL
            SELECT  'SM' || TO_CHAR((SELECT TO_NUMBER(SUBSTR(NVL(MAX(SM_ID), 'SM00000'), 3)) FROM SEND_MSG_TBL) + ROW_NUMBER() OVER(ORDER BY DD), 'FM00000')
                    AS SM_ID ,VISIT_ID,'MSG02',DD,NULL                  --방문기록에서 확진자와 같은 건물에 있던 사람을 문자발송 테이블에 INSERT
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
                        WHERE A.B_ID = B.B_ID AND D = TO_CHAR(B.CHECK_IN,'YYYYMMDD') -- 확진자와 같은 날짜와 같은건물에 있었던 사람들 찾는 조건문
                    )
                WHERE ((BCHECK_IN <= ACHECK_IN AND BCHECK_OUT >= ACHECK_OUT) OR          -- 같은날짜와 같은 건물에 있었던 사람들 중 같은 시간대에 있었던 사람들 찾기
                                                                    ((BCHECK_IN <= ACHECK_IN AND ACHECK_IN < BCHECK_OUT) AND (ACHECK_IN < BCHECK_OUT AND BCHECK_OUT <= ACHECK_OUT)) OR
                                                                    ((ACHECK_IN <= BCHECK_IN AND BCHECK_IN < ACHECK_OUT) AND (BCHECK_IN < ACHECK_OUT AND ACHECK_OUT <= BCHECK_OUT)) OR 
                                                                    (ACHECK_IN <= BCHECK_IN AND BCHECK_OUT <= ACHECK_OUT))  AND CON_ID != TLT_PID );
        -----------------------------------------------------------------------------건물 종료    
        
        -----------------------------------------------------------------------------승차 시작
        INSERT INTO SEND_MSG_TBL(SM_ID,VISIT_ID,MSG_ID,SM_DATE,GET_IN_ID)
        SELECT 'SM' || TO_CHAR((SELECT TO_NUMBER(SUBSTR(NVL(MAX(SM_ID), 'SM00000'), 3)) FROM SEND_MSG_TBL) + ROW_NUMBER() OVER(ORDER BY SYSDATE), 'FM00000')
                AS SM_ID,NULL,'MSG02',BCHECK_OUT + 1,GET_IN_ID      -- 확진자와 같은 승차기록이 있는 사람을 문자발송 테이블에 INSERT
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
                 WHERE A.T_ID = B.T_ID AND D1 = TO_CHAR(B.CHECK_IN,'YYYYMMDD') -- 확진자와 같은 날짜와 같은 운송수단에 있었던 사람들 찾는 조건문
            )
        WHERE ((BCHECK_IN <= ACHECK_IN AND BCHECK_OUT >= ACHECK_OUT) OR         -- 같은날짜와 같은 운송수단에 있었던 사람들 중 같은 시간대에 있었던 사람들 찾기
                                                                    ((BCHECK_IN <= ACHECK_IN AND ACHECK_IN < BCHECK_OUT) AND (ACHECK_IN < BCHECK_OUT AND BCHECK_OUT <= ACHECK_OUT)) OR
                                                                    ((ACHECK_IN <= BCHECK_IN AND BCHECK_IN < ACHECK_OUT) AND (BCHECK_IN < ACHECK_OUT AND ACHECK_OUT <= BCHECK_OUT)) OR 
                                                                    (ACHECK_IN <= BCHECK_IN AND BCHECK_OUT <= ACHECK_OUT))  AND CON_ID1 != TLT_ID 
        ;
    END PROC_FIRST_CONTAGION;
    -- 최초확진자와 접촉한 사람 동선 찾아 문자발송 테이블에 INSERT하는 프로시져 종료
    
    
    --4. 성별 기준 확진자 수 찾아내는 프로시저 시작
    PROCEDURE PROC_GENDER(
        O_CUR          OUT             SYS_REFCURSOR
    )AS
    BEGIN
         OPEN O_CUR FOR
         SELECT DECODE(P_GENDER,'F','여성','남성') AS GENDER ,COUNT(*) AS CNT       --사람들의 성별과 숫자 구하기
         FROM (
                SELECT T5.*                                 --감염된 사람의 승차기록
                FROM CONTAGION_TBL T1, CHECK_UP_TBL T2, SEND_MSG_TBL T3,GET_IN_TBL T4,PEOPLE_TBL T5
                WHERE T1.CHK_ID = T2.CHK_ID AND T2.SM_ID = T3.SM_ID AND T3.VISIT_ID IS NULL AND T3.GET_IN_ID = T4.GET_IN_ID AND T4.P_ID = T5.P_ID 
                
                UNION
                
                SELECT T5.*                                 --감염된 사람의 방문기록
                FROM CONTAGION_TBL T1, CHECK_UP_TBL T2, SEND_MSG_TBL T3,VISIT_TBL T4,PEOPLE_TBL T5
                WHERE T1.CHK_ID = T2.CHK_ID AND T2.SM_ID = T3.SM_ID AND T3.GET_IN_ID IS NULL AND T3.VISIT_ID = T4.VISIT_ID AND T4.P_ID = T5.P_ID 
             )
         GROUP BY P_GENDER;
    END PROC_GENDER;
    --성별 기준 확진자 수 찾아내는 프로시저 종료
    
    
    --5. 동선이 가장 많은 사람 찾아내는 프로시저 시작
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
    -- 동선이 가장 많은 사람 찾아내는 프로시저 종료
    
    
    --6. 자가격리자 찾아내는 프로시저 시작
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
                    )A1,--건물 관련 자가격리자 
                    (
                        SELECT T3.A_ID,T1.A_VAL AS SI, T2.A_VAL AS GU, T3.A_VAL AS DONG
                        FROM ADDRESS_TBL T1 , ADDRESS_TBL T2, ADDRESS_TBL T3
                        WHERE T1.A_ID = T2.A_PARENT_ID
                        AND T2.A_ID = T3.A_PARENT_ID
                    )A2--주소 계층쿼리
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
                    )A1,--교통수단 관련 자가격리자 
                    (
                        SELECT T3.A_ID,T1.A_VAL AS SI, T2.A_VAL AS GU, T3.A_VAL AS DONG
                        FROM ADDRESS_TBL T1 , ADDRESS_TBL T2, ADDRESS_TBL T3
                        WHERE T1.A_ID = T2.A_PARENT_ID
                        AND T2.A_ID = T3.A_PARENT_ID
                    )A2--주소 계층쿼리
                    WHERE A1.P_ADD = A2.A_ID
                    ;
    END PROC_SELF_ISOLATION_LIST;
    -- 자가격리자 찾아내는 프로시저 종료
    
    
    --7. 확진자 평균 나이 구하는 프로시저 시작
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
    --확진자 평균 나이 구하는 프로시저 종료
    
    --8. 확진자가 방문지별 머문 시간구하는 프로시저 시작
    PROCEDURE PROC_CON_STAY_TIME(
        O_CUR           OUT           SYS_REFCURSOR
    )AS
    BEGIN
        OPEN O_CUR FOR
            SELECT A.P_ID, A.P_NAME,A.NEW_NAME,A.AL_BTID,
                  ((TO_CHAR(A_OUT,'HH24')* 60 + TO_CHAR(A_OUT,'MI')+TO_CHAR(A_OUT,'SS')*1/60) - (TO_CHAR(A_IN,'HH24')* 60 + TO_CHAR(A_IN,'MI')+TO_CHAR(A_IN,'SS')*1/60))/60 AS STAR_TIME
                --(체크아웃시간) - (체크인시간)으로 확진자가 머무른 시간 계산
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
                  --확진자의 구체적인 방문 기록
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
                --확진자의 구체적인 교통수단 탑승 기록
              )A
            ;

    END PROC_CON_STAY_TIME;
    --확진자가 방문지별 머문 시간구하는 프로시저 종료
    
    
    --9. 코로나 검사를 받았지만 결과가 음성인 사람들 구하는 프로시저 시작
    PROCEDURE PROC_SEL_CHECK_UP_N(
        O_CUR       OUT     SYS_REFCURSOR
    )AS
    BEGIN
         --2.	검사결과가 음성인 사람 찾기
        OPEN O_CUR FOR
        
        SELECT T1.*, T2.A_VAL1||' '|| T2.A_VAL2||' '|| T2.A_VAL3 AS A_VAL 
        FROM
            (
            SELECT D.P_ID, D.P_NAME, D.P_GENDER, D.P_TEL, D.P_BIRTH, D.P_ADD
            FROM CHECK_UP_TBL A, SEND_MSG_TBL B, VISIT_TBL C, PEOPLE_TBL D
            WHERE A.C_YN='N' AND B.SM_ID=A.SM_ID AND C.VISIT_ID=B.VISIT_ID AND D.P_ID=C.P_ID
            ) T1, --음성 결과가 나온 사람 데이터를 보여주기 위해서 C_YN='N'이면서 검사를 받은 사람의 신상 정보를 보여주기 위해서 PEOPEL_TBL까지 JOIN활용
                  --데이터가 VISIT_TBL과 GET_IN_TBL 각각의 테이블에 들어있기 때문에 각각을 구하여 UNION으로 한번에 SELECT한다.
            (
            SELECT C.A_ID, A.A_VAL AS A_VAL1, B.A_VAL AS A_VAL2, C.A_VAL AS A_VAL3, A.GROUP_ID, C.A_PARENT_ID
            FROM ADDRESS_TBL A, ADDRESS_TBL B, ADDRESS_TBL C
            WHERE A.A_ID(+)=B.A_PARENT_ID AND B.A_ID(+)=C.A_PARENT_ID
            ORDER BY C.A_ID
            ) T2 --주소 테이블 계층형으로 이루어져있으므로 SELF JOIN 과 OUTER JOIN으로 처음부터 끝 레벨까지 한번에 보여줄 수 있도록 작성.
        WHERE T1.P_ADD=T2.A_ID
        
        UNION ALL   --승차기록과 방문기록 두 가지 경우를 각각 구하여 한번에 보여주기 위해 UNION ALL 사용
        
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
    -- 코로나 검사를 받았지만 겨로가가 음성인 사람들 구하는 프로시저 종료
    
    --10. 매개변수를 받아와서 날짜별/지역별/교통수단별 확진자 발생수 검색하는 프로시저 시작
    PROCEDURE PROC_SEL_CON(
        O_CUR   OUT     SYS_REFCURSOR,
        IN_CLICK    IN      VARCHAR2
    )AS
    BEGIN
         /* 
    날짜별 보고싶으면 'DATE' 입력, 지역별 보고싶으면 'ADDRESS' 입력, 교통수단별 보고싶으면 'VEHICLE' 입력
    현재 날짜는 SYSDATE 로 그 달만 나오게 돼있음 
    */
    
        IF IN_CLICK = 'DATE' THEN
        OPEN O_CUR FOR
        --5월 전체 날짜별 확진자 발생 수
        SELECT T2.MDATE, NVL(T1.CNT,0) AS CON_CNT
        FROM
            (
            SELECT CON_DATE, COUNT(*) AS CNT
            FROM CONTAGION_TBL
            GROUP BY CON_DATE
            ) T1, --확진자 테이블에서 날짜별 확진자 수를 GROUP BY로 SELECT 한다.
            (
            SELECT TRUNC(SYSDATE,'MM') + (LEVEL-1) AS MDATE
            FROM DUAL
            CONNECT BY LEVEL <= 31
            ) T2 --SYSDATE와 LEVEL을 활용하여 그 달의 날짜를 모두 SELECT한다.
        WHERE T1.CON_DATE(+)=T2.MDATE --OUTER JOIN을 활용하여 매일매일 확진자수를 보여줄 수 있도록 한다.
        ORDER BY T2.MDATE ;
        
        
         --지역별 확진자 수
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
                    ) T1, --방문기록이 존재하여 검사받게된 검사 결과가 확진자 테이블에 존재하는 확진ID를 가진 사람을 SELECT.
                    
                    (
                   SELECT C.A_ID, A.A_VAL AS A_VAL1, B.A_VAL AS A_VAL2, C.A_VAL AS A_VAL3, A.GROUP_ID, C.A_PARENT_ID
                    FROM ADDRESS_TBL A, ADDRESS_TBL B, ADDRESS_TBL C
                    WHERE A.A_ID(+)=B.A_PARENT_ID AND B.A_ID(+)=C.A_PARENT_ID
                    ORDER BY C.A_ID
                    ) T2 --주소 테이블을 SELF JOIN해서 주소를 끝 레벨까지 보여준다.
                    
                WHERE T1.P_ADD=T2.A_ID
                GROUP BY A_VAL1||' '||A_VAL2||' '||A_VAL3 --같은 주소에 존재하는 확진자끼리 GROUP BY 하여 COUNT를 구함.
                
        UNION ALL --VISIT과 GET_IN 양쪽으로 관계가 이루어져 있기때문에 각 경우를 구해서 UNION.
        
                SELECT A_VAL1||' '||A_VAL2||' '||A_VAL3 AS A_VAL, COUNT(*) AS CON_CNT
                FROM
                    (
                    SELECT D.P_ID, D.P_NAME, D.P_GENDER, D.P_TEL, D.P_BIRTH, D.P_ADD
                    FROM CHECK_UP_TBL A, SEND_MSG_TBL B, GET_IN_TBL C, PEOPLE_TBL D, CONTAGION_TBL E
                    WHERE E.CHK_ID=A.CHK_ID AND B.SM_ID=A.SM_ID AND C.GET_IN_ID=B.GET_IN_ID AND D.P_ID=C.P_ID
                    ) T1, --승차기록이 존재하여 검사받게된 검사 결과가 확진자 테이블에 존재하는 확진ID를 가진 사람을 SELECT.
                    
                    (
                   SELECT C.A_ID, A.A_VAL AS A_VAL1, B.A_VAL AS A_VAL2, C.A_VAL AS A_VAL3, A.GROUP_ID, C.A_PARENT_ID
                    FROM ADDRESS_TBL A, ADDRESS_TBL B, ADDRESS_TBL C
                    WHERE A.A_ID(+)=B.A_PARENT_ID AND B.A_ID(+)=C.A_PARENT_ID
                    ORDER BY C.A_ID
                    ) T2 --주소 테이블을 SELF JOIN해서 주소를 끝 레벨까지 보여준다.
                    
                WHERE T1.P_ADD=T2.A_ID
                GROUP BY A_VAL1||' '||A_VAL2||' '||A_VAL3
                )
        ) TT1, --각 주소별로 확진자들이 존재하는 숫자를 나타낸다.
        
        (
            SELECT A.A_VAL||' '||B.A_VAL||' '||C.A_VAL AS A_VAL
            FROM ADDRESS_TBL A, ADDRESS_TBL B, ADDRESS_TBL C
            WHERE A.A_ID(+)=B.A_PARENT_ID AND B.A_ID(+)=C.A_PARENT_ID AND C.A_LVL=3
            ORDER BY C.A_ID
        ) TT2 --모든 주소를 나타낸다.
        
        WHERE TT1.A_VAL(+)=TT2.A_VAL 
        --OUTER JOIN을 통해서 확진자가 존재하지 않아 NULL인 주소도 모두 보여주므로 NULL인 경우 NVL을 통해 0으로 만들어준다
        ;
        
        ELSIF IN_CLICK='VEHICLE' THEN
        
        OPEN O_CUR FOR
       
        --교통 수단별 확진자 수
        SELECT T2.VEHICLE_ID, T2.VEHICLE_NAME, NVL(T1.CNT,0) AS CNT
        FROM
        (
        SELECT F.VEHICLE_ID, F.VEHICLE_NAME, COUNT(*) AS CNT
        FROM CONTAGION_TBL A, CHECK_UP_TBL B, SEND_MSG_TBL C, GET_IN_TBL D, TIME_TBL E, VEHICLE_TBL F
        WHERE A.CHK_ID=B.CHK_ID AND B.SM_ID=C.SM_ID AND C.GET_IN_ID=D.GET_IN_ID AND D.T_ID=E.T_ID AND E.VEHICLE_ID=F.VEHICLE_ID
        GROUP BY F.VEHICLE_ID, F.VEHICLE_NAME
        ) T1, --JOIN을 통해서 승차 기록이 있는 확진자들이 어떤 교통수단을 이용했는지 교통수단 별로 COUNT 한다.
        (
        SELECT VEHICLE_ID, VEHICLE_NAME
        FROM VEHICLE_TBL
        ) T2
        
        WHERE T1.VEHICLE_ID(+)=T2.VEHICLE_ID --교통수단 별 확진자 수를 보여줄 수 있도록 WHERE절 조건.
        ORDER BY T2.VEHICLE_ID
        ;
        
        ELSE
        
            NULL;
            
        END IF;
    END PROC_SEL_CON;
    --매개변수를 받아와서 날짜별/지역별/교통수단별 확진자 발생수 검색하는 프로시저 종료
    
    --11. 날짜별 확진자 발생 수를 활용하여 전일 대비 확진자 증감 수를 보여주는 프로시저 시작
    PROCEDURE PROC_SEL_CON_PLUS(
         O_CUR       OUT         SYS_REFCURSOR
    )AS
    BEGIN
        OPEN O_CUR FOR
    
            --일자별 확진자 증가 폭 구하기
            --5월 전체 날짜별 확진자 발생 수
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
                -- TT1 일자 별 확진자 수
                
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
                ) TT2 --TT2도 일자별 확진자 수
                
            WHERE TT1.MDATE(+) = TT2.MDATE -1 
            /*
            같은 일자 별 확진자 수 결과를 JOIN할 때 한쪽의 날짜를 -1 하여 하루 전 날짜와 같다는 조건을 주어
            당일과 전날 데이터를 한 ROW에 가져와서 확진자 수의 증감을 보여줄 수 있게 하였음.
            */
            ;
    END PROC_SEL_CON_PLUS;
    --날짜별 확진자 발생 수를 활용하여 전일 대비 확진자 증감 수를 보여주는 프로시저 종료
    
    --12.검사 테이블에서 검사한 결과를 날짜별로 검사 몇건, 확진 몇건 데이터를 가져와서 날짜별 확진률 구하는 프로시저 시작
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
                SELECT CHK_DATE,COUNT(*) AS CNT_CHK_UP--5.3일의 검사 수
                FROM CHECK_UP_TBL
                --WHERE CHK_DATE=IN_CHK_DATE 날짜 매개변수를 적용할 시 특정일 하루의 확진률을 볼 수 있다.
                GROUP BY CHK_DATE
                ) T1, --날짜별 총 검사 수
                
                (
                SELECT CHK_DATE,COUNT(*) AS CNT_CON
                FROM CHECK_UP_TBL
                WHERE C_YN='Y'
                --AND CHK_DATE=IN_CHK_DATE
                GROUP BY CHK_DATE
                ) T2 --날짜별 총 확진 수
                
            WHERE T1.CHK_DATE=T2.CHK_DATE
            ) TT1,
            (
            SELECT TRUNC(SYSDATE,'MM') + (LEVEL-1) AS MDATE
            FROM DUAL
            CONNECT BY LEVEL <= 31
            )TT2 --SYSDATE, LEVEL을 활용해서 그 달의 날짜를 모두 조회
        WHERE TT1.CHK_DATE(+)=TT2.MDATE
        ORDER BY TT2.MDATE
        ;
    END PROC_SEL_CON_RATE;
    -- 검사 테이블에서 검사한 결과를 날짜별로 검사 몇건, 확진 몇건 데이터를 가져와서 날짜별 확진률 구하는 프로시저 종료
    
    --13.  확진자가 발생한 건물 명단 중에서 일정수치 이상 확진자가 발생한 건물은 집단 감염 발생지로 지정하고, 집단 감염 발생지를 검색할 수 있는 프로시저 시작
    PROCEDURE PROC_SEL_INFECTION_BUILDINGS(
        O_CUR       OUT     SYS_REFCURSOR
    )AS 
    BEGIN
         /*
    집단 감염 발생지 구하기(현재 감염 발생 3명 이상인 경우로 정의함)
    며칠 내로 발생했는지는 정의하지 않았음.
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
    --확진자가 발생한 건물 명단 중에서 일정수치 이상 확진자가 발생한 건물은 집단 감염 발생지로 지정하고, 집단 감염 발생지를 검색할 수 있는 프로시저 종료
    
    
    --14. 확진자와 접촉하여 코로나 검사 대상에 지정됐지만 현재 검사받은 사람 테이블에 들어있지 않은 사람을 검색하는 프로시저 시작
    PROCEDURE PROC_SEL_NOT_CHK(
        O_CUR       OUT     SYS_REFCURSOR
    )AS
    BEGIN
        --1.	검사 받아야 하는데 안 받은 사람 찾기
        OPEN O_CUR  FOR
        SELECT  T1.*, T2.A_VAL1||' '|| T2.A_VAL2||' '|| T2.A_VAL3 AS A_VAL
            FROM
            (
            SELECT D.P_ID, D.P_NAME, D.P_GENDER, D.P_TEL, D.P_BIRTH, D.P_ADD
            FROM SEND_MSG_TBL A, CHECK_UP_TBL B, GET_IN_TBL C, PEOPLE_TBL D
            WHERE A.SM_ID=B.SM_ID(+) AND C.GET_IN_ID=A.GET_IN_ID AND D.P_ID=C.P_ID AND B.CHK_ID IS NULL
            ORDER BY A.SM_ID
            ) T1, --승차기록이 겹쳐서 검사를 받아야 하는 사람 중 아직 검사를 받지 않은 사람을 OUTER JOIN으로 한꺼번에 JOIN.
                  --B.CHK_ID가 NULL인 데이터를 찾아와서 검사 받아야 하는 사람이지만 검사 테이블에 존재하지 않는 사람 데이터만 보여준다.
            
            (
            SELECT C.A_ID, A.A_VAL AS A_VAL1, B.A_VAL AS A_VAL2, C.A_VAL AS A_VAL3, A.GROUP_ID, C.A_PARENT_ID
            FROM ADDRESS_TBL A, ADDRESS_TBL B, ADDRESS_TBL C
            WHERE A.A_ID(+)=B.A_PARENT_ID AND B.A_ID(+)=C.A_PARENT_ID
            ORDER BY C.A_ID
            ) T2 --주소 테이블 계층형으로 이루어져있으므로 SELF JOIN 과 OUTER JOIN으로 처음부터 끝 레벨까지 한번에 보여줄 수 있도록 작성.
            
        WHERE T1.P_ADD = T2.A_ID
    
        UNION ALL--승차기록과 방문기록 두 가지 경우를 각각 구하여 한번에 보여줘야 해서 UNION ALL 사용
    
        SELECT  T1.*, T2.A_VAL1||' '|| T2.A_VAL2||' '|| T2.A_VAL3 AS A_VAL
        FROM
            (
            SELECT D.P_ID, D.P_NAME, D.P_GENDER, D.P_TEL, D.P_BIRTH, D.P_ADD
            FROM SEND_MSG_TBL A, CHECK_UP_TBL B, VISIT_TBL C, PEOPLE_TBL D
            WHERE A.SM_ID=B.SM_ID(+) AND C.VISIT_ID=A.VISIT_ID AND D.P_ID=C.P_ID AND B.CHK_ID IS NULL
            ORDER BY A.SM_ID
            ) T1,  --방문기록이 겹쳐서 검사를 받아야 하는 사람 중 아직 검사를 받지 않은 사람을 OUTER JOIN으로 한꺼번에 JOIN.
                  --B.CHK_ID가 NULL인 데이터를 찾아와서 검사 받아야 하는 사람이지만 검사 테이블에 존재하지 않는 사람 데이터만 보여준다.
                  
            (
            SELECT C.A_ID, A.A_VAL AS A_VAL1, B.A_VAL AS A_VAL2, C.A_VAL AS A_VAL3, A.GROUP_ID, C.A_PARENT_ID
            FROM ADDRESS_TBL A, ADDRESS_TBL B, ADDRESS_TBL C
            WHERE A.A_ID(+)=B.A_PARENT_ID AND B.A_ID(+)=C.A_PARENT_ID
            ORDER BY C.A_ID
            ) T2
            
        WHERE T1.P_ADD = T2.A_ID
        ;
  
    END PROC_SEL_NOT_CHK;
    --확진자와 접촉하여 코로나 검사 대상에 지정됐지만 현재 검사받은 사람 테이블에 들어있지 않은 사람을 검색하는 프로시저 종료
END PKG_PROCESS;