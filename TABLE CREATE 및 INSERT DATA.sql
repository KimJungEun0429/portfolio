CREATE TABLE ADDRESS_TBL --주소테이블 (공통테이블)
(
    A_ID            CHAR(5)         NOT NULL        PRIMARY KEY,
    A_VAL           VARCHAR2(20)    NOT NULL,
    A_LVL           NUMBER(5)       NOT NULL,
    A_PARENT_ID     CHAR(5)         NULL,
    GROUP_ID        CHAR(5)         NOT NULL
);

CREATE TABLE GROUP_TBL( --그룹테이블 (그룹코드)
    G_ID            CHAR(5)         NOT NULL        PRIMARY KEY,
    GROUP_NAME      VARCHAR2(20)    NOT NULL
);

CREATE TABLE TIME_TBL --시간표 테이블
(
    T_ID            CHAR(5)         NOT NULL        PRIMARY KEY,
    T_START       VARCHAR2(10)	NULL,	
    T_END	        VARCHAR2(10)	NULL,
    VEHICLE_ID	    CHAR(7)	        NOT NULL

);

CREATE TABLE VISIT_TBL --방문기록 테이블
(
    VISIT_ID            CHAR(7)         NOT NULL        PRIMARY KEY,
    P_ID                CHAR(5)         NOT NULL,
    B_ID                CHAR(5)         NOT NULL,
    CHECK_IN            DATE            NOT NULL,
    CHECK_OUT           DATE            NOT NULL,
    V_TEM               NUMBER(3,1)     NOT NULL
);

CREATE TABLE MSG_TBL    --메시지 테이블
(
    MSG_ID          CHAR(5)         NOT NULL        PRIMARY KEY,
    MSG_VALUE       VARCHAR2(100)   NOT NULL
);

CREATE TABLE CHECK_UP_TBL   --검사 테이블
(
    CHK_ID          CHAR(7)         NOT NULL        PRIMARY KEY,
    SM_ID           CHAR(7)         NOT NULL,
    C_YN            CHAR(1)         NOT NULL, -- 0: 음성, 1:양성
    CHK_DATE        DATE            NOT NULL
);

CREATE TABLE CONTAGION_TBL      --확진 테이블
(
    CON_ID          CHAR(7)         NOT NULL        PRIMARY KEY,
    CHK_ID          CHAR(7)         NOT NULL,
    CON_DATE        DATE            NOT NULL
);

CREATE TABLE PEOPLE_TBL     --사람 테이블
(
    P_ID        CHAR(5)         NOT NULL  PRIMARY KEY,
    P_NAME      VARCHAR2(30)    NOT NULL,
    P_GENDER    CHAR(1)         NOT NULL,
    P_TEL       VARCHAR2(20)    NOT NULL,
    P_BIRTH     DATE            NOT NULL,
    P_ADD       CHAR(5)         NOT NULL
);

CREATE TABLE BUILDING_TBL       --건물 테이블
(
    B_ID        CHAR(5)         NOT NULL  PRIMARY KEY,
    B_NAME      VARCHAR2(30)    NOT NULL,
    B_TEL       VARCHAR2(20)    NOT NULL,
    B_ADD       CHAR(5)         
);

CREATE TABLE VEHICLE_TBL --(GROUP_CODE) 차량
(
    VEHICLE_ID        CHAR(7)         NOT NULL  PRIMARY KEY,
    VEHICLE_NAME      VARCHAR2(30)    NOT NULL      
);

CREATE TABLE GET_IN_TBL --승차테이블
(
    GET_IN_ID        CHAR(7)    NOT NULL  PRIMARY KEY,
    P_ID             CHAR(5)    NOT NULL,
    T_ID             CHAR(5)    NOT NULL,
    CHECK_IN          DATE       NOT NULL,
    CHECK_OUT         DATE       NOT NULL
);

