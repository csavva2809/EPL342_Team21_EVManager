<?php
session_start();
include 'connect.php'; // Ensure this file sets up the sqlsrv connection

// Retrieve the criteria_id from the URL
$criteria_id = isset($_GET['criteria_id']) ? $_GET['criteria_id'] : null;

if ($criteria_id === null) {
    die("No criteria ID found.");
}

$error_message = '';
$success_message = '';

// Handle file upload
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_FILES["document"])) {
    // Check if a file is selected
    if ($_FILES["document"]["error"] > 0) {
        $error_message = "Error uploading file.";
    } else {
        // Define the directory to store the uploaded files
        $upload_dir = '/home/students/cs/2021/ksavva05/public_html/epl342/dbpro/filled_forms/'; // Make sure this is correct path
        
        // Get the file name and the path
        $file_name = $_FILES["document"]["name"];
        $file_path = $upload_dir . $file_name;

        // Max lengths for FileName and FilePath
        $max_file_name_length = 255;
        $max_file_path_length = 255;

        // Check if the file name exceeds the max length
        if (strlen($file_name) > $max_file_name_length) {
            die("Error: File name is too long. Maximum length is $max_file_name_length characters.");
        }

        // Check if the file path exceeds the max length
        if (strlen($file_path) > $max_file_path_length) {
            die("Error: File path is too long. Maximum length is $max_file_path_length characters.");
        }

        // Generate a unique name for the file to avoid overwriting
        $file_name = uniqid("doc_") . "_" . $_FILES["document"]["name"];
        $file_path = $upload_dir . $file_name;

        // Check if the directory is writable
        if (!is_writable($upload_dir)) {
            die("Error: The upload directory is not writable.");
        }

        // Move the uploaded file to the desired directory
        if (move_uploaded_file($_FILES["document"]["tmp_name"], $file_path)) {
            // Store the document in the Documents table using a stored procedure
            $sql = "{CALL InsertDocument(?, ?, ?)}";  // Stored procedure to insert the document info into the database
            $params = array(
                array($file_name, SQLSRV_PARAM_IN),  // Document name
                array($criteria_id, SQLSRV_PARAM_IN), // Associated criteria ID
                array($file_path, SQLSRV_PARAM_IN)   // File path
            );
            
            $stmt = sqlsrv_query($conn, $sql, $params);

            if ($stmt === false) {
                $error_message = "Error storing document: " . print_r(sqlsrv_errors(), true);
            } else {
                sqlsrv_free_stmt($stmt);
                $success_message = "Document uploaded successfully!";
            }
        } else {
            $error_message = "Failed to move the uploaded file.";
        }
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload Document</title>
</head>
<body>
    <h2>Upload Document for Criteria</h2>

    <?php if (!empty($error_message)): ?>
        <p class="error"><?php echo htmlspecialchars($error_message); ?></p>
    <?php elseif (!empty($success_message)): ?>
        <p class="success"><?php echo htmlspecialchars($success_message); ?></p>
    <?php endif; ?>

    <form action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]) . '?criteria_id=' . $criteria_id; ?>" method="post" enctype="multipart/form-data">
        <label for="document">Select Document:</label>
        <input type="file" name="document" required>
        <br><br>
        <input type="submit" value="Upload Document">
    </form>
</body>
</html>
