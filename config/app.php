<?php
/**
 * Application Configuration
 * 
 * General application settings and constants.
 */

return [
    'name' => 'Donare',
    'version' => '1.0.0',
    'env' => getenv('APP_ENV') ?: 'development',
    'debug' => getenv('APP_DEBUG') ?: true,
    'url' => getenv('APP_URL') ?: 'http://localhost/donare-v',
    'timezone' => 'Asia/Kuala_Lumpur',

    'upload' => [
        'path' => __DIR__ . '/../public/uploads',
        'max_size' => 5 * 1024 * 1024, // 5MB
        'allowed_types' => ['image/jpeg', 'image/png', 'image/gif', 'image/webp'],
    ],

    'donation' => [
        'max_amount' => 10000,
        'currency' => 'MYR',
        'currency_symbol' => 'RM',
    ],

    'paths' => [
        'root' => dirname(__DIR__),
        'public' => dirname(__DIR__) . '/public',
        'storage' => dirname(__DIR__) . '/storage',
        'config' => __DIR__,
        'src' => dirname(__DIR__) . '/src',
    ],
];
