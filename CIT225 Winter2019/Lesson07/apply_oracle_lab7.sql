-- ------------------------------------------------------------------
--  Program Name:   apply_oracle_lab7.sql
--  Lab Assignment: Lab #7
--  Program Author: Michael McLaughlin
--  Creation Date:  02-Mar-2010
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
--   sql> @apply_oracle_lab7.sql
--
-- ------------------------------------------------------------------

-- Call library files.
@/home/student/Data/cit225/oracle/lab6/apply_oracle_lab6.sql

-- Open log file.
SPOOL apply_oracle_lab7.txt

-- number 1

INSERT INTO common_lookup VALUES
( common_lookup_s1.nextval
, 'YES'
, 'Yes'
, 1, SYSDATE, 1, SYSDATE
, 'PRICE'
, 'ACTIVE_FLAG'
, 'Y');

INSERT INTO common_lookup VALUES
( common_lookup_s1.nextval
, 'NO'
, 'No'
, 1, SYSDATE, 1, SYSDATE
, 'PRICE'
, 'ACTIVE_FLAG'
, 'N');

-- verify 

COLUMN common_lookup_table  FORMAT A20 HEADING "COMMON_LOOKUP_TABLE"
COLUMN common_lookup_column FORMAT A20 HEADING "COMMON_LOOKUP_COLUMN"
COLUMN common_lookup_type   FORMAT A20 HEADING "COMMON_LOOKUP_TYPE"
SELECT   common_lookup_table
,        common_lookup_column
,        common_lookup_type
FROM     common_lookup
WHERE    common_lookup_table = 'PRICE'
AND      common_lookup_column = 'ACTIVE_FLAG'
ORDER BY 1, 2, 3 DESC;

-- number 2
-- price table

INSERT INTO common_lookup VALUES
( common_lookup_s1.nextval
, '1-DAY RENTAL'
, '1-Day Rental'
, 1, SYSDATE, 1, SYSDATE
, 'PRICE'
, 'PRICE_TYPE'
, '1');

INSERT INTO common_lookup VALUES
( common_lookup_s1.nextval
, '3-DAY RENTAL'
, '3-Day Rental'
, 1, SYSDATE, 1, SYSDATE
, 'PRICE'
, 'PRICE_TYPE'
, '3');

INSERT INTO common_lookup VALUES
( common_lookup_s1.nextval
, '5-DAY RENTAL'
, '5-Day Rental'
, 1, SYSDATE, 1, SYSDATE
, 'PRICE'
, 'PRICE_TYPE'
, '5');

-- rental_item table

INSERT INTO common_lookup VALUES
( common_lookup_s1.nextval
, '1-DAY RENTAL'
, '1-Day Rental'
, 1, SYSDATE, 1, SYSDATE
, 'RENTAL_ITEM'
, 'RENTAL_ITEM_TYPE'
, '1');

INSERT INTO common_lookup VALUES
( common_lookup_s1.nextval
, '3-DAY RENTAL'
, '3-Day Rental'
, 1, SYSDATE, 1, SYSDATE
, 'RENTAL_ITEM'
, 'RENTAL_ITEM_TYPE'
, '3');

INSERT INTO common_lookup VALUES
( common_lookup_s1.nextval
, '5-DAY RENTAL'
, '5-Day Rental'
, 1, SYSDATE, 1, SYSDATE
, 'RENTAL_ITEM'
, 'RENTAL_ITEM_TYPE'
, '5');

-- verify

COLUMN common_lookup_table  FORMAT A20 HEADING "COMMON_LOOKUP_TABLE"
COLUMN common_lookup_column FORMAT A20 HEADING "COMMON_LOOKUP_COLUMN"
COLUMN common_lookup_type   FORMAT A20 HEADING "COMMON_LOOKUP_TYPE"
SELECT   common_lookup_table
,        common_lookup_column
,        common_lookup_type
FROM     common_lookup
WHERE    common_lookup_table IN ('PRICE','RENTAL_ITEM')
AND      common_lookup_column IN ('PRICE_TYPE','RENTAL_ITEM_TYPE')
ORDER BY 1, 3;

-- number 3 part a

ALTER TABLE rental_item
ADD (rental_item_type  NUMBER(22));

ALTER TABLE rental_item
  ADD rental_item_price NUMBER(22);

-- verify

