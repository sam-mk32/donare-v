<?php
/**
 * Database Connection Class
 * 
 * Provides a singleton database connection with proper configuration management.
 */

namespace Donare\Core;

use mysqli;
use Exception;

class Database
{
    private static ?Database $instance = null;
    private mysqli $connection;
    private array $config;

    private function __construct()
    {
        $this->loadConfig();
        $this->connect();
    }

    public static function getInstance(): Database
    {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    public static function getConnection(): mysqli
    {
        return self::getInstance()->connection;
    }

    private function loadConfig(): void
    {
        $configPath = dirname(__DIR__, 2) . '/config/database.php';
        
        if (!file_exists($configPath)) {
            throw new Exception('Database configuration file not found.');
        }

        $config = require $configPath;
        $connectionName = $this->isProduction() ? 'production' : 'mysql';
        $this->config = $config['connections'][$connectionName];
    }

    private function isProduction(): bool
    {
        $serverName = $_SERVER['SERVER_NAME'] ?? 'localhost';
        $httpHost = $_SERVER['HTTP_HOST'] ?? '';
        
        return $serverName !== 'localhost' && 
               strpos($httpHost, 'localhost') === false;
    }

    private function connect(): void
    {
        $this->connection = new mysqli(
            $this->config['host'],
            $this->config['username'],
            $this->config['password'],
            $this->config['database']
        );

        if ($this->connection->connect_error) {
            throw new Exception('Database connection failed: ' . $this->connection->connect_error);
        }

        $this->connection->set_charset($this->config['charset']);
    }

    public function query(string $sql): mixed
    {
        return $this->connection->query($sql);
    }

    public function prepare(string $sql): \mysqli_stmt|false
    {
        return $this->connection->prepare($sql);
    }

    public function escape(string $value): string
    {
        return $this->connection->real_escape_string($value);
    }

    public function getLastInsertId(): int
    {
        return (int) $this->connection->insert_id;
    }

    public function getAffectedRows(): int
    {
        return (int) $this->connection->affected_rows;
    }

    public function beginTransaction(): bool
    {
        return $this->connection->begin_transaction();
    }

    public function commit(): bool
    {
        return $this->connection->commit();
    }

    public function rollback(): bool
    {
        return $this->connection->rollback();
    }

    public function close(): void
    {
        $this->connection->close();
    }

    // Prevent cloning
    private function __clone() {}

    // Prevent unserialization
    public function __wakeup()
    {
        throw new Exception("Cannot unserialize singleton");
    }
}
