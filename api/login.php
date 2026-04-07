<?php
/**
 * Login API Endpoint
 * 
 * POST: Authenticate user and return session data
 */
require_once 'bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    exit;
}

$data = json_decode(file_get_contents('php://input'), true);

if (!$data || empty($data['email']) || empty($data['password'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Email and password required']);
    exit;
}

$email = trim($data['email']);
$password = $data['password'];

function tryLogin($conn, $table, $email, $password, $role) {
    $extraFields = ($table === 'trustees') ? ', ngo_name' : '';
    $stmt = $conn->prepare("SELECT id, name, password{$extraFields} FROM `$table` WHERE email = ?");
    if (!$stmt) return null;
    
    $stmt->bind_param('s', $email);
    $stmt->execute();
    $row = $stmt->get_result()->fetch_assoc();
    $stmt->close();
    
    if (!$row || !password_verify($password, $row['password'])) {
        return null;
    }
    
    return [
        'id' => $row['id'],
        'name' => $row['name'],
        'email' => $email,
        'role' => $role,
        'ngo_name' => $row['ngo_name'] ?? null,
    ];
}

$user = tryLogin($conn, 'admins', $email, $password, 'admin')
     ?? tryLogin($conn, 'trustees', $email, $password, 'trustee')
     ?? tryLogin($conn, 'users', $email, $password, 'user');

if (!$user) {
    http_response_code(401);
    echo json_encode(['error' => 'Invalid email or password']);
    $conn->close();
    exit;
}

echo json_encode([
    'success' => true,
    'id' => $user['id'],
    'name' => $user['name'],
    'email' => $user['email'],
    'role' => $user['role'],
    'ngo_name' => $user['ngo_name'],
]);

$conn->close();
