-- Clasificación de los productos que permite agruparlos.
CREATE TABLE categorias (
    categoria_id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL UNIQUE
);

-- Registro de clientes con sus datos de contacto.
CREATE TABLE clientes (
    cliente_id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
	email TEXT UNIQUE NOT NULL, -- "UNIQUE" para evitar cuentas de clientes duplicadas. 
    ciudad TEXT NOT NULL
);

-- Catálogo de productos disponibles.
CREATE TABLE productos (
    producto_id SERIAL PRIMARY KEY,
    nombre TEXT NOT NULL,
    -- Con el "CHECK" se valida que el precio sea mayor a 0 y el stock mayor o igual a 0.
	precio NUMERIC(10,2) NOT NULL CHECK (precio > 0), 
    stock INT NOT NULL CHECK (stock >= 0),
    categoria_id INT,
    -- Si se elimina una categoría, el producto se mantiene activo (SET NULL) para preservar su registro y stock físico en el inventario.
	FOREIGN KEY (categoria_id) REFERENCES categorias(categoria_id)
        ON DELETE SET NULL
);

-- Registro de la transacción de venta (quién y cuándo).
CREATE TABLE pedidos (
    pedido_id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL,
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    -- Se utiliza "RESTRICT" para proteger el historial de ventas: no se puede eliminar un cliente si ya tiene pedidos registrados.
	FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id)
        ON DELETE RESTRICT
);

-- Detalle de los productos incluidos en cada pedido.
-- La clave primaria compuesta evita duplicados dentro de un mismo pedido; si un cliente quiere más unidades, se incrementa la columna cantidad.
CREATE TABLE detalle_pedido (
    pedido_id INT,
    producto_id INT,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(10,2) NOT NULL CHECK (precio_unitario > 0),

    PRIMARY KEY (pedido_id, producto_id),

    -- Si se elimina un pedido, automáticamente se eliminan todos sus registros asociados en detalle_pedido (CASCADE).
	FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id)
        ON DELETE CASCADE,

    -- Evita eliminar productos que ya fueron vendidos, preservando la integridad del historial.
	FOREIGN KEY (producto_id) REFERENCES productos(producto_id)
        ON DELETE RESTRICT
);