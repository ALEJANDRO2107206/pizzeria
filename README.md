# Forno Vivo

## Entrega final con XAMPP

1. Copia esta carpeta en `C:/xampp/htdocs/proyecto`.
2. Inicia **Apache** y **MySQL** desde XAMPP.
3. Entra en phpMyAdmin e importa [database/forno_vivo.sql](database/forno_vivo.sql).
4. Abre `http://localhost/proyecto/`.

## Funcionalidades

- Carta de pizzas y carrito de compra.
- Seleccion de Nequi, PSE, Google Pay, Visa y Mastercard.
- Registro e inicio de sesion con sesiones PHP.
- Cuenta de cliente para consultar pedidos.
- Panel administrativo protegido por rol.
- Creacion de pedidos con precios tomados desde MySQL.

## Estructura

- `index.html`: interfaz principal.
- `css/`: estilos visuales.
- `js/`: comportamiento del carrito y filtros.
- `api/`: endpoints PHP de login, registro, pedidos y administracion.
- `config/database.php`: conexion PDO a MySQL.
- `database/forno_vivo.sql`: tablas y datos iniciales.

## Cuenta demo

Administrador: `admin@fornovivo.cl` / `Admin123!`

Cliente: `cliente@fornovivo.cl` / `Forno123!`