CREATE TABLE SEND_MSG_TBL       --문자발송테이블
(
    SM_ID        CHAR(7)    NOT NULL  PRIMARY KEY,
    VISIT_ID     CHAR(7)    NULL,
    MSG_ID       CHAR(5)    NOT NULL,
    SM_DATE      DATE       NOT NULL,
    GET_IN_ID    CHAR(7)    NULL
);



-- 주소 데이터
Insert into ADDRESS_TBL (A_ID,A_VAL,A_LVL,A_PARENT_ID,GROUP_ID) values ('A0001','부산시',1,null,'G0001');
Insert into ADDRESS_TBL (A_ID,A_VAL,A_LVL,A_PARENT_ID,GROUP_ID) values ('A0002','영도구',2,'A0001','G0001');
Insert into ADDRESS_TBL (A_ID,A_VAL,A_LVL,A_PARENT_ID,GROUP_ID) values ('A0003','남구',2,'A0001','G0001');
Insert into ADDRESS_TBL (A_ID,A_VAL,A_LVL,A_PARENT_ID,GROUP_ID) values ('A0004','수영구',2,'A0001','G0001');
Insert into ADDRESS_TBL (A_ID,A_VAL,A_LVL,A_PARENT_ID,GROUP_ID) values ('A0005','부산진구',2,'A0001','G0001');
Insert into ADDRESS_TBL (A_ID,A_VAL,A_LVL,A_PARENT_ID,GROUP_ID) values ('A0006','남항동',3,'A0002','G0001');
Insert into ADDRESS_TBL (A_ID,A_VAL,A_LVL,A_PARENT_ID,GROUP_ID) values ('A0007','영선동',3,'A0002','G0001');
Insert into ADDRESS_TBL (A_ID,A_VAL,A_LVL,A_PARENT_ID,GROUP_ID) values ('A0008','신성동',3,'A0002','G0001');
Insert into ADDRESS_TBL (A_ID,A_VAL,A_LVL,A_PARENT_ID,GROUP_ID) values ('A0009','봉래동',3,'A0002','G0001');
Insert into ADDRESS_TBL (A_ID,A_VAL,A_LVL,A_PARENT_ID,GROUP_ID) values ('A0010','대연동',3,'A0003','G0001');
Insert into ADDRESS_TBL (A_ID,A_VAL,A_LVL,A_PARENT_ID,GROUP_ID) values ('A0011','용호동',3,'A0003','G0001');
Insert into ADDRESS_TBL (A_ID,A_VAL,A_LVL,A_PARENT_ID,GROUP_ID) values ('A0012','문현동',3,'A0003','G0001');
Insert into ADDRESS_TBL (A_ID,A_VAL,A_LVL,A_PARENT_ID,GROUP_ID) values ('A0013','우암동',3,'A0003','G0001');
Insert into ADDRESS_TBL (A_ID,A_VAL,A_LVL,A_PARENT_ID,GROUP_ID) values ('A0014','남천동',3,'A0004','G0001');
Insert into ADDRESS_TBL (A_ID,A_VAL,A_LVL,A_PARENT_ID,GROUP_ID) values ('A0015','수영동',3,'A0004','G0001');
Insert into ADDRESS_TBL (A_ID,A_VAL,A_LVL,A_PARENT_ID,GROUP_ID) values ('A0016','망미동',3,'A0004','G0001');
Insert into ADDRESS_TBL (A_ID,A_VAL,A_LVL,A_PARENT_ID,GROUP_ID) values ('A0017','광안동',3,'A0004','G0001');
Insert into ADDRESS_TBL (A_ID,A_VAL,A_LVL,A_PARENT_ID,GROUP_ID) values ('A0018','부전동',3,'A0005','G0001');
Insert into ADDRESS_TBL (A_ID,A_VAL,A_LVL,A_PARENT_ID,GROUP_ID) values ('A0019','초읍동',3,'A0005','G0001');
Insert into ADDRESS_TBL (A_ID,A_VAL,A_LVL,A_PARENT_ID,GROUP_ID) values ('A0020','전포동',3,'A0005','G0001');
Insert into ADDRESS_TBL (A_ID,A_VAL,A_LVL,A_PARENT_ID,GROUP_ID) values ('A0021','당감동',3,'A0005','G0001');