COLUMN table_name   FORMAT A14
COLUMN column_id    FORMAT 9999
COLUMN column_name  FORMAT A22
COLUMN data_type    FORMAT A12
SELECT   table_name
,        column_id
,        column_name
,        CASE
           WHEN nullable = 'N' THEN 'NOT NULL'
           ELSE ''
         END AS nullable
,        CASE
           WHEN data_type IN ('CHAR','VARCHAR2','NUMBER') THEN
             data_type||'('||data_length||')'
           ELSE
             data_type
         END AS data_type
FROM     user_tab_columns
WHERE    table_name = 'RENTAL_ITEM'
ORDER BY 2;

UPDATE   rental_item ri
SET      rental_item_type =
           (SELECT   cl.common_lookup_id
            FROM     common_lookup cl
            WHERE    cl.common_lookup_code =
              (SELECT   r.return_date - r.check_out_date
               FROM     rental r
               WHERE    r.rental_id = ri.rental_id)
            AND      cl.common_lookup_table = 'RENTAL_ITEM'
            AND      cl.common_lookup_column = 'RENTAL_ITEM_TYPE');
  
-- verify

SELECT   ROW_COUNT
,        col_count
FROM    (SELECT   COUNT(*) AS ROW_COUNT
         FROM     rental_item) rc CROSS JOIN
        (SELECT   COUNT(rental_item_type) AS col_count
         FROM     rental_item
         WHERE    rental_item_type IS NOT NULL) cc;

-- diagnostic query

COL ROWNUM              FORMAT 999999  HEADING "Row|Number"
COL rental_item_type    FORMAT 999999  HEADING "Rental|Item|Type"
COL common_lookup_id    FORMAT 999999  HEADING "Common|Lookup|ID #"
COL common_lookup_code  FORMAT A6      HEADING "Common|Lookup|Code"
COL return_date         FORMAT A11     HEADING "Return|Date"
COL check_out_date      FORMAT A11     HEADING "Check Out|Date"
COL r_rental_id         FORMAT 999999  HEADING "Rental|ID #"
COL ri_rental_id        FORMAT 999999  HEADING "Rental|Item|Rental|ID #"
SELECT   ROWNUM
,        ri.rental_item_type
,        cl.common_lookup_id
,        cl.common_lookup_code
,        r.return_date
,        r.check_out_date
,        CAST((r.return_date - r.check_out_date) AS CHAR) AS lookup_code
,        r.rental_id AS r_rental_id
,        ri.rental_id AS ri_rental_id
FROM     rental r FULL JOIN rental_item ri
ON       r.rental_id = ri.rental_id FULL JOIN common_lookup cl
ON       cl.common_lookup_code =
           CAST((r.return_date - r.check_out_date) AS CHAR)
WHERE    cl.common_lookup_table = 'RENTAL_ITEM'
AND      cl.common_lookup_column = 'RENTAL_ITEM_TYPE'
AND      cl.common_lookup_type LIKE '%-DAY RENTAL'
ORDER BY r.rental_id
,        ri.rental_id;

-- number 3 part b, add foreign key and references

ALTER TABLE rental_item
  ADD CONSTRAINT FK_rental_item_7 FOREIGN KEY (rental_item_type)
REFERENCES common_lookup (common_lookup_id);

-- verify constraint set

COLUMN table_name      FORMAT A12 HEADING "TABLE NAME"
COLUMN constraint_name FORMAT A18 HEADING "CONSTRAINT NAME"
COLUMN constraint_type FORMAT A12 HEADING "CONSTRAINT|TYPE"
COLUMN column_name     FORMAT A18 HEADING "COLUMN NAME"
SELECT   uc.table_name
,        uc.constraint_name
,        CASE
           WHEN uc.constraint_type = 'R' THEN
            'FOREIGN KEY'
         END AS constraint_type
,        ucc.column_name
FROM     user_constraints uc INNER JOIN user_cons_columns ucc
ON       uc.constraint_name = ucc.constraint_name
WHERE    uc.table_name = 'RENTAL_ITEM'
AND      ucc.column_name = 'RENTAL_ITEM_TYPE';

-- number 3 part c, change rental item type column from null to not null

ALTER TABLE RENTAL_ITEM
  MODIFY (RENTAL_ITEM_TYPE NOT NULL);
  
-- verify 3c

