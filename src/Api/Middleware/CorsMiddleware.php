<?php
/**
 * CORS Middleware
 * 
 * Handles Cross-Origin Resource Sharing headers for API requests.
 */

namespace Donare\Api\Middleware;

class CorsMiddleware
{
    private array $config;

    public function __construct()
    {
        $configPath = dirname(__DIR__, 3) . '/config/cors.php';
        $this->config = file_exists($configPath) ? require $configPath : $this->getDefaults();
    }

    private function getDefaults(): array
    {
        return [
            'allowed_origins' => ['*'],
            'allowed_methods' => ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
            'allowed_headers' => ['Content-Type', 'Authorization', 'X-Requested-With'],
            'exposed_headers' => [],
            'max_age' => 86400,
            'supports_credentials' => false,
        ];
    }

    public function handle(): void
    {
        $origin = $_SERVER['HTTP_ORIGIN'] ?? '*';

        if (in_array('*', $this->config['allowed_origins']) || in_array($origin, $this->config['allowed_origins'])) {
            header('Access-Control-Allow-Origin: ' . ($this->config['allowed_origins'][0] === '*' ? '*' : $origin));
        }

        header('Access-Control-Allow-Methods: ' . implode(', ', $this->config['allowed_methods']));
        header('Access-Control-Allow-Headers: ' . implode(', ', $this->config['allowed_headers']));

        if (!empty($this->config['exposed_headers'])) {
            header('Access-Control-Expose-Headers: ' . implode(', ', $this->config['exposed_headers']));
        }

        header('Access-Control-Max-Age: ' . $this->config['max_age']);

        if ($this->config['supports_credentials']) {
            header('Access-Control-Allow-Credentials: true');
        }

        // Handle preflight requests
        if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
            http_response_code(200);
            exit;
        }
    }

    public static function apply(): void
    {
        (new self())->handle();
    }
}
