<?php
declare(strict_types=1);
require_once __DIR__ . '/_bootstrap.php';
respond(['user' => $_SESSION['user'] ?? null]);
