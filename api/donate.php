<?php
/**
 * Process donation - with smart donation caps and transaction limits
 * 
 * Features:
 * - Per-transaction limit: ₹10,000 max per payment
 * - Campaign goal cap: Cannot donate more than remaining amount to reach goal
 * - Goal reached: No donations accepted once campaign reaches 100%
 */
require 'db.php';

// Global per-transaction limit (industry standard for online donations)
define('MAX_TRANSACTION_AMOUNT', 10000);

/**
 * Add columns expected by this endpoint if an older DB is missing them.
 */
function ensure_donations_schema(mysqli $conn): void
{
    $need = [
        'user_id'         => 'INT NULL',
        'donor_phone'     => 'VARCHAR(30) NULL',
        'donor_address'   => 'TEXT NULL',
        'payment_method'  => 'VARCHAR(30) NULL',
        'payment_details' => 'TEXT NULL',
    ];
    $db   = $conn->real_escape_string(DB_NAME);
    $res  = $conn->query("
        SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = '{$db}' AND TABLE_NAME = 'donations'
    ");
    if (!$res) {
        return;
    }
    $have = [];
    while ($row = $res->fetch_assoc()) {
        $have[$row['COLUMN_NAME']] = true;
    }
    $parts = [];
    foreach ($need as $col => $def) {
        if (empty($have[$col])) {
            $parts[] = 'ADD COLUMN `' . str_replace('`', '', $col) . '` ' . $def;
        }
    }
    if ($parts) {
        $conn->query('ALTER TABLE donations ' . implode(', ', $parts));
    }
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed.']);
    exit;
}

// Parse JSON body
$body = json_decode(file_get_contents('php://input'), true);
if (!$body) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid JSON body.']);
    exit;
}

// Extract and validate fields
$campaignId = isset($body['campaign_id']) ? (int)$body['campaign_id'] : 0;
$donorName = trim($body['donor_name'] ?? '');
$donorEmail = trim($body['donor_email'] ?? '');
$donorPhone = trim($body['donor_phone'] ?? '');
$donorAddress = trim($body['donor_address'] ?? '');
$amount = isset($body['amount']) ? (float)$body['amount'] : 0;
$paymentMethod = trim($body['payment_method'] ?? '');
$paymentDetails = $body['payment_details'] ?? [];
$userId = isset($body['user_id']) ? (int)$body['user_id'] : null;

// Basic validation
if ($campaignId <= 0) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid campaign ID.']);
    exit;
}

if (empty($donorName)) {
    http_response_code(400);
    echo json_encode(['error' => 'Donor name is required.']);
    exit;
}

if (empty($donorEmail) || !filter_var($donorEmail, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(['error' => 'Valid email is required.']);
    exit;
}

if ($amount < 1) {
    http_response_code(400);
    echo json_encode(['error' => 'Minimum donation amount is ₹1.']);
    exit;
}

// Check per-transaction limit (₹10,000)
if ($amount > MAX_TRANSACTION_AMOUNT) {
    http_response_code(400);
    echo json_encode([
        'error' => 'Maximum donation per transaction is ₹' . number_format(MAX_TRANSACTION_AMOUNT) . '. For larger donations, please make multiple transactions.',
        'max_transaction' => MAX_TRANSACTION_AMOUNT,
        'code' => 'EXCEEDS_TRANSACTION_LIMIT'
    ]);
    exit;
}

if (!in_array($paymentMethod, ['Bank Transfer', 'Card Payment'])) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid payment method.']);
    exit;
}

// Sanitize payment details
if (is_array($paymentDetails)) {
    foreach ($paymentDetails as $key => $value) {
        if (!is_string($value) && !is_numeric($value)) {
            $paymentDetails[$key] = '';
        } else {
            $paymentDetails[$key] = htmlspecialchars((string)$value, ENT_QUOTES, 'UTF-8');
        }
    }
}

// Verify campaign exists, is active, and check goal status
$checkCampaign = $conn->prepare("SELECT id, goal, raised FROM campaigns WHERE id = ? AND is_active = 1");
$checkCampaign->bind_param('i', $campaignId);
$checkCampaign->execute();
$campaign = $checkCampaign->get_result()->fetch_assoc();
$checkCampaign->close();

if (!$campaign) {
    http_response_code(400);
    echo json_encode(['error' => 'Campaign not found or is no longer active.']);
    exit;
}

$goal = (float)$campaign['goal'];
$raised = (float)$campaign['raised'];
$remaining = $goal - $raised;

// Check if campaign goal is already reached
if ($remaining <= 0) {
    http_response_code(400);
    echo json_encode([
        'error' => 'This campaign has reached its funding goal. Thank you for your interest!',
        'goal_reached' => true,
        'code' => 'GOAL_REACHED'
    ]);
    exit;
}

// Check if donation amount exceeds remaining goal
if ($amount > $remaining) {
    http_response_code(400);
    echo json_encode([
        'error' => 'This campaign only needs ₹' . number_format($remaining) . ' more to reach its goal. Please reduce your donation amount.',
        'remaining_to_goal' => $remaining,
        'max_allowed' => min($remaining, MAX_TRANSACTION_AMOUNT),
        'code' => 'EXCEEDS_REMAINING_GOAL'
    ]);
    exit;
}

// Encode payment details as JSON (card numbers are already masked to last 4 digits by JS)
$paymentDetailsJson = json_encode($paymentDetails);

$receiptId = 'DNR-' . strtoupper(uniqid());

ensure_donations_schema($conn);

// Use transaction for data integrity
$conn->begin_transaction();

try {
    $stmt = $conn->prepare("
        INSERT INTO donations
            (receipt_id, user_id, donor_name, donor_email, donor_phone, donor_address,
             campaign_id, amount, payment_method, payment_details, status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Completed')
    ");
    if (!$stmt) {
        throw new Exception("Could not prepare statement: " . $conn->error);
    }

    $stmt->bind_param(
        'siisssidss',
        $receiptId,
        $userId,
        $donorName,
        $donorEmail,
        $donorPhone,
        $donorAddress,
        $campaignId,
        $amount,
        $paymentMethod,
        $paymentDetailsJson
    );
    
    if (!$stmt->execute()) {
        throw new Exception("Could not save donation: " . $stmt->error);
    }
    $stmt->close();

    // Update campaign totals
    $stmt2 = $conn->prepare("UPDATE campaigns SET raised = raised + ?, donors = donors + 1 WHERE id = ?");
    if (!$stmt2) {
        throw new Exception("Could not prepare update: " . $conn->error);
    }
    $stmt2->bind_param('di', $amount, $campaignId);
    if (!$stmt2->execute()) {
        throw new Exception("Could not update campaign: " . $stmt2->error);
    }
    $stmt2->close();

    $conn->commit();

    // Calculate new remaining after this donation
    $newRemaining = $remaining - $amount;
    $goalReached = $newRemaining <= 0;

    echo json_encode([
        'success'    => true,
        'receipt_id' => $receiptId,
        'amount'     => $amount,
        'goal_reached' => $goalReached,
        'remaining_to_goal' => max(0, $newRemaining),
    ]);

} catch (Exception $e) {
    $conn->rollback();
    http_response_code(500);
    echo json_encode(['error' => 'Could not process donation. Please try again.', 'detail' => $e->getMessage()]);
}

$conn->close();
