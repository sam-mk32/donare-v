<?php
/**
 * User signup - Simple version with validation
 */
require_once 'db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true);

if (!$data) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid JSON']);
    exit;
}

// Honeypot check (bot protection)
if (!empty($data['website'])) {
    // Bots often fill hidden fields - silently reject with fake success
    echo json_encode(['success' => true, 'id' => 0, 'name' => '', 'email' => '', 'role' => 'user']);
    exit;
}

$name = trim($data['name'] ?? '');
$email = trim($data['email'] ?? '');
$password = $data['password'] ?? '';

if (empty($name) || empty($email) || empty($password)) {
    http_response_code(400);
    echo json_encode(['error' => 'Name, email and password are required']);
    exit;
}

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid email format']);
    exit;
}

// Password validation
$passwordErrors = [];
if (strlen($password) < 6) {
    $passwordErrors[] = 'Password must be at least 6 characters';
}

if (!empty($passwordErrors)) {
    http_response_code(400);
    echo json_encode(['error' => $passwordErrors[0], 'errors' => $passwordErrors]);
    exit;
}

// Sanitize name for XSS (email is validated, password is hashed)
$name = htmlspecialchars($name, ENT_QUOTES, 'UTF-8');

// Check if email exists in any user table
$tables = ['users', 'trustees', 'admins'];
foreach ($tables as $table) {
    $check = $conn->prepare("SELECT id FROM `$table` WHERE email = ?");
    $check->bind_param('s', $email);
    $check->execute();
    if ($check->get_result()->num_rows > 0) {
        http_response_code(400);
        echo json_encode(['error' => 'Email already registered']);
        $check->close();
        $conn->close();
        exit;
    }
    $check->close();
}

// Hash password and insert (users table only has: id, name, email, password, role, ngo_name, created_at)
$hashedPassword = password_hash($password, PASSWORD_DEFAULT);
$stmt = $conn->prepare("INSERT INTO users (name, email, password) VALUES (?, ?, ?)");
$stmt->bind_param('sss', $name, $email, $hashedPassword);

if ($stmt->execute()) {
    echo json_encode([
        'success' => true,
        'id' => $conn->insert_id,
        'name' => $name,
        'email' => $email,
        'role' => 'user'
    ]);
} else {
    http_response_code(500);
    echo json_encode(['error' => 'Registration failed', 'detail' => $stmt->error]);
}

$stmt->close();
$conn->close();
