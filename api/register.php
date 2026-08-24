<?php
declare(strict_types=1);
require_once __DIR__ . '/_bootstrap.php';

$data = json_input();
$name = trim((string)($data['name'] ?? ''));
$email = strtolower(trim((string)($data['email'] ?? '')));
$password = (string)($data['password'] ?? '');

if ($name === '' || !filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($password) < 8) {
    respond(['error' => 'Nombre, correo válido y contraseña de mínimo 8 caracteres son obligatorios.'], 422);
}

try {
    $statement = db()->prepare('INSERT INTO users (name, email, password_hash) VALUES (?, ?, ?)');
    $statement->execute([$name, $email, password_hash($password, PASSWORD_DEFAULT)]);
    $user = ['id' => (int)db()->lastInsertId(), 'name' => $name, 'email' => $email, 'role' => 'customer'];
    $_SESSION['user'] = $user;
    respond(['user' => $user], 201);
} catch (PDOException $error) {
    if ($error->errorInfo[1] ?? null === 1062) {
        respond(['error' => 'Ese correo ya está registrado.'], 409);
    }
    respond(['error' => 'No se pudo crear la cuenta.'], 500);
}
