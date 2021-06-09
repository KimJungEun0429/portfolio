create or replace NONEDITIONABLE PACKAGE PKG_PROCESS AS 
    
    -- 1. 확진자와 밀접접촉자 찾은 다음 문자발송 테이블에 INSERT하는 프로시저 시작
    PROCEDURE PROC_INS_CONTACT_CONTAGION(
        IN_CON_ID         IN          VARCHAR2 
    );
    --확진자와 밀접접촉자 찾은 다음 문자발송 테이블에 INSERT하는 프로시저 종료
    
    -- 2. 확진자가 돌아다닌 동선 찾아내는 프로시저 시작
    PROCEDURE PROC_FIND_PLACE(
        O_CUR            OUT            SYS_REFCURSOR 
    );
    --확진자가 돌아다닌 동선 찾아내는 프로시저 종료
    
    --3. 최초확진자와 접촉한 사람 동선 찾아 문자발송 테이블에 INSERT하는 프로시져 시작
    PROCEDURE PROC_FIRST_CONTAGION(
        IN_CON_ID           IN              VARCHAR2
    );
    -- 최초확진자와 접촉한 사람 동선 찾아 문자발송 테이블에 INSERT하는 프로시져 종료
    
    --4. 성별 기준 확진자 수 찾아내는 프로시저 시작
    PROCEDURE PROC_GENDER(
        O_CUR          OUT             SYS_REFCURSOR
    );
    --성별 기준 확진자 수 찾아내는 프로시저 종료
    
    
    --5. 동선이 가장 많은 사람 찾아내는 프로시저 시작
    PROCEDURE PROC_MANY_TRAKING(
        O_CUR         OUT         SYS_REFCURSOR
    );
    -- 동선이 가장 많은 사람 찾아내는 프로시저 종료
    
    
    --6. 자가격리자 찾아내는 프로시저 시작
    PROCEDURE PROC_SELF_ISOLATION_LIST(
        O_CUR         OUT         SYS_REFCURSOR
    );
    -- 자가격리자 찾아내는 프로시저 종료
    
    
    --7. 확진자 평균 나이 구하는 프로시저 시작
    PROCEDURE PROC_CON_AVG_AGE(
        O_CUR         OUT             SYS_REFCURSOR
    );
    --확진자 평균 나이 구하는 프로시저 종료
    
    --8. 확진자가 방문지별 머문 시간구하는 프로시저 시작
    PROCEDURE PROC_CON_STAY_TIME(
        O_CUR           OUT           SYS_REFCURSOR
    );
    --확진자가 방문지별 머문 시간구하는 프로시저 종료
    
    
    --9. 코로나 검사를 받았지만 결과가 음성인 사람들 구하는 프로시저 시작
    PROCEDURE PROC_SEL_CHECK_UP_N(
        O_CUR       OUT     SYS_REFCURSOR
    );
    -- 코로나 검사를 받았지만 겨로가가 음성인 사람들 구하는 프로시저 종료
    
    --10. 매개변수를 받아와서 날짜별/지역별/교통수단별 확진자 발생수 검색하는 프로시저 시작
    PROCEDURE PROC_SEL_CON(
        O_CUR   OUT     SYS_REFCURSOR,
        IN_CLICK    IN      VARCHAR2
    );
    --매개변수를 받아와서 날짜별/지역별/교통수단별 확진자 발생수 검색하는 프로시저 종료
    
    --11. 날짜별 확진자 발생 수를 활용하여 전일 대비 확진자 증감 수를 보여주는 프로시저 시작
    PROCEDURE PROC_SEL_CON_PLUS(
         O_CUR       OUT         SYS_REFCURSOR
    );
    --날짜별 확진자 발생 수를 활용하여 전일 대비 확진자 증감 수를 보여주는 프로시저 종료
    
    --12.검사 테이블에서 검사한 결과를 날짜별로 검사 몇건, 확진 몇건 데이터를 가져와서 날짜별 확진률 구하는 프로시저 시작
    PROCEDURE PROC_SEL_CON_RATE(
        IN_CHK_DATE     IN      VARCHAR2,
        O_CUR           OUT     SYS_REFCURSOR
    );
    -- 검사 테이블에서 검사한 결과를 날짜별로 검사 몇건, 확진 몇건 데이터를 가져와서 날짜별 확진률 구하는 프로시저 종료
    
    --13.  확진자가 발생한 건물 명단 중에서 일정수치 이상 확진자가 발생한 건물은 집단 감염 발생지로 지정하고, 집단 감염 발생지를 검색할 수 있는 프로시저 시작
    PROCEDURE PROC_SEL_INFECTION_BUILDINGS(
        O_CUR       OUT     SYS_REFCURSOR
    );
    --확진자가 발생한 건물 명단 중에서 일정수치 이상 확진자가 발생한 건물은 집단 감염 발생지로 지정하고, 집단 감염 발생지를 검색할 수 있는 프로시저 종료
    
    --14. 확진자와 접촉하여 코로나 검사 대상에 지정됐지만 현재 검사받은 사람 테이블에 들어있지 않은 사람을 검색하는 프로시저 시작
    PROCEDURE PROC_SEL_NOT_CHK(
        O_CUR       OUT     SYS_REFCURSOR
    );
    --확진자와 접촉하여 코로나 검사 대상에 지정됐지만 현재 검사받은 사람 테이블에 들어있지 않은 사람을 검색하는 프로시저 종료
END PKG_PROCESS;