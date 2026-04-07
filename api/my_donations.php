<?php
/**
 * My donations - Simple version
 */
require 'db.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    exit;
}

$email = isset($_GET['email']) ? trim($_GET['email']) : '';

if (empty($email)) {
    http_response_code(400);
    echo json_encode(['error' => 'Email required']);
    exit;
}

// Validate email format to prevent enumeration
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid email format']);
    exit;
}

// Check if payment_method column exists
$hasPaymentMethod = false;
$checkCol = $conn->query("SHOW COLUMNS FROM donations LIKE 'payment_method'");
if ($checkCol && $checkCol->num_rows > 0) {
    $hasPaymentMethod = true;
}

$paymentField = $hasPaymentMethod ? ", d.payment_method" : ", '' AS payment_method";

$stmt = $conn->prepare("
    SELECT d.id, d.receipt_id, d.amount, d.status, d.donated_at, c.title AS campaign_title{$paymentField}
    FROM donations d
    JOIN campaigns c ON d.campaign_id = c.id
    WHERE d.donor_email = ?
    ORDER BY d.donated_at DESC
");
$stmt->bind_param('s', $email);
$stmt->execute();
$result = $stmt->get_result();

$donations = [];
while ($row = $result->fetch_assoc()) {
    $row['amount'] = (float)$row['amount'];
    $donations[] = $row;
}

$stmt->close();
echo json_encode($donations);
$conn->close();
