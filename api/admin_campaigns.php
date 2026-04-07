<?php
/**
 * Admin Campaign Management API Endpoint
 * 
 * GET: Retrieve all campaigns (including inactive)
 * POST: Create a new campaign
 * PUT: Update an existing campaign
 * DELETE: Delete/deactivate a campaign
 */
require_once 'bootstrap.php';

$method = $_SERVER['REQUEST_METHOD'];

// Handle POST tunnelling for PUT/DELETE
$rawBody = file_get_contents('php://input');
$body = json_decode($rawBody, true) ?? [];

if ($method === 'POST' && isset($body['_method'])) {
    $method = strtoupper($body['_method']);
}

/**
 * Ensure max_donation column exists in campaigns table
 */
function ensureMaxDonationColumn(mysqli $conn): void {
    $checkCol = $conn->query("SHOW COLUMNS FROM campaigns LIKE 'max_donation'");
    if ($checkCol && $checkCol->num_rows === 0) {
        $conn->query("ALTER TABLE campaigns ADD COLUMN max_donation DECIMAL(12,2) NULL DEFAULT NULL");
    }
}

ensureMaxDonationColumn($conn);

if ($method === 'GET') {
    // Return all campaigns with max_donation
    $sql = "
        SELECT c.id, c.title, c.category, c.goal, c.raised, c.donors,
               c.days_left, c.image_url, c.description, c.is_active, 
               c.max_donation, n.name AS ngo
        FROM campaigns c
        JOIN ngos n ON c.ngo_id = n.id
        ORDER BY c.id ASC
    ";
    $result = $conn->query($sql);                           
    
    if (!$result) {
        http_response_code(500);
        echo json_encode(['error' => 'Database query failed', 'detail' => $conn->error]);
        $conn->close();
        exit;
    }
    
    $list = [];
    while ($row = $result->fetch_assoc()) {
        $row['goal'] = (float)$row['goal'];
        $row['raised'] = (float)$row['raised'];
        $row['donors'] = (int)$row['donors'];
        $row['max_donation'] = $row['max_donation'] !== null ? (float)$row['max_donation'] : null;
        $list[] = $row;
    }
    echo json_encode($list);

} elseif ($method === 'POST') {
    // Create campaign
    $title = trim($body['title'] ?? '');
    $category = trim($body['category'] ?? '');
    $goal = (float)($body['goal'] ?? 0);
    $daysLeft = (int)($body['days_left'] ?? 30);
    $imageUrl = trim($body['image_url'] ?? '');
    $description = trim($body['description'] ?? '');
    $ngoId = (int)($body['ngo_id'] ?? 0);
    $ngoName = trim($body['ngo_name'] ?? '');
    $maxDonation = isset($body['max_donation']) && $body['max_donation'] !== '' ? (float)$body['max_donation'] : null;

    if (empty($title) || empty($category) || $goal <= 0) {
        http_response_code(400);
        echo json_encode(['error' => 'Title, category, and goal are required']);
        $conn->close();
        exit;
    }

    // If ngo_name provided but not ngo_id, look up or create the NGO
    if ($ngoId <= 0 && !empty($ngoName)) {
        $stmt = $conn->prepare("SELECT id FROM ngos WHERE name = ?");
        $stmt->bind_param('s', $ngoName);
        $stmt->execute();
        $ngoResult = $stmt->get_result()->fetch_assoc();
        $stmt->close();
        
        if ($ngoResult) {
            $ngoId = $ngoResult['id'];
        } else {
            // Create new NGO
            $stmt = $conn->prepare("INSERT INTO ngos (name) VALUES (?)");
            $stmt->bind_param('s', $ngoName);
            $stmt->execute();
            $ngoId = $conn->insert_id;
            $stmt->close();
        }
    }
    
    if ($ngoId <= 0) {
        $ngoId = 1; // Default fallback
    }

    $conn->begin_transaction();
    
    try {
        if ($maxDonation !== null) {
            $stmt = $conn->prepare("
                INSERT INTO campaigns (title, ngo_id, category, goal, days_left, image_url, description, is_active, max_donation)
                VALUES (?, ?, ?, ?, ?, ?, ?, 1, ?)
            ");
            $stmt->bind_param('sisdisd', $title, $ngoId, $category, $goal, $daysLeft, $imageUrl, $description, $maxDonation);
        } else {
            $stmt = $conn->prepare("
                INSERT INTO campaigns (title, ngo_id, category, goal, days_left, image_url, description, is_active)
                VALUES (?, ?, ?, ?, ?, ?, ?, 1)
            ");
            $stmt->bind_param('sisdiss', $title, $ngoId, $category, $goal, $daysLeft, $imageUrl, $description);
        }
        
        if (!$stmt) {
            throw new Exception("Prepare failed: " . $conn->error);
        }
        
        if (!$stmt->execute()) {
            throw new Exception("Insert failed: " . $stmt->error);
        }
        
        $newId = $conn->insert_id;
        $stmt->close();
        
        $conn->commit();
        echo json_encode(['success' => true, 'id' => $newId]);
        
    } catch (Exception $e) {
        $conn->rollback();
        http_response_code(500);
        echo json_encode(['error' => 'Could not create campaign', 'detail' => $e->getMessage()]);
    }

} elseif ($method === 'PUT') {
    // Update campaign
    $id = (int)($body['id'] ?? 0);
    $title = trim($body['title'] ?? '');
    $category = trim($body['category'] ?? '');
    $goal = (float)($body['goal'] ?? 0);
    $daysLeft = (int)($body['days_left'] ?? 30);
    $imageUrl = trim($body['image_url'] ?? '');
    $description = trim($body['description'] ?? '');
    $isActive = isset($body['is_active']) ? (int)$body['is_active'] : 1;
    $maxDonation = isset($body['max_donation']) && $body['max_donation'] !== '' ? (float)$body['max_donation'] : null;

    if ($id <= 0) {
        http_response_code(400);
        echo json_encode(['error' => 'Campaign ID required']);
        $conn->close();
        exit;
    }

    $conn->begin_transaction();
    
    try {
        $stmt = $conn->prepare("
            UPDATE campaigns 
            SET title = ?, category = ?, goal = ?, days_left = ?, image_url = ?, description = ?, is_active = ?, max_donation = ?
            WHERE id = ?
        ");
        
        if (!$stmt) {
            throw new Exception("Prepare failed: " . $conn->error);
        }
        
        $stmt->bind_param('ssdissidi', $title, $category, $goal, $daysLeft, $imageUrl, $description, $isActive, $maxDonation, $id);
        
        if (!$stmt->execute()) {
            throw new Exception("Update failed: " . $stmt->error);
        }
        
        $stmt->close();
        $conn->commit();
        
        echo json_encode(['success' => true]);
        
    } catch (Exception $e) {
        $conn->rollback();
        http_response_code(500);
        echo json_encode(['error' => 'Could not update campaign', 'detail' => $e->getMessage()]);
    }

} elseif ($method === 'DELETE') {
    // Delete campaign
    $id = (int)($body['id'] ?? 0);
    
    if ($id <= 0) {
        http_response_code(400);
        echo json_encode(['error' => 'Campaign ID required']);
        $conn->close();
        exit;
    }

    $conn->begin_transaction();
    
    try {
        // First check if campaign has donations
        $stmt = $conn->prepare("SELECT COUNT(*) as cnt FROM donations WHERE campaign_id = ?");
        $stmt->bind_param('i', $id);
        $stmt->execute();
        $count = $stmt->get_result()->fetch_assoc()['cnt'];
        $stmt->close();
        
        if ($count > 0) {
            // Soft delete - just mark as inactive
            $stmt = $conn->prepare("UPDATE campaigns SET is_active = 0 WHERE id = ?");
            $stmt->bind_param('i', $id);
            $stmt->execute();
            $stmt->close();
            $conn->commit();
            echo json_encode(['success' => true, 'soft_delete' => true, 'message' => 'Campaign deactivated (has donations)']);
        } else {
            // Hard delete - no donations
            $stmt = $conn->prepare("DELETE FROM campaigns WHERE id = ?");
            if (!$stmt) {
                throw new Exception("Prepare failed: " . $conn->error);
            }
            $stmt->bind_param('i', $id);
            if (!$stmt->execute()) {
                throw new Exception("Delete failed: " . $stmt->error);
            }
            $stmt->close();
            $conn->commit();
            echo json_encode(['success' => true]);
        }
        
    } catch (Exception $e) {
        $conn->rollback();
        http_response_code(500);
        echo json_encode(['error' => 'Could not delete campaign', 'detail' => $e->getMessage()]);
    }

} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}

$conn->close();
?>