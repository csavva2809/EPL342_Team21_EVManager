<?php
session_start();
include 'connect.php'; // Ensure this file sets up the SQL Server connection

// Initialize error message
$error_message = '';
$success_message = '';

// Check if the user is logged in
if (!isset($_SESSION['user'])) {
    header("Location: login.php");
    exit();
}

// If the form is submitted
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Retrieve form data
    $userID = $_SESSION['personId'];
    $userName = $_SESSION['user'];
    $applicantType = $_SESSION['userType']; // Either 'individual' or 'legal_entity'
    $grantCategory = $_POST['grantCategory'];
    $vehicleType = $_POST['vehicleType'];
    $withdrawalVehicleID = $_POST['withdrawalVehicleID'];
    $applicationDate = date('Y-m-d');
    $status = 'submitted'; // Default status
    $expirationDate = $_POST['expirationDate']; // Set expiration date for the application
    
    // Generate a unique Application ID (you can adjust the logic here for how you want to generate the ID)
    $applicationID = uniqid('APP'); // Simple unique ID (you could also use an auto-increment strategy)

    // Call the stored procedure to insert the application
    $sql = "{CALL InsertApplication(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}";
    $params = array(
        array($applicationID, SQLSRV_PARAM_IN),
        array($userID, SQLSRV_PARAM_IN),
        array($userName, SQLSRV_PARAM_IN),
        array($applicantType, SQLSRV_PARAM_IN),
        array($grantCategory, SQLSRV_PARAM_IN),
        array($applicationDate, SQLSRV_PARAM_IN),
        array($vehicleType, SQLSRV_PARAM_IN),
        array($withdrawalVehicleID, SQLSRV_PARAM_IN),
        array($status, SQLSRV_PARAM_IN),
        array($expirationDate, SQLSRV_PARAM_IN)
    );

    // Execute the stored procedure
    $stmt = sqlsrv_query($conn, $sql, $params);

    if ($stmt === false) {
        // Output error details
        $error_message = "Error in submitting application: " . print_r(sqlsrv_errors(), true);
    } else {
        sqlsrv_free_stmt($stmt); // Free statement resources
        $success_message = "Application submitted successfully!";
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apply for Grant</title>
    <link rel="stylesheet" href="style.css"> <!-- Adjust the path if necessary -->
</head>
<body>
    <?php include 'navbar.php'; ?>

    <div class="apply-container">
        <h2>Apply for Grant</h2>

        <?php if ($error_message): ?>
            <p class="error"><?php echo htmlspecialchars($error_message); ?></p>
        <?php elseif ($success_message): ?>
            <p class="success"><?php echo htmlspecialchars($success_message); ?></p>
        <?php endif; ?>

        <form action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" method="post">
            <label for="grantCategory">Grant Category:</label>
            <select id="grantCategory" name="grantCategory" required>
                <option value="C1">C1</option>
                <option value="C2">C2</option>
                <option value="C3">C3</option>
                <!-- Add other grant options here -->
            </select>

            <label for="vehicleType">Vehicle Type:</label>
            <select id="vehicleType" name="vehicleType" required>
                <option value="M1">M1</option>
                <option value="M2">M2</option>
                <option value="N1">N1</option>
                <option value="N2">N2</option>
                <option value="L">L</option>
            </select>

            <label for="withdrawalVehicleID">Withdrawal Vehicle ID:</label>
            <input type="text" id="withdrawalVehicleID" name="withdrawalVehicleID" required>

            <label for="expirationDate">Expiration Date:</label>
            <input type="date" id="expirationDate" name="expirationDate" required>

            <input type="submit" value="Submit Application">
        </form>
    </div>
</body>
</html>
