<?php
declare(strict_types=1);

session_start();
date_default_timezone_set('America/Lima');

$configFile = __DIR__ . '/../config/database.php';
if (!file_exists($configFile)) {
    http_response_code(500);
    exit('Falta configurar la conexión. Copia config/database.example.php como config/database.php y completa tus credenciales.');
}
$db = require $configFile;

$dsn = sprintf(
    'mysql:host=%s;dbname=%s;charset=%s',
    $db['host'],
    $db['database'],
    $db['charset'] ?? 'utf8mb4'
);

try {
    $pdo = new PDO($dsn, $db['username'], $db['password'], [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    exit('No se pudo conectar con MySQL. Revisa las credenciales de config/database.php.');
}

function e(?string $value): string {
    return htmlspecialchars((string)$value, ENT_QUOTES, 'UTF-8');
}
function money(float|string|null $value): string {
    return 'S/ ' . number_format((float)$value, 2);
}
function csrf_token(): string {
    if (empty($_SESSION['csrf'])) {
        $_SESSION['csrf'] = bin2hex(random_bytes(32));
    }
    return $_SESSION['csrf'];
}
function verify_csrf(): void {
    if (!hash_equals($_SESSION['csrf'] ?? '', $_POST['csrf'] ?? '')) {
        http_response_code(419);
        exit('La sesión del formulario expiró. Regresa e inténtalo nuevamente.');
    }
}
function flash(string $type, string $message): void {
    $_SESSION['flash'] = ['type' => $type, 'message' => $message];
}
function redirect(string $url = 'index.php'): never {
    header('Location: ' . $url);
    exit;
}
function status_class(string $status): string {
    return match ($status) {
        'ATENDIDA', 'CONFIRMADA', 'ACTIVO', 'PAGADA' => 'success',
        'PROGRAMADA', 'PARCIAL' => 'warning',
        'CANCELADA', 'NO_ASISTIO', 'INACTIVO', 'SIN_PAGOS' => 'danger',
        default => 'neutral',
    };
}
