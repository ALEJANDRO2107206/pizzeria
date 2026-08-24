-- Base de datos Forno Vivo para MySQL/MariaDB y phpMyAdmin.
-- Importa este archivo completo desde la pestaña Importar.

CREATE DATABASE IF NOT EXISTS forno_vivo
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE forno_vivo;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS addresses;
DROP TABLE IF EXISTS menu_items;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE users (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(160) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('customer', 'admin') NOT NULL DEFAULT 'customer',
  active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email)
) ENGINE=InnoDB;

CREATE TABLE addresses (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  label VARCHAR(50) NOT NULL DEFAULT 'Casa',
  address VARCHAR(255) NOT NULL,
  city VARCHAR(100) NOT NULL DEFAULT 'Santiago',
  is_default TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_addresses_user (user_id),
  CONSTRAINT fk_addresses_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE menu_items (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  description VARCHAR(255) NOT NULL,
  price INT UNSIGNED NOT NULL,
  category ENUM('clasicas', 'vegetales', 'especiales') NOT NULL,
  image_url VARCHAR(500),
  available TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_menu_name (name)
) ENGINE=InnoDB;

CREATE TABLE orders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  address_id INT UNSIGNED NULL,
  customer_name VARCHAR(120) NOT NULL,
  customer_phone VARCHAR(30) NOT NULL,
  delivery_address VARCHAR(255) NOT NULL,
  total INT UNSIGNED NOT NULL,
  payment_method ENUM('Nequi', 'PSE', 'Google Pay', 'Visa', 'Mastercard') NOT NULL DEFAULT 'PSE',
  status ENUM('received', 'preparing', 'on_the_way', 'delivered', 'cancelled') NOT NULL DEFAULT 'received',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_orders_user (user_id),
  KEY idx_orders_status (status, created_at),
  CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_orders_address FOREIGN KEY (address_id) REFERENCES addresses(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE order_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  menu_item_id INT UNSIGNED NOT NULL,
  quantity SMALLINT UNSIGNED NOT NULL,
  unit_price INT UNSIGNED NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_order_item (order_id, menu_item_id),
  CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_items_menu FOREIGN KEY (menu_item_id) REFERENCES menu_items(id)
) ENGINE=InnoDB;

-- Cuenta de prueba: cliente@fornovivo.cl / Forno123!
-- Este hash SHA-256 sirve para la cuenta demo. Para usuarios nuevos usa password_hash() de PHP.
INSERT INTO users (name, email, password_hash, role) VALUES
('Cliente Demo', 'cliente@fornovivo.cl', SHA2('Forno123!', 256), 'customer'),
('Administrador Forno Vivo', 'admin@fornovivo.cl', SHA2('Admin123!', 256), 'admin');

INSERT INTO addresses (user_id, label, address, city, is_default) VALUES
(1, 'Casa', 'Av. Italia 1420, Providencia', 'Santiago', 1);

INSERT INTO menu_items (name, description, price, category, image_url) VALUES
('Margherita', 'Pomodoro, fior di latte, albahaca fresca y aceite de oliva.', 12900, 'clasicas', 'https://images.unsplash.com/photo-1579751626657-72bc17010498?auto=format&fit=crop&w=700&q=85'),
('Diavola', 'Salame picante, mozzarella, tomate y miel de aji fermentado.', 14900, 'especiales', 'https://images.unsplash.com/photo-1593560708920-61dd98c8c6d3?auto=format&fit=crop&w=700&q=85'),
('Orto', 'Verduras de estacion, stracciatella, limon y hierbas del huerto.', 14500, 'vegetales', 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&fit=crop&w=700&q=85'),
('Prosciutto', 'Prosciutto di Parma, mozzarella, rucula y parmesano.', 16900, 'clasicas', 'https://images.unsplash.com/photo-1566843972142-a7fcb70de55a?auto=format&fit=crop&w=700&q=85'),
('Bianca', 'Crema de ajo, mozzarella, hongos, tomillo y aceite de trufa.', 15900, 'especiales', 'https://images.unsplash.com/photo-1571407970349-bc81e7e96d47?auto=format&fit=crop&w=700&q=85'),
('Pomodoro', 'Tomates confitados, burrata, albahaca y pimienta negra.', 13900, 'vegetales', 'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&w=700&q=85');

INSERT INTO orders (user_id, address_id, customer_name, customer_phone, delivery_address, total, status) VALUES
(1, 1, 'Cliente Demo', '+56912345678', 'Av. Italia 1420, Providencia, Santiago', 25800, 'received');

INSERT INTO order_items (order_id, menu_item_id, quantity, unit_price) VALUES
(1, 1, 2, 12900);

CREATE OR REPLACE VIEW order_summary AS
SELECT o.id AS order_id, u.name AS customer, u.email, o.customer_phone,
       o.delivery_address, o.total, o.status, o.created_at,
       GROUP_CONCAT(CONCAT(mi.name, ' x', oi.quantity) ORDER BY mi.name SEPARATOR ', ') AS products
FROM orders o
JOIN users u ON u.id = o.user_id
JOIN order_items oi ON oi.order_id = o.id
JOIN menu_items mi ON mi.id = oi.menu_item_id
GROUP BY o.id, u.name, u.email, o.customer_phone, o.delivery_address, o.total, o.status, o.created_at;