<?php
/**
 * NGO History API Endpoint
 * 
 * GET: Retrieve historical data for an NGO
 */
require_once 'bootstrap.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed.']);
    exit;
}

$ngoName = trim($_GET['ngo_name'] ?? '');

if (!$ngoName) {
    http_response_code(400);
    echo json_encode(['error' => 'NGO name is required.']);
    exit;
}

// Get ngo_id from name
$stmt = $conn->prepare("SELECT id FROM ngos WHERE name = ?");
$stmt->bind_param('s', $ngoName);
$stmt->execute();
$result = $stmt->get_result();
$ngo = $result->fetch_assoc();
$stmt->close();

if (!$ngo) {
    echo json_encode([]);
    exit;
}

$ngoId = $ngo['id'];

// Get historical campaigns for this NGO
$stmt = $conn->prepare("
    SELECT year, title, raised, distributed, beneficiaries, period, note
    FROM ngo_history
    WHERE ngo_id = ?
    ORDER BY year DESC, id DESC
");
$stmt->bind_param('i', $ngoId);
$stmt->execute();
$result = $stmt->get_result();

$history = [];
while ($row = $result->fetch_assoc()) {
    $row['raised'] = (float) $row['raised'];
    $row['distributed'] = (float) $row['distributed'];
    $history[] = $row;
}

$stmt->close();
$conn->close();

echo json_encode($history);
