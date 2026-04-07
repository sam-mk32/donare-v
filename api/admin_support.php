<?php
/**
 * Admin support tickets view - with status update support
 */
require 'db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    // Check if resolved_at column exists
    $hasResolvedAt = false;
    $checkCol = $conn->query("SHOW COLUMNS FROM support_messages LIKE 'resolved_at'");
    if ($checkCol && $checkCol->num_rows > 0) {
        $hasResolvedAt = true;
    } else {
        // Add resolved_at column if missing
        $conn->query("ALTER TABLE support_messages ADD COLUMN resolved_at DATETIME NULL");
        $hasResolvedAt = true;
    }

    // Auto-purge resolved messages older than 24 hours
    $conn->query("DELETE FROM support_messages WHERE status = 'Resolved' AND resolved_at IS NOT NULL AND resolved_at < DATE_SUB(NOW(), INTERVAL 24 HOUR)");

    // Get pending messages
    $sqlPending = "
        SELECT id, name, email, phone, category, message, status, submitted_at
        FROM support_messages
        WHERE status != 'Resolved' OR status IS NULL
        ORDER BY submitted_at DESC
    ";
    $resultPending = $conn->query($sqlPending);
    $pending = [];
    if ($resultPending) {
        while ($row = $resultPending->fetch_assoc()) {
            $pending[] = $row;
        }
    }

    // Get resolved messages with delete countdown
    $sqlResolved = "
        SELECT id, name, email, phone, category, message, status, submitted_at, resolved_at
        FROM support_messages
        WHERE status = 'Resolved'
        ORDER BY resolved_at DESC
    ";
    $resultResolved = $conn->query($sqlResolved);
    $resolved = [];
    if ($resultResolved) {
        while ($row = $resultResolved->fetch_assoc()) {
            // Calculate delete time (24 hours after resolved)
            if ($row['resolved_at']) {
                $resolvedTime = strtotime($row['resolved_at']);
                $deleteTime = $resolvedTime + (24 * 60 * 60); // 24 hours later
                $row['delete_at_ms'] = $deleteTime * 1000; // Convert to JS milliseconds
            }
            $resolved[] = $row;
        }
    }

    echo json_encode([
        'pending' => $pending,
        'resolved' => $resolved,
        'pendingCount' => count($pending),
        'resolvedCount' => count($resolved)
    ]);

} elseif ($method === 'POST') {
    // Update status
    $body = json_decode(file_get_contents('php://input'), true);
    
    if (!$body || !isset($body['id']) || !isset($body['status'])) {
        http_response_code(400);
        echo json_encode(['error' => 'ID and status required']);
        $conn->close();
        exit;
    }
    
    $id = (int)$body['id'];
    $status = trim($body['status']);
    
    if (!in_array($status, ['Pending', 'Resolved'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid status']);
        $conn->close();
        exit;
    }
    
    // Update resolved_at timestamp when marking as resolved
    if ($status === 'Resolved') {
        $stmt = $conn->prepare("UPDATE support_messages SET status = ?, resolved_at = NOW() WHERE id = ?");
    } else {
        $stmt = $conn->prepare("UPDATE support_messages SET status = ?, resolved_at = NULL WHERE id = ?");
    }
    $stmt->bind_param('si', $status, $id);
    $stmt->execute();
    $stmt->close();
    
    echo json_encode(['success' => true]);

} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}

$conn->close();
