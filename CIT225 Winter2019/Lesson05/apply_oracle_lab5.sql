-- ------------------------------------------------------------------
--  Program Name:   apply_oracle_lab5.sql
--  Lab Assignment: N/A
--  Program Author: Michael McLaughlin
--  Creation Date:  17-Jan-2018
-- ------------------------------------------------------------------
--  Change Log:
-- ------------------------------------------------------------------
--  Change Date    Change Reason
-- -------------  ---------------------------------------------------
--  
-- ------------------------------------------------------------------
-- This creates tables, sequences, indexes, and constraints necessary
-- to begin lesson #5. Demonstrates proper process and syntax.
-- ------------------------------------------------------------------
-- Instructions:
-- ------------------------------------------------------------------
-- The two scripts contain spooling commands, which is why there
-- isn't a spooling command in this script. When you run this file
-- you first connect to the Oracle database with this syntax:
--
--   sqlplus student/student@xe
--
-- Then, you call this script with the following syntax:
--
--   sql> @apply_oracle_lab5.sql
--
-- ------------------------------------------------------------------

-- Run the prior lab script.
@/home/student/Data/cit225/oracle/lib1/utility/cleanup_oracle.sql
@/home/student/Data/cit225/oracle/lib1/create/create_oracle_store2.sql
@/home/student/Data/cit225/oracle/lib1/preseed/preseed_oracle_store.sql
@/home/student/Data/cit225/oracle/lib1/seed/seeding.sql
 
SPOOL apply_oracle_lab5.txt

--1a. Display member_id and contact_id in the SELECT clause form a join
--of the member and contact tables.  Make the join with the USING
--subclause based on the member_id column which is the primary and
-- foreign key of the respective tables--
 
SELECT member_id, contact_id
FROM member m
INNER JOIN contact c
USING(member_id);

--1b--

SELECT  M.MEMBER_ID, C.CONTACT_ID
FROM    MEMBER M, CONTACT C
WHERE M.MEMBER_ID = C.MEMBER_ID;

--1c--
SELECT  CONTACT_ID
,       ADDRESS_ID
FROM    CONTACT
INNER   JOIN ADDRESS 
USING   (CONTACT_ID);

--1d--
SELECT  C.CONTACT_ID, A.ADDRESS_ID
FROM    CONTACT C, ADDRESS A
WHERE   C.CONTACT_ID = A.CONTACT_ID;

--1e--
SELECT  ADDRESS_ID
,       STREET_ADDRESS_ID
FROM    ADDRESS
INNER   JOIN STREET_ADDRESS 
USING   (ADDRESS_ID);

--1f--
SELECT  A.ADDRESS_ID, S.STREET_ADDRESS_ID
FROM    ADDRESS A, STREET_ADDRESS S
WHERE   A.ADDRESS_ID = S.ADDRESS_ID;

--1g--
SELECT  ADDRESS_ID
,       TELEPHONE_ID
FROM    ADDRESS
INNER   JOIN TELEPHONE 
USING   (ADDRESS_ID);

--1h--
SELECT  A.ADDRESS_ID, T.TELEPHONE_ID
FROM    ADDRESS A, TELEPHONE T
WHERE   A.ADDRESS_ID = T.ADDRESS_ID;

--2a--
SELECT C.CONTACT_ID, S.SYSTEM_USER_ID
FROM CONTACT C  INNER JOIN SYSTEM_USER S
ON C.CREATED_BY = S.SYSTEM_USER_ID;

--2b--
SELECT C.CONTACT_ID, S.SYSTEM_USER_ID
FROM CONTACT C, SYSTEM_USER S
WHERE C.CREATED_BY = S.SYSTEM_USER_ID;

--2c
SELECT C.CONTACT_ID, S.SYSTEM_USER_ID
FROM CONTACT C  INNER JOIN SYSTEM_USER S
ON C.LAST_UPDATED_BY = S.SYSTEM_USER_ID;

--2d--
SELECT C.CONTACT_ID, S.SYSTEM_USER_ID
FROM CONTACT C, SYSTEM_USER S
WHERE C.LAST_UPDATED_BY = S.SYSTEM_USER_ID;

--3a--
SELECT SU1.SYSTEM_USER_ID as system_user_id, SU1.CREATED_BY as created_by, SU2.SYSTEM_USER_ID as system_user_pk
FROM SYSTEM_USER SU1 INNER JOIN SYSTEM_USER SU2
ON SU1.CREATED_BY = SU2.SYSTEM_USER_ID;

