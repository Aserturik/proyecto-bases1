SET ECHO OFF
SET VERIFY OFF
SET LINESIZE 200
SET PAGESIZE 500
SET TRIMSPOOL ON

REM ----------------------------------------------------------------------------------------------------


REM ---------------------------- CREACION DEL USUARIO Y CEACION DE PERMISOS -----------------------------
UNDEFINE admin_Inventory
UNDEFINE pass

PROMPT
PROMPT Define tu usuario:
DEFINE user_admin = &admin_user
PROMPT Define una clave para el usuario &user_admin:
DEFINE password = &pass
PROMPT Define la clave del usuario SYS:
DEFINE password_SYS = &passSYS
PROMPT

SPOOL ./taller.log

REM -------------------------- CONEXION A LA BASE DE DATOS COMO ADMINISTRADOR --------------------------

DISCONN
CONN sys/&password_SYS@localhost:1521/xepdb1 as SYSDBA
SHOW CON_NAME


DROP USER &user_admin CASCADE;

CREATE USER &user_admin IDENTIFIED BY &password;

ALTER USER &user_admin DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;
ALTER USER &user_admin TEMPORARY TABLESPACE temp;

GRANT CREATE SESSION, CREATE VIEW, ALTER SESSION, CREATE SEQUENCE TO &user_admin;
GRANT CREATE SYNONYM, CREATE DATABASE LINK, RESOURCE , UNLIMITED TABLESPACE TO &user_admin;
GRANT execute ON sys.dbms_stats TO &user_admin;

REM ----------------------------------------------------------------------------------------------------


REM ---------------------- CONEXION A LA BASE DE DATOS CON EL NUEVO USUARIO ----------------------------

CONNECT &user_admin/&password@localhost:1521/xepdb1
--
-- CREACION DE LAS TABLAS, SECUENCIAS Y CONSTRAINTS
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

---ALTERACION DE LAS TABLAS CON (FK)
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

-- CARGA DE DATOS CON INSERCIONES

INSERT INTO units_of_measure (measure_id, measure_name) VALUES (1, 'Centimetros');
INSERT INTO units_of_measure (measure_id, measure_name) VALUES (2, 'Kilogramos');
INSERT INTO units_of_measure (measure_id, measure_name) VALUES (3, 'Galones');
INSERT INTO units_of_measure (measure_id, measure_name) VALUES (4, 'Piezas');

INSERT INTO jobs (job_id, job_title) VALUES (1, 'Gerente');
INSERT INTO jobs (job_id, job_title) VALUES (2, 'Soldador');
INSERT INTO jobs (job_id, job_title) VALUES (3, 'Pintor');
INSERT INTO jobs (job_id, job_title) VALUES (4, 'Ayudante');

INSERT INTO base_products (b_product_id, description, name, gauge, measure_id)
VALUES (1, 'Lamina calibre 14 (gruesa)', 'Lamina cal 14', 14, 1);

INSERT INTO base_products (b_product_id, description, name, gauge, measure_id)
VALUES (2, 'Porton de una hoja para casa', 'Porton de una hoja para casa', 18, 1);

INSERT INTO base_products (b_product_id, description, name, gauge, measure_id)
VALUES (3, 'Pintura negra esmalte brillante', 'Esmalte Negro Brillante', NULL, 3);

INSERT INTO base_products (b_product_id, description, name, gauge, measure_id)
VALUES (4, 'Clavo caballo color negro, resistente a la corrosion', 'clavo negro caballo', NULL, 4);

INSERT INTO compositions (composition_id, composition_name, composition_description, price)
VALUES (1, 'Acero', 'Aleacion de hierro y carbono, en la que este entra en una proporcion entre el 0,02 y el 2 por ciento, y que, segun su tratamiento, adquiereesas propiedades: elasticidad, dureeza o resistencia.', 120.00);

INSERT INTO compositions (composition_id, composition_name, composition_description, price)
VALUES (2, 'Aluminio', 'Elemento quimico metalico, de numero atomico 13, de color similar al de la plata, ligero, resistente y ductil, muy abundante en la corteza terrestre, que tiene diversas aplicaciones industriales.', 250.00);

INSERT INTO compositions (composition_id, composition_name, composition_description, price)
VALUES (3, 'Hierro', 'Elemento quimico metalico, de numero atomico 26, de color negro lustroso o gris azulado, ductil, maleable, muy tenaz, abundante en la corteza terrestre.', 80.00);

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
VALUES (1, SYSDATE, SYSDATE + 7, 'Pendiente', NULL, 1);

INSERT INTO orders (order_id, order_date, delivery_date, status, total_price, clients_id_client)
VALUES (2, SYSDATE, SYSDATE + 5, 'Completado', NULL, 2);

INSERT INTO orders (order_id, order_date, delivery_date, status, total_price, clients_id_client)
VALUES (3, SYSDATE, SYSDATE + 10, 'Pendiente', NULL, 3);

INSERT INTO product_composition (p_comp_id, length, width, height, stock, product_details, composition_id, b_product_id)
VALUES (1, 200.00, 0.00, 100.00, 50.000, 'Lamina de acero calibre 14', 1, 1);

INSERT INTO product_composition (p_comp_id, length, width, height, stock, product_details, composition_id, b_product_id)
VALUES (2, 150.00, 80.00, 5.00, 3.000, 'Porton calibre 18 de aluminio una hoja para casa', 2, 2);

INSERT INTO product_composition (p_comp_id, length, width, height, stock, product_details, composition_id, b_product_id)
VALUES (3, 0.30, 0.10, 2.00, 20.000, 'clavo de hierro marca caballo de 2 cemtimetros', 3, 4);

INSERT INTO labor (labor, employee_id, p_comp_id, order_id)
VALUES (50000.00, 2, 1, 1);

INSERT INTO labor (labor, employee_id, p_comp_id, order_id)
VALUES (60000.00, 3, 2, 2);

INSERT INTO labor (labor, employee_id, p_comp_id, order_id)
VALUES (20000.50, 4, 3, 3);

COMMIT;
spool off
