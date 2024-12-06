<?php
include 'connect.php'; // Ensure this file sets up the SQL Server connection

if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['grantCategory'])) {
    $grantCategory = $_POST['grantCategory'];

    $sql = "SELECT Justification, WithdrawalVehicle FROM Grants WHERE GrantCategory = ?";
    $params = array($grantCategory);
    $stmt = sqlsrv_query($conn, $sql, $params);

    if ($stmt === false) {
        echo json_encode(['success' => false, 'message' => 'Error fetching grant details.']);
        exit;
    }

    if ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
        echo json_encode([
            'success' => true,
            'criteria' => [
                'RequiresWithdrawalVehicle' => $row['WithdrawalVehicle'],
                'JustificationTitle' => $row['Justification'] // Fetch justification dynamically
            ]
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'No grant found for the selected category.']);
    }

    sqlsrv_free_stmt($stmt);
    exit;
}

echo json_encode(['success' => false, 'message' => 'Invalid request.']);
exit;