----건물 데이터
Insert into BUILDING_TBL (B_ID,B_NAME,B_TEL,B_ADD) values ('B0001','GS25','0518641497','A0006');
Insert into BUILDING_TBL (B_ID,B_NAME,B_TEL,B_ADD) values ('B0002','자드PC','0518681852','A0009');
Insert into BUILDING_TBL (B_ID,B_NAME,B_TEL,B_ADD) values ('B0003','수미식당','0516936742','A0012');
Insert into BUILDING_TBL (B_ID,B_NAME,B_TEL,B_ADD) values ('B0004','은하수식당','0517945169','A0013');
Insert into BUILDING_TBL (B_ID,B_NAME,B_TEL,B_ADD) values ('B0005','동아약국','0511327412','A0010');
Insert into BUILDING_TBL (B_ID,B_NAME,B_TEL,B_ADD) values ('B0006','맥도날드','0515369496','A0010');
Insert into BUILDING_TBL (B_ID,B_NAME,B_TEL,B_ADD) values ('B0007','코끼리내과','0515552103','A0018');
Insert into BUILDING_TBL (B_ID,B_NAME,B_TEL,B_ADD) values ('B0008','부경대학교','0511424421','A0017');
Insert into BUILDING_TBL (B_ID,B_NAME,B_TEL,B_ADD) values ('B0009','일층술집','0517841005','A0011');
Insert into BUILDING_TBL (B_ID,B_NAME,B_TEL,B_ADD) values ('B0010','마왕족발','0512409981','A0017');
Insert into BUILDING_TBL (B_ID,B_NAME,B_TEL,B_ADD) values ('B0011','피자헛','0514513320','A0014');
Insert into BUILDING_TBL (B_ID,B_NAME,B_TEL,B_ADD) values ('B0012','BBQ치킨','0513339851','A0020');
Insert into BUILDING_TBL (B_ID,B_NAME,B_TEL,B_ADD) values ('B0013','CU','0516436644','A0014');
Insert into BUILDING_TBL (B_ID,B_NAME,B_TEL,B_ADD) values ('B0014','락볼링장','0512481134','A0021');
Insert into BUILDING_TBL (B_ID,B_NAME,B_TEL,B_ADD) values ('B0015','롯데마트','0515521982','A0017');

--검사 데이터
INSERT INTO CHECK_UP_TBL VALUES('CHK0001','SM00001','Y',TO_DATE('20210502'));
INSERT INTO CHECK_UP_TBL VALUES('CHK0002','SM00002','N',TO_DATE('20210502'));
INSERT INTO CHECK_UP_TBL VALUES('CHK0003','SM00003','Y',TO_DATE('20210503'));
INSERT INTO CHECK_UP_TBL VALUES('CHK0004','SM00004','N',TO_DATE('20210504'));
INSERT INTO CHECK_UP_TBL VALUES('CHK0005','SM00005','N',TO_DATE('20210504'));

--확진 데이터
Insert into CONTAGION_TBL (CON_ID,CHK_ID,CON_DATE) values ('CON0001','CHK0001',to_date('21/05/02','RR/MM/DD'));
Insert into CONTAGION_TBL (CON_ID,CHK_ID,CON_DATE) values ('CON0002','CHK0003',to_date('21/05/03','RR/MM/DD'));


--그룹코드
Insert into GROUP_TBL (G_ID,GROUP_NAME) values ('G0001','주소');

