<?php
session_start();
include 'connect.php'; // Make sure to set up the SQL Server connection

// Check if the user is logged in
if (!isset($_SESSION['user'])) {
    header("Location: login.php");
    exit();
}

// Get the available grants from the database
$sql = "SELECT GrantID, GrantCategory, Description, GrantPrice, AvailableGrants FROM Grants";
$stmt = sqlsrv_query($conn, $sql);

if ($stmt === false) {
    die("Error fetching grants: " . print_r(sqlsrv_errors(), true));
}

$grants = [];
while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
    $grants[] = $row; // Store each grant in an array
}

sqlsrv_free_stmt($stmt);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Available Grants</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <?php include 'navbar.php'; ?>

    <div class="grant-list">
        <h2>Available Grants</h2>

        <?php if (empty($grants)): ?>
            <p>No grants available at the moment.</p>
        <?php else: ?>
            <table>
                <thead>
                    <tr>
                        <th>Grant Category</th>
                        <th>Description</th>
                        <th>Grant Price</th>
                        <th>Available Grants</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($grants as $grant): ?>
                        <tr>
                            <td><?php echo htmlspecialchars($grant['GrantCategory']); ?></td>
                            <td><?php echo htmlspecialchars($grant['Description']); ?></td>
                            <td><?php echo htmlspecialchars($grant['GrantPrice']); ?> EUR</td>
                            <td><?php echo htmlspecialchars($grant['AvailableGrants']); ?></td>
                            <td>
                                <a href="create_application.php?grantID=<?php echo $grant['GrantID']; ?>">Apply</a>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        <?php endif; ?>
    </div>
</body>
</html>
