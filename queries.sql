-- REPORTING CON AGREGACIÓN (GROUP BY / HAVING):

-- 1) Total vendido por cada producto.
SELECT producto_id, SUM(cantidad * precio_unitario) AS total_ingresos
FROM detalle_pedido
GROUP BY producto_id;

-- 2) Clientes con más de 5 pedidos.
SELECT cliente_id, COUNT(*) AS total_pedidos
FROM pedidos
GROUP BY cliente_id
HAVING COUNT(*) > 5; -- "HAVING" filtra los grupos de clientes con más de 5 pedidos. "COUNT(*)" cuenta cuántos pedidos tiene cada cliente.

-- 3) Reporte de venta diaria.
SELECT p.fecha, SUM(dp.cantidad * dp.precio_unitario) AS facturacion_diaria
FROM pedidos p
JOIN detalle_pedido dp USING(pedido_id) -- "USING" une las dos tablas (pedidos y detalle_pedido) usando la columna "pedido_id" que existe en ambas tablas.
GROUP BY p.fecha
ORDER BY p.fecha DESC;

-- 4) Promedio de gasto por pedido de cada cliente. La subconsulta es necesaria para sumar primero cada pedido antes de promediarlos.
SELECT cliente_id, ROUND(AVG(total_por_pedido), 2) AS promedio_gasto
FROM (
    SELECT p.cliente_id, p.pedido_id, SUM(dp.cantidad * dp.precio_unitario) AS total_por_pedido
    FROM pedidos p
    JOIN detalle_pedido dp USING(pedido_id)
    GROUP BY p.cliente_id, p.pedido_id
) AS subconsulta_totales
GROUP BY cliente_id;



-- SUBCONSULTAS (INCLUYENDO EXISTS Y CORRELACIONADAS):

-- 5) Productos con precio superior al promedio del catálogo.
SELECT *
FROM productos
WHERE precio > (SELECT AVG(precio) FROM productos);

-- 6) Listado de pedidos realizados exclusivamente por clientes que viven en Ciudad 1.
SELECT *
FROM pedidos
WHERE cliente_id IN ( -- El "IN" filtra los pedidos cuyos "cliente_id" coinciden con los valores devueltos por la subconsulta (clientes de 'Ciudad 1').
    SELECT cliente_id 
    FROM clientes 
    WHERE ciudad = 'Ciudad 1'
);

-- 7) Clientes que han realizado al menos una compra.
SELECT nombre, email
FROM clientes c
WHERE EXISTS (  -- "EXISTS" verifica si existe al menos una fila que cumple la condición.
	-- "SELECT 1" se usa por convención, ya que no importa qué se seleccione; solo interesa la existencia de registros.
	SELECT 1 FROM pedidos p 
    WHERE p.cliente_id = c.cliente_id
);

-- 8) Listado de productos que han sido vendidos al menos una vez.
SELECT nombre, precio, stock
FROM productos p
WHERE EXISTS (
    SELECT 1 FROM detalle_pedido dp
    WHERE dp.producto_id = p.producto_id
);



-- COMMON TABLE EXPRESSIONS (CTE):

-- 9) Calcula el total de cada pedido sumando sus productos.
-- Con "WITH" se define una CTE que funciona como una tabla temporal y solo existe durante la ejecución de la consulta.
WITH total_por_pedido AS (
    SELECT pedido_id, SUM(cantidad * precio_unitario) AS total
    FROM detalle_pedido
    GROUP BY pedido_id
)
SELECT * FROM total_por_pedido;

-- 10) Ranking de los 5 pedidos de mayor valor.
WITH ranking_ventas AS (
    SELECT pedido_id, SUM(cantidad * precio_unitario) AS monto_total
    FROM detalle_pedido
    GROUP BY pedido_id
)
SELECT * FROM ranking_ventas 
ORDER BY monto_total DESC 
LIMIT 5;



-- CONSULTAS DE NEGOCIO:

-- 11) Productos sin ventas registradas.
SELECT nombre, precio, stock
FROM productos p
WHERE NOT EXISTS (
    SELECT 1 FROM detalle_pedido dp
    WHERE dp.producto_id = p.producto_id
);

-- 12) Ranking de los 10 clientes por volumen de gasto total.
SELECT c.nombre, SUM(dp.cantidad * dp.precio_unitario) AS gasto_historico
FROM clientes c
JOIN pedidos p ON c.cliente_id = p.cliente_id
JOIN detalle_pedido dp ON p.pedido_id = dp.pedido_id
GROUP BY c.cliente_id, c.nombre
ORDER BY gasto_historico DESC
LIMIT 10;

-- 13) Ranking de categorías de productos según la facturación total.
SELECT cat.nombre AS categoria, SUM(dp.cantidad * dp.precio_unitario) AS total_ventas
FROM detalle_pedido dp
JOIN productos prod ON dp.producto_id = prod.producto_id
JOIN categorias cat ON prod.categoria_id = cat.categoria_id
GROUP BY cat.nombre
ORDER BY total_ventas DESC;