--메시지 데이터
Insert into MSG_TBL (MSG_ID,MSG_VALUE) values ('MSG01','37.5도 이상 이므로 가까운 보건소에서 검사바랍니다.');
Insert into MSG_TBL (MSG_ID,MSG_VALUE) values ('MSG02','의심자와 접촉했으니 가까운 보건소에서 검사바랍니다.');


--사람 데이터
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0001','김민준','M','01039828187',to_date('94/06/20','RR/MM/DD'),'A0019');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0002','박서준','M','01079941339',to_date('88/06/07','RR/MM/DD'),'A0006');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0003','이서연','F','01082762996',to_date('88/01/27','RR/MM/DD'),'A0007');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0004','황서윤','F','01001456883',to_date('95/02/20','RR/MM/DD'),'A0012');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0005','김도윤','M','01044583335',to_date('92/01/14','RR/MM/DD'),'A0013');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0006','정예준','M','01008336987',to_date('91/05/03','RR/MM/DD'),'A0021');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0007','현시우','M','01096809747',to_date('89/12/12','RR/MM/DD'),'A0006');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0008','김지우','F','01011004194',to_date('93/02/28','RR/MM/DD'),'A0012');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0009','박서현','F','01003017111',to_date('91/02/26','RR/MM/DD'),'A0007');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0010','강민서','F','01061751894',to_date('98/05/06','RR/MM/DD'),'A0010');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0011','성지호','M','01086307157',to_date('97/04/22','RR/MM/DD'),'A0009');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0012','최지후','M','01009232685',to_date('96/04/18','RR/MM/DD'),'A0006');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0013','권채원','F','01008572617',to_date('97/01/13','RR/MM/DD'),'A0011');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0014','배준우','M','01002879296',to_date('90/12/14','RR/MM/DD'),'A0008');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0015','신수아','F','01012487924',to_date('98/03/15','RR/MM/DD'),'A0014');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0016','김민재','M','01069006481',to_date('98/04/14','RR/MM/DD'),'A0015');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0017','이현준','M','01005576693',to_date('88/02/21','RR/MM/DD'),'A0008');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0018','이예린','F','01079069599',to_date('92/11/23','RR/MM/DD'),'A0006');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0019','박지원','F','01009785424',to_date('90/03/24','RR/MM/DD'),'A0016');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0020','천정우','M','01007444439',to_date('91/01/18','RR/MM/DD'),'A0017');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0021','이시온','M','01081051624',to_date('88/04/24','RR/MM/DD'),'A0008');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0022','현승우','M','01006854822',to_date('89/10/02','RR/MM/DD'),'A0018');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0023','전시은','F','01078775212',to_date('90/07/12','RR/MM/DD'),'A0009');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0024','김채윤','F','01000651612',to_date('95/04/11','RR/MM/DD'),'A0006');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0025','윤준호','M','01003348163',to_date('89/06/01','RR/MM/DD'),'A0019');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0026','변성현','M','01062773636',to_date('93/07/28','RR/MM/DD'),'A0019');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0027','최예지','F','01063726736',to_date('91/12/02','RR/MM/DD'),'A0018');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0028','박현서','F','01004556885',to_date('91/12/06','RR/MM/DD'),'A0020');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0029','신예지','F','01070318783',to_date('91/09/25','RR/MM/DD'),'A0021');
Insert into PEOPLE_TBL (P_ID,P_NAME,P_GENDER,P_TEL,P_BIRTH,P_ADD) values ('P0030','진정민','M','01003153861',to_date('88/07/09','RR/MM/DD'),'A0015');