COL system_user_id  FORMAT 999999  HEADING "System|User|ID #|--------|Table #1"
COL created_by      FORMAT 999999  HEADING "Created|By|ID #|--------|Table #1"
COL system_user_pk  FORMAT 999999  HEADING "System|User|ID #|--------|Table #2"

--3b--
SELECT SU1.SYSTEM_USER_ID as system_user_id, SU1.LAST_UPDATED_BY as last_updated_by, SU2.SYSTEM_USER_ID as system_user_pk
FROM SYSTEM_USER SU1 INNER JOIN SYSTEM_USER SU2
ON SU1.LAST_UPDATED_BY = SU2.SYSTEM_USER_ID;

COL system_user_id   FORMAT 999999  HEADING "System|User|ID #|--------|Table #1"
COL last_updated_by  FORMAT 999999  HEADING "Last|Updated|By|ID #|--------|Table #1"
COL system_user_pk   FORMAT 999999  HEADING "System|User|ID #|--------|Table #2"

--3c--
SELECT SU1.SYSTEM_USER_ID as user_id
, SU1.SYSTEM_USER_NAME as user_name
, SU2.SYSTEM_USER_ID as cby_user_id
, SU2.SYSTEM_USER_NAME as cby_user_name
, SU3.SYSTEM_USER_ID as lby_user_id
, SU3.SYSTEM_USER_NAME as lby_user_name
FROM SYSTEM_USER SU1 INNER JOIN SYSTEM_USER SU2 
ON SU1.CREATED_BY = SU2.SYSTEM_USER_ID
INNER JOIN SYSTEM_USER SU3
ON SU2.LAST_UPDATED_BY = SU3.SYSTEM_USER_ID;

COL user_id        FORMAT 999999  HEADING "System|User|ID #|--------|Table #1"
COL user_name      FORMAT A8      HEADING "System|User|Name|--------|Table #1"
COL cby_user_id    FORMAT 999999  HEADING "System|User|ID #|--------|Table #2"
COL cby_user_name  FORMAT A8      HEADING "System|User|Name|--------|Table #2"
COL lby_user_id    FORMAT 999999  HEADING "System|User|ID #|--------|Table #3"
COL lby_user_name  FORMAT A8      HEADING "System|User|Name|--------|Table #3"

--4--
SELECT R.RENTAL_ID
,      RI.RENTAL_ID
,      RI.ITEM_ID
,      I.ITEM_ID
FROM RENTAL R 
INNER JOIN RENTAL_ITEM RI
ON R.RENTAL_ID = RI.RENTAL_ID
INNER JOIN ITEM I
ON RI.ITEM_ID = I.ITEM_ID;

ALTER TABLE RENTAL 
DROP CONSTRAINT nn_rental_3;

COMMIT;

--5--

/* Conditionally drop non-equijoin sample tables. */
BEGIN
  FOR i IN (SELECT   object_name
            ,        object_type
            FROM     user_objects
            WHERE    object_name IN ('DEPARTMENT','DEPARTMENT_S'
                                  ,'EMPLOYEE','EMPLOYEE_S'
                                  ,'SALARY','SALARY_S')
            ORDER BY object_type) LOOP
    IF i.object_type = 'TABLE' THEN
      EXECUTE IMMEDIATE 'DROP '||i.object_type||' '||i.object_name||' CASCADE CONSTRAINTS';
    ELSIF i.object_type = 'SEQUENCE' THEN
      EXECUTE IMMEDIATE 'DROP '||i.object_type||' '||i.object_name;
    END IF;
  END LOOP;
END;
/
 
/* Create department table. */
CREATE TABLE department
( department_id    NUMBER  CONSTRAINT department_pk PRIMARY KEY
, department_name  VARCHAR2(20));
 
/* Create a department_s sequence. */
CREATE SEQUENCE department_s;
 
/* Create a salary table. */
CREATE TABLE salary
( salary_id             NUMBER  CONSTRAINT salary_pk   PRIMARY KEY
, effective_start_date  DATE    CONSTRAINT salary_nn1  NOT NULL
, effective_end_date    DATE
, salary                NUMBER  CONSTRAINT salary_nn2  NOT NULL);
 
/* Create a salary_s sequence. */
CREATE SEQUENCE salary_s;
 
/* Create an employee table. */
CREATE TABLE employee
( employee_id    NUMBER        CONSTRAINT employee_pk  PRIMARY KEY
, department_id  NUMBER        CONSTRAINT employee_nn1 NOT NULL
, salary_id      NUMBER        CONSTRAINT employee_nn2 NOT NULL
, first_name     VARCHAR2(20)  CONSTRAINT employee_nn3 NOT NULL
, last_name      VARCHAR2(20)  CONSTRAINT employee_nn4 NOT NULL
, CONSTRAINT employee_fk FOREIGN KEY(employee_id) REFERENCES employee(employee_id));
 
