<?php
/**
 * Campaigns API Endpoint
 * 
 * GET: Retrieve all active campaigns
 */
require_once 'bootstrap.php';

// Global per-transaction limit (must match donate.php)
define('MAX_TRANSACTION_AMOUNT', 10000);

$sql = "
    SELECT c.id, c.title, c.category, c.goal, c.raised, c.donors,
           c.days_left, c.image_url, c.description, n.name AS ngo
    FROM campaigns c
    JOIN ngos n ON c.ngo_id = n.id
    WHERE c.is_active = 1
    ORDER BY c.id ASC
";

$result = $conn->query($sql);

if (!$result) {
    http_response_code(500);
    echo json_encode(['error' => 'Database query failed']);
    $conn->close();
    exit;
}

$campaigns = [];

while ($row = $result->fetch_assoc()) {
    $goal = (float) $row['goal'];
    $raised = (float) $row['raised'];
    $remaining = max(0, $goal - $raised);
    
    $row['goal'] = $goal;
    $row['raised'] = $raised;
    $row['donors'] = (int) $row['donors'];
    
    // Smart donation cap: user can donate up to remaining OR max transaction limit (whichever is lower)
    $row['remaining_to_goal'] = $remaining;
    $row['max_allowed_donation'] = min($remaining, MAX_TRANSACTION_AMOUNT);
    $row['goal_reached'] = ($remaining <= 0);
    $row['transaction_limit'] = MAX_TRANSACTION_AMOUNT;
    
    $campaigns[] = $row;
}

echo json_encode($campaigns);
$conn->close();