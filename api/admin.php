<?php
declare(strict_types=1);
require_once __DIR__ . '/_bootstrap.php';
require_admin();
$pdo = db();
$stats = [
    'menuItems' => (int)$pdo->query('SELECT COUNT(*) FROM menu_items WHERE available = 1')->fetchColumn(),
    'ordersToday' => (int)$pdo->query("SELECT COUNT(*) FROM orders WHERE DATE(created_at) = CURDATE()")->fetchColumn(),
    'salesToday' => (int)$pdo->query("SELECT COALESCE(SUM(total), 0) FROM orders WHERE DATE(created_at) = CURDATE() AND status <> 'cancelled'")->fetchColumn(),
];
$orders = $pdo->query("SELECT o.id, o.customer_name, o.total, o.status, o.created_at, GROUP_CONCAT(CONCAT(mi.name, ' x', oi.quantity) SEPARATOR ', ') products FROM orders o JOIN order_items oi ON oi.order_id = o.id JOIN menu_items mi ON mi.id = oi.menu_item_id GROUP BY o.id ORDER BY o.created_at DESC LIMIT 20")->fetchAll();
respond(['stats' => $stats, 'orders' => $orders]);
