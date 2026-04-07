<?php
/**
 * Bootstrap file for API endpoints
 * 
 * Include this file at the top of each API endpoint for:
 * - Autoloading
 * - CORS handling
 * - Database connection
 * - Common headers
 */

// Register autoloader
spl_autoload_register(function ($class) {
    // Convert namespace to file path
    $prefix = 'Donare\\';
    $baseDir = __DIR__ . '/../src/';

    $len = strlen($prefix);
    if (strncmp($prefix, $class, $len) !== 0) {
        return;
    }

    $relativeClass = substr($class, $len);
    $file = $baseDir . str_replace('\\', '/', $relativeClass) . '.php';

    if (file_exists($file)) {
        require $file;
    }
});

// Load environment variables from .env if it exists
$envFile = __DIR__ . '/../.env';
if (file_exists($envFile)) {
    $lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos($line, '#') === 0) continue;
        if (strpos($line, '=') === false) continue;
        list($key, $value) = explode('=', $line, 2);
        $key = trim($key);
        $value = trim($value);
        // Remove quotes
        $value = trim($value, '"\'');
        putenv("$key=$value");
        $_ENV[$key] = $value;
    }
}

// Apply CORS middleware
\Donare\Api\Middleware\CorsMiddleware::apply();

// Set JSON content type
header('Content-Type: application/json');

// Get database connection
function getDbConnection(): mysqli {
    return \Donare\Core\Database::getConnection();
}

// Shorthand for connection (backward compatibility)
$conn = getDbConnection();
