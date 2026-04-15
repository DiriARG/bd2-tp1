-- Total vendido por cada producto.
SELECT producto_id, SUM(cantidad * precio_unitario) AS total_ingresos
FROM detalle_pedido
GROUP BY producto_id;

-- Clientes con más de 5 pedidos.
SELECT cliente_id, COUNT(*) AS total_pedidos
FROM pedidos
GROUP BY cliente_id
HAVING COUNT(*) > 5; --  HAVING filtra los grupos de clientes con más de 5 pedidos, donde COUNT(*) cuenta cuántos pedidos tiene cada cliente.

-- Reporte de venta diaria
SELECT p.fecha, SUM(dp.cantidad * dp.precio_unitario) AS facturacion_diaria
FROM pedidos p
JOIN detalle_pedido dp USING(pedido_id) -- USING une las dos tablas (pedidos y detalle_pedido) usando la columna "pedido_id" que existe en ambas tablas.
GROUP BY p.fecha
ORDER BY p.fecha DESC;

-- Promedio de gasto por pedido de cada cliente.
SELECT cliente_id, ROUND(AVG(total_por_pedido), 2) AS promedio_gasto
FROM (
    SELECT p.cliente_id, p.pedido_id, SUM(dp.cantidad * dp.precio_unitario) AS total_por_pedido
    FROM pedidos p
    JOIN detalle_pedido dp USING(pedido_id)
    GROUP BY p.cliente_id, p.pedido_id
) AS subconsulta_totales
GROUP BY cliente_id;

-- Productos con precio superior al promedio del catálogo.
SELECT *
FROM productos
WHERE precio > (SELECT AVG(precio) FROM productos)

-- Clientes que han realizado al menos una compra.
SELECT nombre, email
FROM clientes c
WHERE EXISTS (
    SELECT 1 FROM pedidos p
    WHERE p.cliente_id = c.cliente_id
);



