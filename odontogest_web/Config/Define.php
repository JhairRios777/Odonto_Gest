<?php
// ── Constantes globales del panel web OdontoGest ─────────────

define('APP_NAME',    'OdontoGest');
define('APP_VERSION', '1.0.0');

// URL base — ajustar si el alias de XAMPP cambia
define('APP_URL', 'http://localhost:9015/');

// Rutas absolutas
define('ROOT_PATH',     __DIR__ . '/../');
define('TEMPLATE_PATH', ROOT_PATH . 'Template/Default/');
define('VIEW_PATH',     ROOT_PATH . 'Views/');

// Base de datos (misma BD que la API móvil)
define('DB_HOST', 'localhost');
define('DB_NAME', 'odonto_gest');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_PORT', 3306);

// Sesión
define('SESSION_NAME',     'og_web_sess');
define('SESSION_LIFETIME', 0);          // expira al cerrar browser
define('SESSION_TIMEOUT',  7200);       // 2 h de inactividad

// Rutas públicas (sin login)
define('PUBLIC_ROUTES', ['auth']);

// Métodos que devuelven JSON (no cargan template)
define('JSON_METHODS', [
    'toggle', 'delete', 'save', 'buscar', 'cambiarEstado',
    'procesarLogin', 'logout', 'obtener', 'marcarLeida',
    'marcarTodas', 'resetPassword', 'toggleEstado',
]);
