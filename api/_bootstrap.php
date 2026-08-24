<?php
declare(strict_types=1);

require_once __DIR__ . '/../config/database.php';

session_start();
header('Content-Type: application/json; charset=utf-8');
header('X-Content-Type-Options: nosniff');

function json_input(): array
{
    $input = json_decode(file_get_contents('php://input'), true);
    return is_array($input) ? $input : $_POST;
}

function respond(array $data, int $status = 200): never
{
    http_response_code($status);
    echo json_encode($data, JSON_UNESCAPED_UNICODE);
    exit;
}

function require_login(): array
{
    if (empty($_SESSION['user'])) {
        respond(['error' => 'Debes iniciar sesión.'], 401);
    }
    return $_SESSION['user'];
}

function require_admin(): array
{
    $user = require_login();
    if (($user['role'] ?? '') !== 'admin') {
        respond(['error' => 'No tienes permisos de administrador.'], 403);
    }
    return $user;
}
