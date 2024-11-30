<?php
include 'connect.php'; // Ensure this file sets up the SQL Server connection

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['grantCategory'])) {
    $grantCategory = $_POST['grantCategory'];

    // Call the stored procedure
    $sql = "{CALL GetGrantRequirements(?)}";
    $stmt = sqlsrv_query($conn, $sql, [$grantCategory]);

    if ($stmt === false) {
        echo json_encode(['success' => false, 'message' => 'Error fetching requirements.']);
        exit;
    }

    $criteria = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC);
    if ($criteria) {
        echo json_encode(['success' => true, 'criteria' => $criteria]);
    } else {
        echo json_encode(['success' => false, 'message' => 'GrantCategory not found.']);
    }
    exit;
}
?>