--문자발송 데이터
Insert into SEND_MSG_TBL (SM_ID,VISIT_ID,MSG_ID,SM_DATE,GET_IN_ID) values ('SM00001','VI00003','MSG01',to_date('21/05/02','RR/MM/DD'),null);
Insert into SEND_MSG_TBL (SM_ID,VISIT_ID,MSG_ID,SM_DATE,GET_IN_ID) values ('SM00002','VI00012','MSG01',to_date('21/05/02','RR/MM/DD'),null);
Insert into SEND_MSG_TBL (SM_ID,VISIT_ID,MSG_ID,SM_DATE,GET_IN_ID) values ('SM00003','VI00018','MSG01',to_date('21/05/03','RR/MM/DD'),null);
Insert into SEND_MSG_TBL (SM_ID,VISIT_ID,MSG_ID,SM_DATE,GET_IN_ID) values ('SM00004','VI00032','MSG01',to_date('21/05/04','RR/MM/DD'),null);
Insert into SEND_MSG_TBL (SM_ID,VISIT_ID,MSG_ID,SM_DATE,GET_IN_ID) values ('SM00005','VI00039','MSG01',to_date('21/05/04','RR/MM/DD'),null);


--시간 데이터
Insert into TIME_TBL (T_ID,T_START,T_END,VEHICLE_ID) values ('T0001','06:00','09:00','VE00001');
Insert into TIME_TBL (T_ID,T_START,T_END,VEHICLE_ID) values ('T0002','09:00','12:00','VE00001');
Insert into TIME_TBL (T_ID,T_START,T_END,VEHICLE_ID) values ('T0003','12:00','15:00','VE00001');
Insert into TIME_TBL (T_ID,T_START,T_END,VEHICLE_ID) values ('T0004','15:00','18:00','VE00001');
Insert into TIME_TBL (T_ID,T_START,T_END,VEHICLE_ID) values ('T0005','18:00','21:00','VE00001');
Insert into TIME_TBL (T_ID,T_START,T_END,VEHICLE_ID) values ('T0006','21:00',':00:00','VE00001');
Insert into TIME_TBL (T_ID,T_START,T_END,VEHICLE_ID) values ('T0007','06:00','08:00','VE00002');
Insert into TIME_TBL (T_ID,T_START,T_END,VEHICLE_ID) values ('T0008','08:00','10:00','VE00002');
Insert into TIME_TBL (T_ID,T_START,T_END,VEHICLE_ID) values ('T0009','10:00','12:00','VE00002');
Insert into TIME_TBL (T_ID,T_START,T_END,VEHICLE_ID) values ('T0010','12:00','14:00','VE00002');
Insert into TIME_TBL (T_ID,T_START,T_END,VEHICLE_ID) values ('T0011','14:00','16:00','VE00002');
Insert into TIME_TBL (T_ID,T_START,T_END,VEHICLE_ID) values ('T0012','16:00','18:00','VE00002');
Insert into TIME_TBL (T_ID,T_START,T_END,VEHICLE_ID) values ('T0013','18:00','20:00','VE00002');
Insert into TIME_TBL (T_ID,T_START,T_END,VEHICLE_ID) values ('T0014','20:00','22:00','VE00002');
Insert into TIME_TBL (T_ID,T_START,T_END,VEHICLE_ID) values ('T0015','22:00',':00:00','VE00002');
Insert into TIME_TBL (T_ID,T_START,T_END,VEHICLE_ID) values ('T0016',null,null,'VE00003');

--운송수단 데이터
Insert into VEHICLE_TBL (VEHICLE_ID,VEHICLE_NAME) values ('VE00001','지하철');
Insert into VEHICLE_TBL (VEHICLE_ID,VEHICLE_NAME) values ('VE00002','버스');
Insert into VEHICLE_TBL (VEHICLE_ID,VEHICLE_NAME) values ('VE00003','택시');

--COMMIT;
     SELECT * FROM GET_IN_TBL;
     SELECT * FROM ADDRESS_TBL;
     SELECT * FROM BUILDING_TBL;
     SELECT * FROM CHECK_UP_TBL;
     SELECT * FROM CONTAGION_TBL;
     SELECT * FROM GET_IN_TBL;
     SELECT * FROM GROUP_TBL;
     SELECT * FROM MSG_TBL;
     SELECT * FROM PEOPLE_TBL;
     SELECT * FROM SEND_MSG_TBL;

