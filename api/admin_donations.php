<?php
/**
 * Admin donations view - with DELETE support and error handling
 */
require 'db.php';

$method = $_SERVER['REQUEST_METHOD'];

// Handle POST tunnelling for DELETE
$rawBody = file_get_contents('php://input');
$body = json_decode($rawBody, true) ?? [];

if ($method === 'POST' && isset($body['_method'])) {
    $method = strtoupper($body['_method']);
}

if ($method === 'GET') {
    // Check if payment_method column exists
    $hasPaymentMethod = false;
    $checkCol = $conn->query("SHOW COLUMNS FROM donations LIKE 'payment_method'");
    if ($checkCol && $checkCol->num_rows > 0) {
        $hasPaymentMethod = true;
    }

    $paymentField = $hasPaymentMethod ? ", d.payment_method" : ", '' AS payment_method";
    
    $sql = "
        SELECT d.id, d.receipt_id, d.donor_name, d.donor_email, d.donor_phone,
               d.amount, d.status, d.donated_at, c.title AS campaign_title{$paymentField}
        FROM donations d
        JOIN campaigns c ON d.campaign_id = c.id
        ORDER BY d.donated_at DESC
    ";

    $result = $conn->query($sql);
    
    if (!$result) {
        http_response_code(500);
        echo json_encode(['error' => 'Database query failed', 'detail' => $conn->error]);
        $conn->close();
        exit;
    }
    
    $donations = [];

    while ($row = $result->fetch_assoc()) {
        $row['amount'] = (float)$row['amount'];
        $donations[] = $row;
    }

    echo json_encode($donations);

} elseif ($method === 'DELETE') {
    $receiptId = trim($body['receipt_id'] ?? '');
    
    if (empty($receiptId)) {
        http_response_code(400);
        echo json_encode(['error' => 'Receipt ID required']);
        $conn->close();
        exit;
    }
    
    // Start transaction for data integrity
    $conn->begin_transaction();
    
    try {
        // Get the donation details first to reverse campaign totals
        $stmt = $conn->prepare("SELECT campaign_id, amount FROM donations WHERE receipt_id = ?");
        if (!$stmt) {
            throw new Exception("Prepare failed: " . $conn->error);
        }
        $stmt->bind_param('s', $receiptId);
        $stmt->execute();
        $donation = $stmt->get_result()->fetch_assoc();
        $stmt->close();
        
        if (!$donation) {
            $conn->rollback();
            http_response_code(404);
            echo json_encode(['error' => 'Donation not found']);
            $conn->close();
            exit;
        }
        
        // Delete the donation
        $stmt2 = $conn->prepare("DELETE FROM donations WHERE receipt_id = ?");
        if (!$stmt2) {
            throw new Exception("Prepare failed: " . $conn->error);
        }
        $stmt2->bind_param('s', $receiptId);
        if (!$stmt2->execute()) {
            throw new Exception("Delete failed: " . $stmt2->error);
        }
        $affectedRows = $stmt2->affected_rows;
        $stmt2->close();
        
        if ($affectedRows === 0) {
            throw new Exception("No rows deleted");
        }
        
        // Reverse the campaign totals
        $stmt3 = $conn->prepare("UPDATE campaigns SET raised = GREATEST(0, raised - ?), donors = GREATEST(0, donors - 1) WHERE id = ?");
        if (!$stmt3) {
            throw new Exception("Prepare failed: " . $conn->error);
        }
        $stmt3->bind_param('di', $donation['amount'], $donation['campaign_id']);
        if (!$stmt3->execute()) {
            throw new Exception("Update failed: " . $stmt3->error);
        }
        $stmt3->close();
        
        // Commit the transaction
        $conn->commit();
        
        echo json_encode(['success' => true, 'deleted' => $receiptId]);
        
    } catch (Exception $e) {
        $conn->rollback();
        http_response_code(500);
        echo json_encode(['error' => 'Database operation failed', 'detail' => $e->getMessage()]);
    }

} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}

$conn->close();
