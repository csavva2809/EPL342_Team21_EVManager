<?php
session_start();
include 'connect.php'; // Ensure this file sets up the SQL Server connection

// Check if the user is logged in
if (!isset($_SESSION['user'])) {
    header("Location: login.php");
    exit();
}

// Get form data
$grantID = isset($_POST['grantID']) ? intval($_POST['grantID']) : 0;
$applicationTitle = trim($_POST['applicationTitle']);
$applicationDescription = trim($_POST['applicationDescription']);

// Validate inputs
if (empty($applicationTitle) || empty($applicationDescription) || $grantID === 0) {
    die("Invalid application details.");
}

// Insert the application into the Applications table
$sql = "{CALL CreateApplication(?, ?, ?, ?, ?, ?, ?, ?)}";
$params = array(
    array($_SESSION['userType'], SQLSRV_PARAM_IN),
    array($_SESSION['userId'], SQLSRV_PARAM_IN),
    array($applicationTitle, SQLSRV_PARAM_IN),
    array($applicationDescription, SQLSRV_PARAM_IN),
    array('pending', SQLSRV_PARAM_IN), // Default status
    array(&$applicationID, SQLSRV_PARAM_OUT),
    array(&$message, SQLSRV_PARAM_OUT)
);

$stmt = sqlsrv_query($conn, $sql, $params);

if ($stmt === false) {
    die("Error submitting application: " . print_r(sqlsrv_errors(), true));
}

sqlsrv_next_result($stmt);
sqlsrv_free_stmt($stmt);

// Process file upload
if (isset($_FILES['supportingDocuments'])) {
    $files = $_FILES['supportingDocuments'];

    for ($i = 0; $i < count($files['name']); $i++) {
        $fileName = $files['name'][$i];
        $fileTmpName = $files['tmp_name'][$i];
        $fileError = $files['error'][$i];

        if ($fileError === 0) {
            // Define upload path and move file
            $uploadDir = "uploads/";
            $filePath = $uploadDir . basename($fileName);

            if (move_uploaded_file($fileTmpName, $filePath)) {
                // Insert the document record into the Documents table
                $sqlDoc = "{CALL InsertDocument(?, ?, ?, ?, ?)}";
                $paramsDoc = array(
                    array($applicationID, SQLSRV_PARAM_IN),
                    array($fileName, SQLSRV_PARAM_IN),
                    array($filePath, SQLSRV_PARAM_IN),
                    array('submitted', SQLSRV_PARAM_IN), // Document status
                    array(&$docID, SQLSRV_PARAM_OUT)
                );

                $stmtDoc = sqlsrv_query($conn, $sqlDoc, $paramsDoc);

                if ($stmtDoc === false) {
                    die("Error uploading document: " . print_r(sqlsrv_errors(), true));
                }

                sqlsrv_next_result($stmtDoc);
                sqlsrv_free_stmt($stmtDoc);
            } else {
                die("Error uploading file: " . $fileName);
            }
        }
    }
}

echo "Application submitted successfully.";
?>