COLUMN CONSTRAINT FORMAT A10
SELECT   TABLE_NAME
,        column_name
,        CASE
           WHEN NULLABLE = 'N' THEN 'NOT NULL'
           ELSE 'NULLABLE'
         END AS CONSTRAINT
FROM     user_tab_columns
WHERE    TABLE_NAME = 'RENTAL_ITEM'
AND      column_name = 'RENTAL_ITEM_TYPE';

-- number 4 make select to return data set to insert into price table

SELECT   
       i.item_id   AS "ITEM ID" 
     , active_flag AS "ACTIVE FLAG"
     , cl.common_lookup_id AS "PRICE TYPE"
     , cl.common_lookup_type AS "PRICE DESC"
     , CASE
        WHEN af.active_flag = 'N'
        THEN TO_CHAR(TRUNC(i.release_date), 'DD-MON-YY HH24:MI:SS')
        ELSE TO_CHAR(TRUNC(i.release_date + 31), 'DD-MON-YY HH24:MI:SS')
       END AS "START DATE"
     , CASE
        WHEN af.active_flag = 'N'
        THEN TO_CHAR(TRUNC(i.release_date + 30), 'DD-MON-YY HH24:MI:SS') 
        ELSE NULL
       END AS "END DATE"
     , CASE
        WHEN (TRUNC(SYSDATE) - TRUNC(i.release_date) > 30) AND (active_flag = 'N') AND (dr.rental_days = '1')
        THEN TO_CHAR(3)
        WHEN (TRUNC(SYSDATE) - TRUNC(i.release_date) > 30) AND (active_flag = 'N') AND (dr.rental_days = '3')     
        THEN TO_CHAR(10)
        WHEN (TRUNC(SYSDATE) - TRUNC(i.release_date) > 30) AND (active_flag = 'N') AND (dr.rental_days = '5')
        THEN TO_CHAR(15)        
        WHEN (TRUNC(SYSDATE) - TRUNC(i.release_date) > 30) AND (active_flag = 'Y') AND (dr.rental_days = '1')
        THEN TO_CHAR(1)        
        WHEN (TRUNC(SYSDATE) - TRUNC(i.release_date) > 30) AND (active_flag = 'Y') AND (dr.rental_days = '3')
        THEN TO_CHAR(3)
        WHEN (TRUNC(SYSDATE) - TRUNC(i.release_date) > 30) AND (active_flag = 'Y') AND (dr.rental_days = '5')
        THEN TO_CHAR(5)
        WHEN (TRUNC(SYSDATE) - TRUNC(i.release_date) < 31) AND (dr.rental_days = '1')
        THEN TO_CHAR(3)
        WHEN (TRUNC(SYSDATE) - TRUNC(i.release_date) < 31) AND (dr.rental_days = '3')
        THEN TO_CHAR(10)
        WHEN (TRUNC(SYSDATE) - TRUNC(i.release_date) < 31) AND (dr.rental_days = '5') 
        THEN TO_CHAR(15)
       END AS "AMOUNT"
FROM     item i CROSS JOIN
        (SELECT 'Y' AS active_flag FROM dual
         UNION ALL
         SELECT 'N' AS active_flag FROM dual) af CROSS JOIN
        (SELECT '1' AS rental_days FROM dual
         UNION ALL
         SELECT '3' AS rental_days FROM dual
         UNION ALL
         SELECT '5' AS rental_days FROM dual) dr INNER JOIN
         common_lookup cl ON dr.rental_days = SUBSTR(cl.common_lookup_type,1,1)
WHERE    cl.common_lookup_table = 'PRICE'
AND      cl.common_lookup_column = 'PRICE_TYPE'
AND NOT ((TRUNC(SYSDATE) - TRUNC(i.release_date) < 30) AND (active_flag = 'N'))
ORDER BY 1, 2, 3;

COLUMN item_id     FORMAT 9999 HEADING "ITEM|ID"
COLUMN active_flag FORMAT A6   HEADING "ACTIVE|FLAG"
COLUMN price_type  FORMAT 9999 HEADING "PRICE|TYPE"
COLUMN price_desc  FORMAT A12  HEADING "PRICE DESC"
COLUMN start_date  FORMAT A10  HEADING "START|DATE"
COLUMN end_date    FORMAT A10  HEADING "END|DATE"
COLUMN amount      FORMAT 9999 HEADING "AMOUNT"

SPOOL OFF

COMMIT;
