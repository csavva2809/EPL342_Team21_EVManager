<?php
session_start();
include 'connect.php'; // Ensure this file sets up the SQL Server connection

// Fetch all grants using the stored procedure
$sql = "{CALL DisplayGrant()}"; // Call the stored procedure to display all grants
$stmt = sqlsrv_query($conn, $sql);

if ($stmt === false) {
    die(print_r(sqlsrv_errors(), true));
}
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

    <div class="grants-container">
        <h2>Available Grants</h2>
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
                <?php while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)): ?>
                    <tr>
                        <td><?php echo htmlspecialchars($row['GrantCategory']); ?></td>
                        <td><?php echo htmlspecialchars($row['Description']); ?></td>
                        <td><?php echo htmlspecialchars($row['GrantPrice']); ?></td>
                        <td>
                            <?php 
                                $grantPrice = $row['GrantPrice'];
                                $sumPrice = $row['SumPrice'];
                                echo htmlspecialchars(intval($sumPrice / $grantPrice)); 
                            ?>
                        </td>
                        <td>
                            <a href="criteria.php?grant_id=<?php echo $row['GrantID']; ?>" class="btn">View Criteria</a>
                        </td>
                    </tr>
                <?php endwhile; ?>
            </tbody>
        </table>
        <div class="next-btn-container">
            <a href="apply_for_grant.php" class="btn btn-next">Next</a>
        </div>
    </div>
</body>
</html>

<?php
sqlsrv_free_stmt($stmt); // Free statement resources
?>
