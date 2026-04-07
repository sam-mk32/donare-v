<?php
/**
 * Trustee Dashboard API Endpoint
 * 
 * GET: Returns campaigns, history, and donations for an NGO
 */
require_once 'bootstrap.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    // Accept either 'ngo' or 'email' parameter for flexibility
    $ngoName = isset($_GET['ngo']) ? trim(urldecode($_GET['ngo'])) : '';
    $email = isset($_GET['email']) ? trim($_GET['email']) : '';
    
    // If ngo name provided directly, use it
    if (!empty($ngoName)) {
        // Validate ngo exists
        $stmt = $conn->prepare("SELECT id, name FROM ngos WHERE name = ?");
        $stmt->bind_param('s', $ngoName);
        $stmt->execute();
        $ngo = $stmt->get_result()->fetch_assoc();
        $stmt->close();
        
        if (!$ngo) {
            echo json_encode(['campaigns' => [], 'history' => [], 'donations' => []]);
            $conn->close();
            exit;
        }
    } elseif (!empty($email)) {
        // Get trustee's NGO from email
        $stmt = $conn->prepare("SELECT ngo_name FROM trustees WHERE email = ?");
        $stmt->bind_param('s', $email);
        $stmt->execute();
        $trustee = $stmt->get_result()->fetch_assoc();
        $stmt->close();

        if (!$trustee) {
            http_response_code(404);
            echo json_encode(['error' => 'Trustee not found']);
            $conn->close();
            exit;
        }
        
        $ngoName = $trustee['ngo_name'];

        // Get NGO ID
        $stmt2 = $conn->prepare("SELECT id, name FROM ngos WHERE name = ?");
        $stmt2->bind_param('s', $ngoName);
        $stmt2->execute();
        $ngo = $stmt2->get_result()->fetch_assoc();
        $stmt2->close();

        if (!$ngo) {
            echo json_encode(['campaigns' => [], 'history' => [], 'donations' => []]);
            $conn->close();
            exit;
        }
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'NGO name or email required']);
        $conn->close();
        exit;
    }

    $ngoId = $ngo['id'];

    // Ensure max_donation column exists
    $checkCol = $conn->query("SHOW COLUMNS FROM campaigns LIKE 'max_donation'");
    if ($checkCol && $checkCol->num_rows === 0) {
        $conn->query("ALTER TABLE campaigns ADD COLUMN max_donation DECIMAL(12,2) NULL DEFAULT NULL");
    }

    // Get campaigns for this NGO
    $stmt3 = $conn->prepare("
        SELECT id, title, category, goal, raised, donors, days_left, image_url, description, is_active, max_donation
        FROM campaigns
        WHERE ngo_id = ?
        ORDER BY id ASC
    ");
    $stmt3->bind_param('i', $ngoId);
    $stmt3->execute();
    $result = $stmt3->get_result();

    $campaigns = [];
    while ($row = $result->fetch_assoc()) {
        $row['goal'] = (float)$row['goal'];
        $row['raised'] = (float)$row['raised'];
        $row['donors'] = (int)$row['donors'];
        $row['max_donation'] = $row['max_donation'] !== null ? (float)$row['max_donation'] : null;
        $campaigns[] = $row;
    }
    $stmt3->close();

    // Get history records for this NGO
    $history = [];
    $historyCheck = $conn->query("SHOW TABLES LIKE 'ngo_history'");
    if ($historyCheck && $historyCheck->num_rows > 0) {
        $stmt4 = $conn->prepare("
            SELECT year, title, raised, distributed, beneficiaries, period, note
            FROM ngo_history
            WHERE ngo_id = ?
            ORDER BY year DESC, id DESC
        ");
        $stmt4->bind_param('i', $ngoId);
        $stmt4->execute();
        $histResult = $stmt4->get_result();
        while ($row = $histResult->fetch_assoc()) {
            $row['raised'] = (float)$row['raised'];
            $row['distributed'] = (float)$row['distributed'];
            $history[] = $row;
        }
        $stmt4->close();
    }

    // Get recent donations for campaigns of this NGO
    $donations = [];
    $campaignIds = array_column($campaigns, 'id');
    if (!empty($campaignIds)) {
        $placeholders = implode(',', array_fill(0, count($campaignIds), '?'));
        $types = str_repeat('i', count($campaignIds));
        
        $stmt5 = $conn->prepare("
            SELECT d.donor_name AS donor, d.amount, d.donated_at AS date, d.status
            FROM donations d
            WHERE d.campaign_id IN ($placeholders)
            ORDER BY d.donated_at DESC
            LIMIT 50
        ");
        $stmt5->bind_param($types, ...$campaignIds);
        $stmt5->execute();
        $donResult = $stmt5->get_result();
        while ($row = $donResult->fetch_assoc()) {
            $row['amount'] = (float)$row['amount'];
            $donations[] = $row;
        }
        $stmt5->close();
    }

    echo json_encode([
        'campaigns' => $campaigns,
        'history' => $history,
        'donations' => $donations
    ]);

} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}

$conn->close();
