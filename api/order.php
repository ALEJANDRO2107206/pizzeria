<?php
declare(strict_types=1);
require_once __DIR__ . '/_bootstrap.php';
$user = require_login();
$data = json_input();
$name = trim((string)($data['customerName'] ?? $user['name']));
$phone = trim((string)($data['customerPhone'] ?? ''));
$address = trim((string)($data['deliveryAddress'] ?? ''));
$payment = trim((string)($data['paymentMethod'] ?? ''));
$items = $data['items'] ?? [];
$allowedPayments = ['Nequi', 'PSE', 'Google Pay', 'Visa', 'Mastercard'];

if ($name === '' || $phone === '' || $address === '' || !in_array($payment, $allowedPayments, true) || !is_array($items) || count($items) === 0) {
    respond(['error' => 'Completa tus datos, método de pago y productos.'], 422);
}

try {
    $ids = array_map(static fn ($item): int => (int)($item['menuItemId'] ?? 0), $items);
    if (in_array(0, $ids, true)) respond(['error' => 'Producto inválido.'], 422);
    $placeholders = implode(',', array_fill(0, count($ids), '?'));
    $statement = db()->prepare("SELECT id, price FROM menu_items WHERE available = 1 AND id IN ($placeholders)");
    $statement->execute($ids);
    $prices = [];
    foreach ($statement->fetchAll() as $item) $prices[(int)$item['id']] = (int)$item['price'];
    $normalized = [];
    $total = 0;
    foreach ($items as $item) {
        $id = (int)($item['menuItemId'] ?? 0);
        $quantity = (int)($item['quantity'] ?? 0);
        if (!isset($prices[$id]) || $quantity < 1 || $quantity > 20) respond(['error' => 'Cantidad o producto inválido.'], 422);
        $normalized[] = [$id, $quantity, $prices[$id]];
        $total += $prices[$id] * $quantity;
    }
    $pdo = db();
    $pdo->beginTransaction();
    $order = $pdo->prepare('INSERT INTO orders (user_id, customer_name, customer_phone, delivery_address, total, payment_method, status) VALUES (?, ?, ?, ?, ?, ?, ?)');
    $order->execute([$user['id'], $name, $phone, $address, $total, $payment, 'received']);
    $orderId = (int)$pdo->lastInsertId();
    $line = $pdo->prepare('INSERT INTO order_items (order_id, menu_item_id, quantity, unit_price) VALUES (?, ?, ?, ?)');
    foreach ($normalized as [$id, $quantity, $price]) $line->execute([$orderId, $id, $quantity, $price]);
    $pdo->commit();
    respond(['orderId' => $orderId, 'total' => $total, 'paymentMethod' => $payment, 'status' => 'received'], 201);
} catch (Throwable $error) {
    if (isset($pdo) && $pdo->inTransaction()) $pdo->rollBack();
    respond(['error' => 'No se pudo guardar el pedido.'], 500);
}
