<?php
// ── Validación de Bearer Token ────────────────────────────────
// El token tiene formato base64(id_usuario|rol|timestamp|random)
// En producción reemplazar por JWT con firma HMAC

require_once __DIR__ . '/Response.php';

function getAuthUser(): array {
    $header = $_SERVER['HTTP_AUTHORIZATION']
           ?? apache_request_headers()['Authorization']
           ?? '';

    if (!str_starts_with($header, 'Bearer ')) {
        error(401, 'Token requerido');
    }

    $token   = substr($header, 7);
    $decoded = base64_decode($token, true);

    if (!$decoded) {
        error(401, 'Token inválido');
    }

    $parts = explode('|', $decoded, 4);
    if (count($parts) < 3) {
        error(401, 'Token malformado');
    }

    return [
        'id_usuario' => (int) $parts[0],
        'rol'        => $parts[1],
        'timestamp'  => (int) $parts[2],
    ];
}

// Aplica CORS y sale si es preflight OPTIONS
function corsHeaders(): void {
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Headers: Content-Type, Authorization');
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(204);
        exit;
    }
}
