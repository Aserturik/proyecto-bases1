REM ----------------------------------------- AJUSTE DE SALIDA -----------------------------------------

SET ECHO OFF
SET VERIFY OFF
SET LINESIZE 200
SET PAGESIZE 500
SET TRIMSPOOL ON

REM ----------------------------------------------------------------------------------------------------


REM -------------------------- CONEXI�N A LA BASE DE DATOS COMO ADMINISTRADOR --------------------------

DISCONN
CONN sys/oracle@localhost:1521/xepdb1 as SYSDBA
SHOW CON_NAME

REM ----------------------------------------------------------------------------------------------------


REM ---------------------------- CREACI�N DEL USUARIO Y CESI�N DE PERMISOS -----------------------------
UNDEFINE admin_Inventory
UNDEFINE pass


PROMPT
PROMPT Define tu usuario:
DEFINE user_admin = &admin_Inventory
PROMPT Define una clave para el usuario &user_admin:
DEFINE password = &pass
PROMPT

SPOOL ./systemSamaca.log

DROP USER &user_admin CASCADE;

CREATE USER &user_admin IDENTIFIED BY &password;

ALTER USER &user_admin DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;
ALTER USER &user_admin TEMPORARY TABLESPACE temp;

GRANT CREATE SESSION, CREATE VIEW, ALTER SESSION, CREATE SEQUENCE TO &user_admin;
GRANT CREATE SYNONYM, CREATE DATABASE LINK, RESOURCE , UNLIMITED TABLESPACE TO &user_admin;
GRANT execute ON sys.dbms_stats TO &user_admin;

REM ----------------------------------------------------------------------------------------------------


REM ---------------------- CONEXI�N A LA BASE DE DATOS CON EL NUEVO USUARIO ----------------------------

CONNECT &user_admin/&password@localhost:1521/xepdb1

--
-- create tables, sequences and constraint
--

CREATE TABLE base_products (
    b_product_id NUMBER(6) NOT NULL,
    description  VARCHAR2(200) NOT NULL,
    name         VARCHAR2(30) NOT NULL,
    gauge        NUMBER(4, 2),
    measure_id   NUMBER(3) NOT NULL
);

ALTER TABLE base_products ADD CONSTRAINT base_products_pk PRIMARY KEY ( b_product_id );

CREATE TABLE clients (
    id_client         NUMBER(6) NOT NULL,
    names             VARCHAR2(45) NOT NULL,
    last_names        VARCHAR2(45),
    phone_number      VARCHAR2(20),
    email             VARCHAR2(45),
    registration_date DATE,
    direction         VARCHAR2(100)
);

ALTER TABLE clients ADD CONSTRAINT clients_pk PRIMARY KEY ( id_client );

CREATE TABLE compositions (
    composition_id          NUMBER(4) NOT NULL,
    composition_name        VARCHAR2(30) NOT NULL,
    composition_description VARCHAR2(200) NOT NULL,
    price                   NUMBER(8, 2)
);

ALTER TABLE compositions ADD CONSTRAINT compositions_pk PRIMARY KEY ( composition_id );

CREATE TABLE employees (
    employee_id  NUMBER(6) NOT NULL,
    names        VARCHAR2(45) NOT NULL,
    last_names   VARCHAR2(45) NOT NULL,
    phone_number VARCHAR2(20),
    cart         NUMBER(10),
    salary       NUMBER(10, 2),
    hire_date    DATE,
    email        VARCHAR2(35) NOT NULL,
    manager_id   NUMBER(10),
    job_id       NUMBER(10) NOT NULL
);

ALTER TABLE employees ADD CONSTRAINT employees_pk PRIMARY KEY ( employee_id );

ALTER TABLE employees ADD CONSTRAINT employees_email_un UNIQUE ( email );

CREATE TABLE jobs (
    job_id    NUMBER(10) NOT NULL,
    job_title VARCHAR2(45) NOT NULL
);

ALTER TABLE jobs ADD CONSTRAINT jobs_pk PRIMARY KEY ( job_id );

CREATE TABLE labor (
    labor       NUMBER(10, 2),
    employee_id NUMBER(6) NOT NULL,
    p_comp_id   NUMBER(6) NOT NULL,
    order_id    NUMBER(8) NOT NULL
);