/* Create an employee_s sequence. */
CREATE SEQUENCE employee_s;
 
 
/* Create an anonymous program to insert data. */
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
  /* Declare a collection of strings. */
  TYPE xname IS TABLE OF VARCHAR2(20);
 
  /* Declare a collection of numbers. */
  TYPE xsalary IS TABLE OF NUMBER;
 
  /* Local variable generated by a random foreign key. */
  lv_department_id  NUMBER;
  lv_salary_id      NUMBER;
 
  /* A collection of first names. */
  lv_first XNAME := xname('Ann','Abbey','Amanda','Archie','Antonio','Arnold'
                         ,'Barbara','Basil','Bernie','Beth','Brian','Bryce'
                         ,'Carl','Carrie','Charlie','Christine','Corneilus','Crystal'
                         ,'Dana','Darlene','Darren','Dave','Davi','Deidre'
                         ,'Eamonn','Eberhard','Ecaterina','Ebony','Elana','Eric'
                         ,'Fabian','Faith','Fernando','Farris','Fiana','Francesca'
                         ,'Gabe','Gayle','Geoffrey','Gertrude','Grayson','Guy'
                         ,'Harry','Harriet','Henry','Henrica','Herman','Hesper'
                         ,'Ian','Ida','Iggy','Iliana','Imogene','Issac'
                         ,'Jan','Jack','Jennifer','Jerry','Julian','June'
                         ,'Kacey','Karen','Kaitlyn','Keith','Kevin','Kyle'
                         ,'Laney','Lawrence','Leanne','Liam','Lois','Lynne'
                         ,'Marcel','Marcia','Mark','Meagan','Mina','Michael'
                         ,'Nancy','Naomi','Narcissa','Nasim','Nathaniel','Neal'
                         ,'Obadiah','Odelia','Ohanna','Olaf','Olive','Oscar'
                         ,'Paige','Palmer','Paris','Pascal','Patricia','Peter'
                         ,'Qadir','Qasim','Quaid','Quant','Quince','Quinn'
                         ,'Rachelle','Rafael','Raj','Randy','Ramona','Raven'
                         ,'Savina','Sadie','Sally','Samuel','Saul','Santino'
                         ,'Tabitha','Tami','Tanner','Thomas','Timothy','Tina'
                         ,'Ugo','Ululani','Umberto','Una','Urbi','Ursula'
                         ,'Val','Valerie','Valiant','Vanessa','Vaughn','Verna'
                         ,'Wade','Wagner','Walden','Wanda','Wendy','Wilhelmina'
                         ,'Xander','Xavier','Xena','Xerxes','Xia','Xylon'
                         ,'Yana','Yancy','Yasmina','Yasmine','Yepa','Yeva'
                         ,'Zacarias','Zach','Zahara','Zander','Zane');
 
  /* A collection of last names. */
  lv_last  XNAME := xname('Abernathy','Anderson','Baker','Barney'
                         ,'Christensen','Cafferty','Davis','Donaldson'
                         ,'Eckhart','Eidelman','Fern','Finkel','Frank','Frankel','Fromm'
                         ,'Garfield','Geary','Harvey','Hamilton','Harwood'
                         ,'Ibarguen','Imbezi','Lindblom','Lynstrom'
                         ,'Martel','McKay','McLellen','Nagata','Noonan','Nunes'
                         ,'O''Brien','Oakey','Patterson','Petersen','Pratel','Preston'
                         ,'Qian','Queen','Ricafort','Richards','Roberts','Robertson'
                         ,'Sampson','Simon','Tabacchi','Travis','Trevor','Tower'
                         ,'Ubel','Urie','Vassen','Vanderbosch'
                         ,'Wacha','Walcott','West','Worley','Xian','Xiang'
                         ,'Yackley','Yaguchi','Zarbarsky','Zambelli');
 
  /* A collection of department names. */
  lv_dept  XNAME := xname('Accounting','Operations','Sales','Factory','Manufacturing');
 
  /* A colleciton of possible salaries. */
  lv_salary  XSALARY := xsalary( 36000, 42000, 48000, 52000, 64000 );
 
  /* Define a local function. */
  FUNCTION random_foreign_key RETURN INTEGER IS
    /* Declare a return variable. */
    lv_return_value  NUMBER;
  BEGIN
    /* Select a random number between 1 and 5 and assign it to a local variable. */
    SELECT CASE
             WHEN num = 0 THEN 5 ELSE num
           END AS random_key
    INTO   lv_return_value
    FROM   (SELECT ROUND(dbms_random.VALUE(1,1000)/100/2,0) num FROM dual) il;
 
    /* Return the random number. */
    RETURN lv_return_value;
  END random_foreign_key;
 
