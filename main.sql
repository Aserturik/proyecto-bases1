SET ECHO OFF
SET VERIFY OFF

PROMPT 
PROMPT specify password for WORKSHOP as parameter 1:
DEFINE pass     = &1
PROMPT 
PROMPT specify password for SYS as parameter 2:
DEFINE pass_sys = &2
PROMPT 
PROMPT specify connect string as parameter 3:
DEFINE connect_string     = &3
PROMPT

DEFINE spool_file = taller.log
SPOOL taller.log

REM =======================================================
REM cleanup section
REM =======================================================

DISCONN
CONN sys/oracle@localhost:1521/xepdb1 as SYSDBA
SHOW CON_NAME

DROP USER admin_user CASCADE;

REM =======================================================
REM create user
REM =======================================================

CREATE USER admin_user IDENTIFIED BY &pass;

ALTER USER admin_user DEFAULT TABLESPACE users
              QUOTA UNLIMITED ON users;

ALTER USER admin_user TEMPORARY TABLESPACE temp;

GRANT CREATE SESSION, CREATE VIEW, ALTER SESSION, CREATE SEQUENCE TO admin_user;
GRANT CREATE SYNONYM, CREATE DATABASE LINK, RESOURCE , UNLIMITED TABLESPACE TO admin_user;

REM =======================================================
REM grants from sys schema
REM =======================================================

CONNECT sys/&pass_sys@&connect_string AS SYSDBA;
GRANT execute ON sys.dbms_stats TO admin_user;

REM =======================================================
REM create workshop schema objects
REM =======================================================

CONNECT admin_user/&pass@&connect_string
ALTER SESSION SET NLS_LANGUAGE=American;
ALTER SESSION SET NLS_TERRITORY=America;

--
-- create tables, sequences and constraint
--

-- @__SUB__CWD__/human_resources/hr_cre

-- 
-- populate tables
--

-- @__SUB__CWD__/human_resources/hr_popul

--
-- create indexes
--

-- @__SUB__CWD__/human_resources/hr_idx

--
-- create procedural objects
--

-- @__SUB__CWD__/human_resources/hr_code

--
-- add comments to tables and columns
--

-- @__SUB__CWD__/human_resources/hr_comnt

--
-- gather schema statistics
--

-- @__SUB__CWD__/human_resources/hr_analz

spool off
