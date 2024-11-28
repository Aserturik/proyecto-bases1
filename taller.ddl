DROP TABLE base_products CASCADE CONSTRAINTS;

DROP TABLE clients CASCADE CONSTRAINTS;

DROP TABLE compositions CASCADE CONSTRAINTS;

DROP TABLE employees CASCADE CONSTRAINTS;

DROP TABLE jobs CASCADE CONSTRAINTS;

DROP TABLE labor CASCADE CONSTRAINTS;

DROP TABLE orders CASCADE CONSTRAINTS;

DROP TABLE product_composition CASCADE CONSTRAINTS;

DROP TABLE units_of_measure CASCADE CONSTRAINTS;

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
