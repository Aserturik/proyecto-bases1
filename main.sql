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
CONN sys/pass_sys@localhost:1521/connect_string as SYSDBA
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

CREATE TABLE clientes (
    id_cliente       NUMBER(10) NOT NULL,
    nombres          VARCHAR2(30),
    apellidos        VARCHAR2(30),
    telefono         VARCHAR2(15),
    email            VARCHAR2(100),
    direccion        VARCHAR2(100),
    fecha_registro   DATE
);

ALTER TABLE clientes ADD CONSTRAINT clientes_pk PRIMARY KEY ( id_cliente );

CREATE TABLE detalles_de_ordenes (
    id_detalle              NUMBER(10) NOT NULL,
    id_orden                NUMBER(10) NOT NULL,
    detalles_orden_producto VARCHAR2(500),
    id_producto_material    NUMBER(10) NOT NULL
);

ALTER TABLE detalles_de_ordenes ADD CONSTRAINT detalles_de_ordenes_pk PRIMARY KEY ( id_detalle );

CREATE TABLE empleados (
    id_empleado           NUMBER(10) NOT NULL,
    nombres               VARCHAR2(30),
    apellidos             VARCHAR2(30),
    telefono              VARCHAR2(15),
    cedula                NUMBER(20),
    salario               NUMBER(15, 2),
    fecha_de_contratacion DATE,
    email                 VARCHAR2(100),
    gerente_id            NUMBER(10),
    puestos_id_puesto   NUMBER(10) NOT NULL
);

CREATE UNIQUE INDEX empleados_tel_idx ON
    empleados (
        telefono
    ASC );

ALTER TABLE empleados ADD CONSTRAINT empleados_pk PRIMARY KEY ( id_empleado );

CREATE TABLE materiales (
    id_material              NUMBER(10) NOT NULL,
    nombre_material          VARCHAR2(100),
    descripcion              VARCHAR2(500),
    costo_unitario           NUMBER(10, 2),
    proveedores_id_proveedor NUMBER(10)
);

ALTER TABLE materiales ADD CONSTRAINT materiales_pk PRIMARY KEY ( id_material );

CREATE TABLE ordenes (
    id_orden      NUMBER(10) NOT NULL,
    fecha_orden   DATE,
    fecha_entrega DATE,
    estado        VARCHAR2(50),
    total         NUMBER(15, 2),
    id_cliente    NUMBER(10) NOT NULL,
    id_empleado   NUMBER(10) NOT NULL
);

ALTER TABLE ordenes ADD CONSTRAINT ordenes_pk PRIMARY KEY ( id_orden );

CREATE TABLE producto_material (
    id_producto_material   NUMBER(10) NOT NULL,
    stock                  NUMBER(10),
    materiales_id_material NUMBER(10) NOT NULL,
    productos_id_producto  NUMBER(10) NOT NULL,
    precio_unitario        NUMBER(6)
);

ALTER TABLE producto_material ADD CONSTRAINT producto_material_pk PRIMARY KEY ( id_producto_material );

CREATE TABLE productos (
    id_producto NUMBER(10) NOT NULL,
    nombre      VARCHAR2(100),
    descripcion VARCHAR2(500)
);

ALTER TABLE productos ADD CONSTRAINT productos_pk PRIMARY KEY ( id_producto );

CREATE TABLE proveedores (
    id_proveedor NUMBER(10) NOT NULL,
    nombres      VARCHAR2(30),
    apellidos    VARCHAR2(30),
    direccion    VARCHAR2(100),
    telefono     VARCHAR2(15),
    email        VARCHAR2(100)
);

ALTER TABLE proveedores ADD CONSTRAINT proveedores_pk PRIMARY KEY ( id_proveedor );

CREATE TABLE puestos (
    id_puesto   NUMBER(10) NOT NULL,
    nombre_puesto VARCHAR2(15)
);

ALTER TABLE puestos ADD CONSTRAINT puestos_pk PRIMARY KEY ( id_puesto );

REM =========== LLAVES FORANEAS ==========================================

ALTER TABLE detalles_de_ordenes
    ADD CONSTRAINT detalles_de_ordenes_ordenes_fk FOREIGN KEY ( id_orden )
        REFERENCES ordenes ( id_orden );

ALTER TABLE detalles_de_ordenes
    ADD CONSTRAINT deta_orden_producto_material_fk FOREIGN KEY ( id_producto_material )
        REFERENCES producto_material ( id_producto_material );

ALTER TABLE empleados
    ADD CONSTRAINT empleados_empleados_fk FOREIGN KEY ( gerente_id )
        REFERENCES empleados ( id_empleado );

ALTER TABLE empleados
    ADD CONSTRAINT empleados_puestos_fk FOREIGN KEY ( puestos_id_puesto )
        REFERENCES puestos ( id_puesto );

ALTER TABLE materiales
    ADD CONSTRAINT materiales_proveedores_fk FOREIGN KEY ( proveedores_id_proveedor )
        REFERENCES proveedores ( id_proveedor );

ALTER TABLE ordenes
    ADD CONSTRAINT ordenes_clientes_fk FOREIGN KEY ( id_cliente )
        REFERENCES clientes ( id_cliente );

ALTER TABLE ordenes
    ADD CONSTRAINT ordenes_empleados_fk FOREIGN KEY ( id_empleado )
        REFERENCES empleados ( id_empleado );

ALTER TABLE producto_material
    ADD CONSTRAINT produc_material_materiales_fk FOREIGN KEY ( materiales_id_material )
        REFERENCES materiales ( id_material );

ALTER TABLE producto_material
    ADD CONSTRAINT producto_material_productos_fk FOREIGN KEY ( productos_id_producto )
        REFERENCES productos ( id_producto );

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