ALTER TABLE labor ADD CONSTRAINT labor_pk PRIMARY KEY ( employee_id,
                                                        p_comp_id );

CREATE TABLE orders (
    order_id          NUMBER(8) NOT NULL,
    order_date        DATE,
    delivery_date     DATE,
    status            VARCHAR2(50),
    total_price       NUMBER(11, 2),
    clients_id_client NUMBER(6) NOT NULL
);

ALTER TABLE orders ADD CONSTRAINT orders_pk PRIMARY KEY ( order_id );

CREATE TABLE product_composition (
    p_comp_id       NUMBER(6) NOT NULL,
    length          NUMBER(6, 2),
    width           NUMBER(6, 2),
    height          NUMBER(6, 2),
    stock           NUMBER(7, 3),
    product_details VARCHAR2(200) NOT NULL,
    composition_id  NUMBER(4) NOT NULL,
    b_product_id    NUMBER(6) NOT NULL
);

---Alter for tables for FK---
ALTER TABLE product_composition ADD CONSTRAINT product_composition_pk PRIMARY KEY ( p_comp_id );

CREATE TABLE units_of_measure (
    measure_id   NUMBER(3) NOT NULL,
    measure_name VARCHAR2(30) NOT NULL
);

ALTER TABLE units_of_measure ADD CONSTRAINT units_of_measure_pk PRIMARY KEY ( measure_id );

ALTER TABLE units_of_measure ADD CONSTRAINT units_of_measure_name_un UNIQUE ( measure_name );

ALTER TABLE product_composition
    ADD CONSTRAINT base_products_fk FOREIGN KEY ( b_product_id )
        REFERENCES base_products ( b_product_id );

ALTER TABLE orders
    ADD CONSTRAINT clients_fk FOREIGN KEY ( clients_id_client )
        REFERENCES clients ( id_client );

ALTER TABLE product_composition
    ADD CONSTRAINT compositions_fk FOREIGN KEY ( composition_id )
        REFERENCES compositions ( composition_id );

ALTER TABLE labor
    ADD CONSTRAINT employees_fk FOREIGN KEY ( employee_id )
        REFERENCES employees ( employee_id );

ALTER TABLE employees
    ADD CONSTRAINT jobs_fk FOREIGN KEY ( job_id )
        REFERENCES jobs ( job_id );

ALTER TABLE employees
    ADD CONSTRAINT manager_fk FOREIGN KEY ( manager_id )
        REFERENCES employees ( employee_id );

ALTER TABLE labor
    ADD CONSTRAINT orders_fk FOREIGN KEY ( order_id )
        REFERENCES orders ( order_id );

ALTER TABLE labor
    ADD CONSTRAINT product_composition_fk FOREIGN KEY ( p_comp_id )
        REFERENCES product_composition ( p_comp_id );

ALTER TABLE base_products
    ADD CONSTRAINT units_of_measure_fk FOREIGN KEY ( measure_id )
        REFERENCES units_of_measure ( measure_id );


-- INSERT FOR EACH TABLE IN SYSTEM ---
INSERT INTO units_of_measure (measure_id, measure_name) VALUES (1, 'Centimeters');
INSERT INTO units_of_measure (measure_id, measure_name) VALUES (2, 'Kilograms');
INSERT INTO units_of_measure (measure_id, measure_name) VALUES (3, 'Liters');
INSERT INTO units_of_measure (measure_id, measure_name) VALUES (4, 'Pieces');

INSERT INTO jobs (job_id, job_title) VALUES (1, 'Manager');
INSERT INTO jobs (job_id, job_title) VALUES (2, 'Welder');
INSERT INTO jobs (job_id, job_title) VALUES (3, 'Painter');
INSERT INTO jobs (job_id, job_title) VALUES (4, 'Assistant');

INSERT INTO base_products (b_product_id, description, name, gauge, measure_id) 
VALUES (1, 'Galvanized steel sheet', 'Steel Sheet', 0.90, 2);

INSERT INTO base_products (b_product_id, description, name, gauge, measure_id) 
VALUES (2, 'Aluminum profile for doors', 'Aluminum Profile', 0.50, 2);

INSERT INTO base_products (b_product_id, description, name, gauge, measure_id) 
VALUES (3, 'Enameled paint for metal', 'Enameled Paint', NULL, 3);

