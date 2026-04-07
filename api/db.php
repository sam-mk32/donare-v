<?php
/**
 * Database connection - Simple version
 */

// Auto-detect environment
$isLocal = (
    $_SERVER['SERVER_NAME'] === 'localhost' ||
    strpos($_SERVER['HTTP_HOST'] ?? '', 'localhost') !== false
);

if ($isLocal) {
    define('DB_HOST', 'localhost');
    define('DB_USER', 'root');
    define('DB_PASS', '');
    define('DB_NAME', 'donare_db');
} else {
    // Production settings - update these for your hosting
    define('DB_HOST', 'sql301.infinityfree.com');
    define('DB_USER', 'if0_41567144');
    define('DB_PASS', '42258447');
    define('DB_NAME', 'if0_41567144_donare_db');
}

// Handle CORS preflight
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type');
    http_response_code(200);
    exit;
}

$conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);

if ($conn->connect_error) {
    http_response_code(500);
    die(json_encode(['error' => 'Database connection failed.']));
}

$conn->set_charset('utf8mb4');

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
?>