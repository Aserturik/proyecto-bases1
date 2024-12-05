SELECT
    base_products.name AS "Nombre producto base ",
    base_products.gauge AS "Calibre",
    compositions.composition_name AS "compuesto de ",
    product_composition.product_details AS "detalles de producto"
FROM
    product_composition
JOIN compositions ON product_composition.composition_id = compositions.composition_id
JOIN base_products ON product_composition.b_product_id = base_products.b_product_id;
/
SELECT
    base_products.name AS "Producto Base",
    compositions.composition_name AS "Composición",
    compositions.price AS "Precio Composición"
FROM
    product_composition
JOIN compositions ON product_composition.composition_id = compositions.composition_id
JOIN base_products ON product_composition.b_product_id = base_products.b_product_id;
/
SELECT
    clients.names AS "Nombre Cliente",
    clients.last_names AS "Apellido Cliente",
    orders.order_id AS "ID Orden",
    orders.total_price AS "Precio Total"
FROM
    orders
JOIN clients ON orders.clients_id_client = clients.id_client;
/
SELECT
    employees.names AS "Nombre Empleado",
    employees.last_names AS "Apellido Empleado",
    jobs.job_title AS "Cargo"
FROM
    employees
JOIN jobs ON employees.job_id = jobs.job_id;
/
SELECT
    base_products.name AS "Producto Base",
    product_composition.length AS "Largo",
    product_composition.width AS "Ancho",
    product_composition.height AS "Alto",
    product_composition.stock AS "Stock"
FROM
    product_composition
JOIN base_products ON product_composition.b_product_id = base_products.b_product_id;
