<?php
/**
 * Support ticket submission - with proper validation
 */
require 'db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
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
    // Bots often fill hidden fields - silently reject
    echo json_encode(['success' => true]);
    exit;
}

$name = trim($data['name'] ?? '');
$email = trim($data['email'] ?? '');
$phone = trim($data['phone'] ?? '');
$cat = trim($data['category'] ?? '');
$message = trim($data['message'] ?? '');

if (empty($name) || empty($email) || empty($phone) || empty($cat) || empty($message)) {
    http_response_code(400);
    echo json_encode(['error' => 'All fields are required']);
    exit;
}

// Validate email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid email format']);
    exit;
}

// Validate category - matches HTML form options
$validCategories = [
    'General Enquiry',
    'Donation Issue', 
    'Receipt / Tax',
    'Campaign Feedback',
    'Partnership',
    'Technical Problem',
    'Other'
];
if (!in_array($cat, $validCategories)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid category. Please select a valid option.']);
    exit;
}

// Sanitize inputs (XSS prevention - database uses prepared statements for SQL injection)
$name = htmlspecialchars($name, ENT_QUOTES, 'UTF-8');
$phone = htmlspecialchars($phone, ENT_QUOTES, 'UTF-8');
$message = htmlspecialchars($message, ENT_QUOTES, 'UTF-8');

$stmt = $conn->prepare("
    INSERT INTO support_messages (name, email, phone, category, message, status)
    VALUES (?, ?, ?, ?, ?, 'Pending')
");

if (!$stmt) {
    http_response_code(500);
    echo json_encode(['error' => 'Database error. Please try again later.']);
    $conn->close();
    exit;
}

$stmt->bind_param('sssss', $name, $email, $phone, $cat, $message);

if (!$stmt->execute()) {
    http_response_code(500);
    echo json_encode(['error' => 'Could not submit your message. Please try again.']);
    $stmt->close();
    $conn->close();
    exit;
}

$stmt->close();
echo json_encode(['success' => true]);
$conn->close();
