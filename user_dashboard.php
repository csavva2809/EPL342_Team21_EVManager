<?php
session_start();
include 'connect.php'; // Ensure this file sets up the sqlsrv connection

// Ensure the user is logged in
if (!isset($_SESSION['user'])) {
    header("Location: index.php");
    exit();
}

// Handle file upload
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_FILES["uploadedFile"])) {
    $personId = $_SESSION['personId']; // Replace with actual PersonID from session
    $userName = $_SESSION['user']; // Username from session
    $uploadDir = '/~ksavva05/epl342/dbpro/filled_forms/';
    $fileName = basename($_FILES["uploadedFile"]["name"]);
    $targetFilePath = $uploadDir . $fileName;
    $submissionDate = date("Y-m-d"); // Current date

    // Validate file upload
    if (move_uploaded_file($_FILES["uploadedFile"]["tmp_name"], $targetFilePath)) {
        // Prepare the stored procedure
        $sql = "{CALL UploadDocument(?, ?, ?, ?)}";
        $params = array(
            array($personId, SQLSRV_PARAM_IN),
            array($userName, SQLSRV_PARAM_IN),
            array($targetFilePath, SQLSRV_PARAM_IN),
            array($submissionDate, SQLSRV_PARAM_IN)
        );

        // Execute the stored procedure
        $stmt = sqlsrv_query($conn, $sql, $params);

        if ($stmt === false) {
            $error_message = "Error uploading document: " . print_r(sqlsrv_errors(), true);
        } else {
            $success_message = "Document uploaded successfully!";
            sqlsrv_free_stmt($stmt);
        }
    } else {
        $error_message = "Error uploading file. Please try again.";
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Dashboard</title>
    <link rel="stylesheet" href="style.css"> <!-- Link to your CSS file -->
</head>
<body>
    <?php include 'navbar.php'; ?>

    <div class="dashboard-container">
        <h2>User Dashboard</h2>
        <p>Welcome, <?php echo htmlspecialchars($_SESSION['user']); ?>!</p>

        <!-- File Upload Section -->
        <div class="upload-form">
            <h3>Upload a File</h3>
            <?php if (!empty($error_message)): ?>
                <p class="error"><?php echo htmlspecialchars($error_message); ?></p>
            <?php elseif (!empty($success_message)): ?>
                <p class="success"><?php echo htmlspecialchars($success_message); ?></p>
            <?php endif; ?>
            <form action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" method="post" enctype="multipart/form-data">
                <label for="uploadedFile">Choose a file:</label>
                <input type="file" id="uploadedFile" name="uploadedFile" required>
                <input type="submit" value="Upload">
            </form>
        </div>
    </div>
</body>
</html>

