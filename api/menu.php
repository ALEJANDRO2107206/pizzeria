<?php
declare(strict_types=1);
require_once __DIR__ . '/_bootstrap.php';

$category = trim((string)($_GET['category'] ?? ''));
if ($category !== '') {
    $statement = db()->prepare('SELECT id, name, description, price, category, image_url FROM menu_items WHERE available = 1 AND category = ? ORDER BY id');
    $statement->execute([$category]);
    respond(['items' => $statement->fetchAll()]);
}
respond(['items' => db()->query('SELECT id, name, description, price, category, image_url FROM menu_items WHERE available = 1 ORDER BY id')->fetchAll()]);
