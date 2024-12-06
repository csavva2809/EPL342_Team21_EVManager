<?php
session_start();
include 'connect.php'; // Ensure this file sets up the sqlsrv connection

// Get the GrantID from the URL
$grantID = isset($_GET['grant_id']) ? $_GET['grant_id'] : null;

if ($grantID === null) {
    die("Grant ID is missing.");
}

$error_message = '';
$success_message = '';

// Initialize criteria array
$criteria = [];

// Call the stored procedure to get the criteria for the specific grant
$sql = "{CALL GetCriteriaForGrant(?)}";  // Call the stored procedure
$params = array($grantID);
$stmt = sqlsrv_query($conn, $sql, $params);

if ($stmt === false) {
    $error_message = "Database error during criteria retrieval: " . print_r(sqlsrv_errors(), true);
} else {
    // Fetch the results
    while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
        $criteria[] = $row;
    }
    sqlsrv_free_stmt($stmt); // Free statement resources
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Grant Criteria</title>
    <link rel="stylesheet" href="style.css"> <!-- Adjust the path if necessary -->
</head>
<body>
    <?php include 'navbar.php'; ?>

    <div class="criteria-container">
        <h2>Criteria for Grant</h2>
        
        <?php if ($error_message): ?>
            <p class="error"><?php echo htmlspecialchars($error_message); ?></p>
        <?php elseif (empty($criteria)): ?>
            <p>No criteria found for this grant.</p>
        <?php else: ?>
            <table>
                <thead>
                    <tr>
                        <th>Category</th>
                        <th>Description</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($criteria as $row): ?>
                        <tr>
                            <td><?php echo htmlspecialchars($row['Category']); ?></td>
                            <td><?php echo htmlspecialchars($row['Description']); ?></td>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        <?php endif; ?>
    </div>
</body>
</html>
