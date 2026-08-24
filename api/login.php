<?php
declare(strict_types=1);
require_once __DIR__ . '/_bootstrap.php';

$data = json_input();
$email = strtolower(trim((string)($data['email'] ?? '')));
$password = (string)($data['password'] ?? '');

if (!filter_var($email, FILTER_VALIDATE_EMAIL) || $password === '') {
    respond(['error' => 'Correo y contraseña son obligatorios.'], 422);
}

$statement = db()->prepare('SELECT id, name, email, password_hash, role FROM users WHERE email = ? AND active = 1 LIMIT 1');
$statement->execute([$email]);
$user = $statement->fetch();
$valid = $user && password_verify($password, $user['password_hash']);
if (!$valid && $user && strlen($user['password_hash']) === 64) {
    $valid = hash_equals($user['password_hash'], hash('sha256', $password));
}
if (!$valid) {
    respond(['error' => 'Correo o contraseña incorrectos.'], 401);
}

unset($user['password_hash']);
session_regenerate_id(true);
$_SESSION['user'] = ['id' => (int)$user['id'], 'name' => $user['name'], 'email' => $user['email'], 'role' => $user['role']];
respond(['user' => $_SESSION['user']]);
