<?php
session_start();
include 'connect.php'; // Make sure to set up the SQL Server connection


// Get the criteria for the selected grant
$sql = "
    SELECT c.Description 
    FROM GrantCriteria gc
    JOIN Criteria c ON gc.CriteriaID = c.CriteriaID
    WHERE gc.GrantID = ?";
$params = array($grantID);
$stmt = sqlsrv_query($conn, $sql, $params);

if ($stmt === false) {
    die("Error fetching criteria: " . print_r(sqlsrv_errors(), true));
}

$criteria = [];
while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
    $criteria[] = $row['Description']; // Store each criterion in an array
}

sqlsrv_free_stmt($stmt);

// Get the grant details
$sqlGrant = "SELECT GrantCategory, Description, GrantPrice FROM Grants WHERE GrantID = ?";
$stmtGrant = sqlsrv_query($conn, $sqlGrant, array($grantID));

if ($stmtGrant === false) {
    die("Error fetching grant details: " . print_r(sqlsrv_errors(), true));
}

$grant = sqlsrv_fetch_array($stmtGrant, SQLSRV_FETCH_ASSOC);
sqlsrv_free_stmt($stmtGrant);

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apply for Grant</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <?php include 'navbar.php'; ?>

    <div class="application-form">
        <h2>Apply for <?php echo htmlspecialchars($grant['GrantCategory']); ?></h2>
        <p><strong>Grant Description:</strong> <?php echo htmlspecialchars($grant['Description']); ?></p>
        <p><strong>Grant Amount:</strong> <?php echo htmlspecialchars($grant['GrantPrice']); ?> EUR</p>

        <h3>Required Criteria</h3>
        <ul>
            <?php foreach ($criteria as $criterion): ?>
                <li><?php echo htmlspecialchars($criterion); ?></li>
            <?php endforeach; ?>
        </ul>

        <h3>Application Form</h3>
        <form action="submit_application.php" method="post" enctype="multipart/form-data">
            <input type="hidden" name="grantID" value="<?php echo $grantID; ?>">

            <label for="applicationTitle">Application Title:</label>
            <input type="text" id="applicationTitle" name="applicationTitle" required>

            <label for="applicationDescription">Application Description:</label>
            <textarea id="applicationDescription" name="applicationDescription" required></textarea>

            <label for="supportingDocuments">Upload Supporting Documents:</label>
            <input type="file" id="supportingDocuments" name="supportingDocuments[]" multiple required>

            <input type="submit" value="Submit Application">
        </form>
    </div>
</body>
</html>
