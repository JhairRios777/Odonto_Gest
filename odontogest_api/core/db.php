<?php
// ── Conexión PDO — OdontoGest API ─────────────────────────────
// Copiar toda la carpeta odontogest_api a: C:\xampp\htdocs\odontogest_api\

define('DB_HOST', 'localhost');
define('DB_NAME', 'odonto_gest');
define('DB_USER', 'root');
define('DB_PASS', '');       // XAMPP por defecto no tiene contraseña
define('DB_PORT', '3306');

function getDB(): PDO {
    static $pdo = null;
    if ($pdo !== null) return $pdo;

    $dsn = 'mysql:host=' . DB_HOST
         . ';port='      . DB_PORT
         . ';dbname='    . DB_NAME
         . ';charset=utf8mb4';

    $pdo = new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
    ]);

    return $pdo;
}
