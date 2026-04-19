# TP1: Sistema de Gestión de Pedidos, Stock y Clientes

## Desarrollador 👨‍💻 :

- **Desarrollador:** Matías Di Risio 👍
- **GitHub:** [DiriARG](https://github.com/DiriARG)

## Docente 👨‍🏫 :

- **Profesor:** Eduardo Leiva

## Tabla de contenidos 📚:

- [Instrucciones de Ejecución](#instrucciones-de-ejecución-)
- [Decisiones de Diseño y Normalización](#decisiones-de-diseño-y-normalización-️)

## Instrucciones de Ejecución 🚀:

Para recrear la base de datos completa, los archivos deben ejecutarse en el siguiente orden en un entorno **PostgreSQL**:

1. `schema.sql`: Crea la estructura de tablas, restricciones de integridad (PK, FK, UNIQUE, NOT NULL y CHECK) y relaciones.
2. `seed.sql`: Genera los datos de prueba (50 productos, 100 clientes y 200 pedidos con sus detalles).
3. `queries.sql`: Contiene las 13 consultas analíticas solicitadas.

## Decisiones de Diseño y Normalización 🏗️:

### Normalización

El modelo fue diseñado siguiendo los principios de la **Tercera Forma Normal (3NF)** para garantizar la integridad de los datos y eliminar redundancias:

- **1FN (Atomicidad)**: Todos los atributos contienen valores atómicos (nombres, correos, precios y fechas), sin listas, ni grupos repetitivos.
- **2FN (Dependencia Funcional)**: Se eliminaron las dependencias parciales mediante el uso de claves primarias simples (`producto_id`, `categoria_id`y `cliente_id`) y una clave primaria compuesta en **detalle_pedido** (`pedido_id`, `producto_id`), garantizando que todos los atributos no clave dependan de la clave primaria compuesta y no únicamente de una parte de ella.
- **3FN (Dependencia Transitiva)**: Se separaron las categorías en una tabla independiente, evitando que los atributos descriptivos de la categoría (como `nombre`) dependan transitivamente del ID del producto (`producto_id`). De esta forma, los atributos no clave dependen directamente de la clave primaria y no de otro atributo no clave.

### Integridad Referencial y Reglas de Negocio

Se implementaron acciones de `FOREIGN KEY` que reflejan el comportamiento de un sistema de gestión real:

- **ON DELETE RESTRICT** (en `clientes` y `productos`): Protege la integridad del historial contable, impidiendo borrar registros que ya tienen transacciones vinculadas.
- **ON DELETE CASCADE** (en `detalle_pedido`): Si un pedido se elimina, automáticamente se eliminan todos sus registros asociados para evitar "datos huérfanos" en el sistema.
- **ON DELETE SET NULL** (en `productos`): Si una categoría es dada de baja, los registros en la tabla de productos se mantienen activos pero su referencia se establece como nula ("sin clasificar"), preservando el registro del stock físico.
- **Restricciones de Dominio** (`CHECK`): Se validó a nivel de motor que el precio sea > 0 y el stock sea ≥ 0 para prevenir estados de inventario lógicamente imposibles.
