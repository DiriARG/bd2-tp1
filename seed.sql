-- Las 5 categorías de los productos.
INSERT INTO categorias (nombre)
VALUES ('Electrónica'), ('Ropa'), ('Hogar'), ('Juguetes'), ('Alimentos');

-- Generación de 50 artículos.
-- Se usa "generate_series(inicio,fin)" como tabla virtual para insertar datos masivamente.
INSERT INTO productos (nombre, precio, stock, categoria_id)
SELECT 
    'Producto ' || i, -- El operador "||" concatena el texto con i, donde i es cada número generado por "generate_series".
    (random() * 100 + 1)::numeric(10,2),
    (random() * 50)::int,
    floor(random() * 5 + 1)::int 
FROM generate_series(1,50) i;

-- Creación de 100 perfiles.
INSERT INTO clientes (nombre, email, ciudad)
SELECT 
    'Cliente ' || i,
    'cliente' || i || '@email.com',
    'Ciudad ' || (i % 10)
FROM generate_series(1,100) i;

-- Generación de 200 transacciones en los últimos 30 días.
INSERT INTO pedidos (cliente_id, fecha)
SELECT 
    floor(random() * 100 + 1)::int,  -- Asigna un cliente aleatorio (1-100).
    CURRENT_DATE - (random() * 30)::int
FROM generate_series(1,200);

-- Se generan 3 filas por cada pedido (600 filas en total).
INSERT INTO detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario)
SELECT
    p.pedido_id,
    pr.producto_id,
    floor(random() * 5 + 1)::int,
    pr.precio -- Se agarra el precio actual del producto como "precio histórico".
FROM pedidos p
CROSS JOIN LATERAL (
    SELECT producto_id, precio 
    FROM productos 
    -- El uso de "p.pedido_id" en el WHERE fuerza a que se reejecuté el "ORDER BY random()" por cada pedido, garantizando productos distintos.
	WHERE p.pedido_id IS NOT NULL 
    ORDER BY random() 
    LIMIT 3 
) pr;