BEGIN
  /* Insert departments. */
  FOR i IN 1..lv_dept.LAST LOOP
    INSERT INTO department
    ( department_id
    , department_name )
    VALUES
    ( department_s.NEXTVAL
    , lv_dept(i));
  END LOOP;
 
  /* Insert salary. */
  FOR i IN 1..lv_salary.LAST LOOP
    INSERT INTO salary
    ( salary_id
    , effective_start_date
    , salary )
    VALUES
    ( salary_s.NEXTVAL
    , TRUNC(SYSDATE) - 30
    , lv_salary(i));
  END LOOP;
 
  /* Insert random employees. */
  FOR i IN 1..lv_first.LAST LOOP
    FOR j IN 1..lv_last.LAST LOOP
      /* Assign a random values to a local variable. */
      lv_department_id := random_foreign_key;
      lv_salary_id := random_foreign_key;
 
      /* Insert values into the employee table. */
      INSERT INTO employee
      ( employee_id
      , department_id
      , salary_id
      , first_name
      , last_name )
      VALUES
      ( employee_s.NEXTVAL
      , lv_department_id
      , lv_salary_id
      , lv_first(i)
      , lv_last(j));   
    END LOOP;
  END LOOP;
 
  /* Commit the writes. */
  COMMIT;  
END;
/


SELECT   d.department_name
,        ROUND(AVG(s.salary),0) AS salary
FROM     employee e INNER JOIN department d
ON       e.department_id = d.department_id INNER JOIN salary s
ON       e.salary_id = s.salary_id
GROUP BY d.department_name
ORDER BY d.department_name;

/* Conditionally drop the table. */
BEGIN
  FOR i IN (SELECT table_name
            FROM   user_tables
            WHERE  table_name = 'MOCK_CALENDAR') LOOP
    EXECUTE IMMEDIATE 'DROP TABLE '||i.table_name||' CASCADE CONSTRAINTS';
  END LOOP;
END;
/
 
/* Create a mock_calendar table. */
CREATE TABLE mock_calendar
( short_month  VARCHAR2(3)
, long_month   VARCHAR2(9)
, start_date   DATE
, end_date     DATE );
 
/* Seed the table with 10 years of data. */
DECLARE
  /* Create local collection data types. */
  TYPE smonth IS TABLE OF VARCHAR2(3);
  TYPE lmonth IS TABLE OF VARCHAR2(9);
 
  /* Declare month arrays. */
  short_month SMONTH := smonth('JAN','FEB','MAR','APR','MAY','JUN'
                              ,'JUL','AUG','SEP','OCT','NOV','DEC');
  long_month  LMONTH := lmonth('January','February','March','April','May','June'
                              ,'July','August','September','October','November','December');
 
  /* Declare base dates. */
  start_date DATE := '01-JAN-15';
  end_date   DATE := '31-JAN-15';
 
  /* Declare years. */
  years      NUMBER := 4;
 
BEGIN
 
  /* Loop through years and months. */
  FOR i IN 1..years LOOP
    FOR j IN 1..short_month.COUNT LOOP
      INSERT INTO mock_calendar VALUES
      ( short_month(j)
      , long_month(j)
      , ADD_MONTHS(start_date,(j-1)+(12*(i-1)))
      , ADD_MONTHS(end_date,(j-1)+(12*(i-1))));
    END LOOP;
  END LOOP;
 
  /* Commit the records. */
  COMMIT;
END;
/

/* Set output parameters. */
SET PAGESIZE 16
 
/* Format column output. */
COL short_month FORMAT A5 HEADING "Short|Month"
COL long_month  FORMAT A9 HEADING "Long|Month"
COL start_date  FORMAT A9 HEADING "Start|Date"
COL end_date    FORMAT A9 HEADING "End|Date" 
 
/* Query the results from the table. */
SELECT * FROM mock_calendar;


SELECT   d.department_name
,        ROUND(AVG(s.salary),0) AS salary
FROM     employee e INNER JOIN department d
ON       e.department_id = d.department_id INNER JOIN salary s
ON       e.salary_id = s.salary_id
WHERE    effective_start_date > TRUNC(SYSDATE) - 60
GROUP BY d.department_name
ORDER BY d.department_name;
 
SPOOL OFF