INSERT INTO base_products (b_product_id, description, name, gauge, measure_id) 
VALUES (4, 'High-strength screws', 'Screws', NULL, 4);


INSERT INTO compositions (composition_id, composition_name, composition_description, price) 
VALUES (1, 'Steel Door Frame', 'Frame made of galvanized steel sheets and aluminum profiles', 120.00);

INSERT INTO compositions (composition_id, composition_name, composition_description, price) 
VALUES (2, 'Painted Gate', 'Gate with enamel paint and decorative finishes', 250.00);

INSERT INTO compositions (composition_id, composition_name, composition_description, price) 
VALUES (3, 'Window Frame', 'Frame made of aluminum profiles and screws', 80.00);


INSERT INTO clients (id_client, names, last_names, phone_number, email, registration_date, direction) 
VALUES (1, 'Carlos', 'Gomez', '3124567890', 'carlos.gomez@correo.com', SYSDATE, 'Calle 12 #45-78');

INSERT INTO clients (id_client, names, last_names, phone_number, email, registration_date, direction) 
VALUES (2, 'Lucia', 'Martinez', '3019876543', 'lucia.martinez@correo.com', SYSDATE, 'Carrera 8 #20-14');

INSERT INTO clients (id_client, names, last_names, phone_number, email, registration_date, direction) 
VALUES (3, 'Andres', 'Rojas', '3105671234', 'andres.rojas@correo.com', SYSDATE, 'Diagonal 6 #30-25');


INSERT INTO employees (employee_id, names, last_names, phone_number, cart, salary, hire_date, email, manager_id, job_id) 
VALUES (1, 'Ana', 'Lopez', '3151234567', 1234567890, 5000.00, SYSDATE, 'ana.lopez@correo.com', NULL, 1);

INSERT INTO employees (employee_id, names, last_names, phone_number, cart, salary, hire_date, email, manager_id, job_id) 
VALUES (2, 'Juan', 'Perez', '3112345678', 9876543210, 3000.00, SYSDATE, 'juan.perez@correo.com', 1, 2);

INSERT INTO employees (employee_id, names, last_names, phone_number, cart, salary, hire_date, email, manager_id, job_id) 
VALUES (3, 'Maria', 'Hernandez', '3179876543', 1234509876, 2800.00, SYSDATE, 'maria.hernandez@correo.com', 1, 3);

INSERT INTO employees (employee_id, names, last_names, phone_number, cart, salary, hire_date, email, manager_id, job_id) 
VALUES (4, 'Luis', 'Garcia', '3185671234', 4567891230, 2000.00, SYSDATE, 'luis.garcia@correo.com', 1, 4);


INSERT INTO orders (order_id, order_date, delivery_date, status, total_price, clients_id_client) 
VALUES (1, SYSDATE, SYSDATE + 7, 'Pending', 370.00, 1);

INSERT INTO orders (order_id, order_date, delivery_date, status, total_price, clients_id_client) 
VALUES (2, SYSDATE, SYSDATE + 5, 'Completed', 250.00, 2);

INSERT INTO orders (order_id, order_date, delivery_date, status, total_price, clients_id_client) 
VALUES (3, SYSDATE, SYSDATE + 10, 'Pending', 120.00, 3);


INSERT INTO product_composition (p_comp_id, length, width, height, stock, product_details, composition_id, b_product_id) 
VALUES (1, 200.00, 100.00, 5.00, 50.000, 'Steel and aluminum door', 1, 1);

INSERT INTO product_composition (p_comp_id, length, width, height, stock, product_details, composition_id, b_product_id) 
VALUES (2, 150.00, 80.00, 5.00, 30.000, 'Gate with paint finish', 2, 3);

INSERT INTO product_composition (p_comp_id, length, width, height, stock, product_details, composition_id, b_product_id) 
VALUES (3, 120.00, 60.00, 5.00, 20.000, 'Window frame with screws', 3, 2);


INSERT INTO labor (labor, employee_id, p_comp_id, order_id) 
VALUES (5.50, 2, 1, 1);

INSERT INTO labor (labor, employee_id, p_comp_id, order_id) 
VALUES (6.00, 3, 2, 2);

INSERT INTO labor (labor, employee_id, p_comp_id, order_id) 
VALUES (4.50, 4, 3, 3);
COMMIT;
spool off