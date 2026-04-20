# TP1: Sistema de Gestión de Pedidos, Stock y Clientes

## Desarrollador 👨‍💻:

- **Desarrollador:** Matías Di Risio 👍
- **GitHub:** [DiriARG](https://github.com/DiriARG)

## Docente 👨‍🏫:

- **Profesor:** Eduardo Leiva

## Tabla de contenidos 📚:

- [Instrucciones de ejecución](#instrucciones-de-ejecución-)
- [Decisiones de diseño y normalización](#decisiones-de-diseño-y-normalización-️)
- [Generación de datos](#generación-de-datos-)

## Instrucciones de ejecución 🚀:

Para recrear la base de datos completa, los archivos deben ejecutarse en el siguiente orden en un entorno **PostgreSQL**:

1. **schema.sql**: Crea la estructura de tablas, restricciones de integridad (PK, FK, UNIQUE, NOT NULL y CHECK) y relaciones.
2. **seed.sql**: Genera los datos de prueba (50 productos, 100 clientes y 200 pedidos con sus detalles).
3. **queries.sql**: Contiene las 13 consultas analíticas solicitadas.

## Decisiones de diseño y normalización 🏗️:

### Normalización

El modelo fue diseñado siguiendo los principios de la **Tercera Forma Normal (3NF)** para garantizar la integridad de los datos y eliminar redundancias:

- **1FN (Atomicidad)**: Todos los atributos contienen valores atómicos (nombres, correos, precios y fechas), sin listas, ni grupos repetitivos.
- **2FN (Dependencia Funcional)**: Se eliminaron las dependencias parciales mediante el uso de claves primarias simples (`producto_id`, `categoria_id`y `cliente_id`) y una clave primaria compuesta en **detalle_pedido** (`pedido_id`, `producto_id`), garantizando que todos los atributos no clave dependan de la clave primaria compuesta y no únicamente de una parte de ella.
- **3FN (Dependencia Transitiva)**: Se separaron las categorías en una tabla independiente, evitando que los atributos descriptivos de la categoría (como `nombre`) dependan transitivamente del ID del producto (`producto_id`). De esta forma, los atributos no clave dependen directamente de la clave primaria y no de otro atributo no clave.

### Integridad referencial y reglas de negocio

Se implementaron acciones de `FOREIGN KEY` que reflejan el comportamiento de un sistema de gestión real:

- **ON DELETE RESTRICT** (en `clientes` y `productos`): Protege la integridad del historial contable, impidiendo borrar registros que ya tienen transacciones vinculadas.
- **ON DELETE CASCADE** (en `detalle_pedido`): Si un pedido se elimina, automáticamente se eliminan todos sus registros asociados para evitar "datos huérfanos" en el sistema.
- **ON DELETE SET NULL** (en `productos`): Si una categoría es dada de baja, los registros en la tabla de productos se mantienen activos pero su referencia se establece como nula ("sin clasificar"), preservando el registro del stock físico.
- **Restricciones de Dominio** (`CHECK`): Se validó a nivel de motor que el precio sea > 0 y el stock sea ≥ 0 para prevenir estados de inventario lógicamente imposibles.

## Generación de datos 📊:

Para poblar la base de datos con información coherente y masiva, se utilizaron funciones nativas de PostgreSQL en el archivo **seed.sql**:

- **generate_series**: Se utilizó para la creación masiva de registros sintéticos (datos artificiales que imitan información real, sin provenir de usuarios ni eventos reales), permitiendo escalar el volumen de datos de forma automática.
- **floor(random() \* N + 1)**: Se aplicó para generar valores enteros aleatorios en el rango `[1, N]`, a partir de números decimales generados por `random()`, manteniendo una distribución uniforme.
- **Casteo de tipos (::int / ::numeric)**: Se utilizaron conversiones explícitas para ajustar el resultado de funciones como random() al tipo de dato definido en el **schema.sql**, garantizando compatibilidad con la estructura de la base de datos.
- **CROSS JOIN LATERAL**: Utilizado para el detalle de los pedidos. Esto permite que cada pedido contenga múltiples productos distintos (3 por pedido), simulando un comportamiento de compra real y permitiendo que las consultas de agregación (`SUM`, `AVG`) tengan sentido estadístico.
