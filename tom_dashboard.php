<?php
session_start();
include 'connect.php'; // Ensure this file sets up the SQL Server connection

if (!isset($_SESSION['userName']) || $_SESSION['role'] !== 'TOM') {
    header("Location: index.php"); // Redirect if not TOM
    exit();
}

// Initialize error and success messages
$error_message = '';
$success_message = '';

// Handle file upload
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_FILES["document"])) {
    $applicationID = $_POST['applicationID']; // Get the ApplicationID from the form

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
            // Call the UploadDocument stored procedure
            $docType = 'Supportive';  // Assuming the document type is 'supportive' for now
            
            // Insert the document into the database using the stored procedure
            $sql = "{CALL UploadDocument(?, ?, ?, ?, ?)}";  // Stored procedure for supportive document upload
            $params = array(
                array($applicationID, SQLSRV_PARAM_IN),  // Application ID
                array($file_name, SQLSRV_PARAM_IN),     // Document name
                array($file_path, SQLSRV_PARAM_IN),     // File path
                array($_FILES["document"]["size"], SQLSRV_PARAM_IN), // File size
                array($docType, SQLSRV_PARAM_IN)        // DocType (set as 'supportive' for this case)
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

// Fetch grouped documents using the new stored procedure
$sql = "{CALL GetGroupedOrderAndSupportiveDocuments()}"; // Call the updated stored procedure
$stmt = sqlsrv_query($conn, $sql);

if ($stmt === false) {
    $error_message = "Error fetching grouped documents: " . print_r(sqlsrv_errors(), true);
} else {
    $documentTable = '';
    while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
        $fileLinks = '';
        $fileNames = explode(', ', $row['FileNames']);
        $filePaths = explode(', ', $row['FilePaths']);
        $docTypes = explode(', ', $row['DocTypes']);

          // Limit number of file links to show initially (e.g., first 2)
          $visibleFiles = array_slice($fileNames, 0, 2);
          $hiddenFiles = array_slice($fileNames, 2);
  
          // Generate the visible file links
          foreach ($visibleFiles as $index => $fileName) {
              $fileLinks .= "<a href='download.php?file=" . urlencode($filePaths[$index]) . "' target='_blank'>$fileName</a> (" . htmlspecialchars($docTypes[$index]) . ")<br>";
          }
  
          // Add the "See More" button if there are more files to show
          if (count($hiddenFiles) > 0) {
              $fileLinks .= "<br><a href='javascript:void(0);' class='see-more'>See More</a>";
          }
  
          // Add the hidden file links, wrapped in a <span> that will be toggled
          foreach ($hiddenFiles as $index => $fileName) {
              $fileLinks .= "<span class='more-files' style='display:none;'><br><a href='download.php?file=" . urlencode($filePaths[$index + 2]) . "' target='_blank'>$fileName</a> (" . htmlspecialchars($docTypes[$index + 2]) . ")</span>";
          }

        $documentTable .= "<tr>
            <td>" . htmlspecialchars($row['ApplicationID']) . "</td>
            <td>$fileLinks</td>
            <td>" . htmlspecialchars($row['OrderIDs']) . "</td>
            <td>" . htmlspecialchars($row['VehicleIDs']) . "</td>
            <td>" . htmlspecialchars($row['ExpectedRegisterDates']) . "</td>
            <!-- New Column for File Upload -->
            <td>
                <form action='' method='post' enctype='multipart/form-data'>
                    <input type='hidden' name='applicationID' value='" . htmlspecialchars($row['ApplicationID']) . "'>
                    <input type='file' name='document' required>
                    <input type='submit' value='Upload Document'>
                </form>
            </td>
        </tr>";
    }
    sqlsrv_free_stmt($stmt);
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TOM Dashboard - Grouped Order Documents</title>
    <link rel="stylesheet" href="style.css">

    
    <style>
        /* General styles */
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
        }

        /* Navbar (adjust if needed) */
        .navbar {
            background-color: #333;
            color: white;
            padding: 10px 0;
            text-align: center;
        }

        .navbar a {
            color: white;
            text-decoration: none;
            margin: 0 15px;
            font-size: 18px;
        }

        /* Dashboard container */
        .dashboard-container {
            width: 80%;
            margin: 30px auto;
            background-color: white;
            padding: 20px;
            box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
        }

        /* Table styles */
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }

        table th, table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }

        table th {
            background-color: #4CAF50;
            color: white;
        }

        table tr:hover {
            background-color: #f1f1f1;
        }

        /* File upload form in the table */
        td form {
            display: inline-block;
            margin: 0;
        }

        input[type="file"] {
            display: inline-block;
            padding: 6px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            margin-right: 10px;
        }

        input[type="submit"] {
            background-color: #4CAF50;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            cursor: pointer;
        }

        input[type="submit"]:hover {
            background-color: #45a049;
        }

        /* Success and error message styles */
        .success {
            background-color: #dff0d8;
            color: #3c763d;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }

        .error {
            background-color: #f2dede;
            color: #a94442;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }

        /* Table column widths (optional) */
        table th:nth-child(1), table td:nth-child(1) {
            width: 15%;
        }/* Adjustments for the "Files" column */
        
            /* Adjustments for the "Files" column */
        table td:nth-child(2) {
            word-wrap: break-word; /* Ensures text breaks in a column */
            max-width: 200px; /* Limit the width of the file column */
            overflow: hidden;
            text-overflow: ellipsis; /* Adds ellipsis when the content is too long */
            vertical-align: top; /* Aligns the content to the top of the cell */
        }

        /* Style links inside the "Files" column */
        table td:nth-child(2) a {
            display: inline-block;
            padding: 3px 8px; /* Smaller padding for the buttons */
            background-color: #4CAFF4; /* Light blue background */
            color: white;
            text-decoration: none;
            border-radius: 4px;
            margin-bottom: 3px;
            width: 100%;
            box-sizing: border-box; /* Makes sure the link fills the available space */
            white-space: nowrap;
            text-overflow: ellipsis; /* Adds ellipsis for long filenames */
            overflow: hidden;
            font-size: 14px; /* Smaller font size */
            line-height: 1.5; /* Ensures button text is vertically centered */
        }


        /* Style links on hover */
        table td:nth-child(2) a:hover {
            background-color: #3e9fb4; /* Slightly darker blue on hover */
        }

        /* Ensure the file links are responsive */
        @media screen and (max-width: 768px) {
            table td:nth-child(2) {
                max-width: 150px; /* Limit the width on smaller screens */
            }

            table td:nth-child(2) a {
                width: 100%; /* Make links take full width on smaller screens */
                text-overflow: ellipsis;
                overflow: hidden;
                display: block;
            }
        }

        /* Add toggle behavior for 'See More' */
        .more-files {
            display: none;
        }
    </style>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Attach click event to See More button
            const seeMoreButtons = document.querySelectorAll('.see-more');
            
            seeMoreButtons.forEach(function(button) {
                button.addEventListener('click', function() {
                    const parentTd = this.closest('td');
                    const moreFiles = parentTd.querySelectorAll('.more-files');
                    
                    // Toggle visibility of additional files
                    moreFiles.forEach(function(file) {
                        file.style.display = (file.style.display === 'none') ? 'block' : 'none';
                    });
                    
                    // Change the button text
                    if (this.textContent === 'See More') {
                        this.textContent = 'See Less';
                    } else {
                        this.textContent = 'See More';
                    }
                });
            });
        });
    </script>
</head>
<body>
    <?php include 'navbar.php'; ?>
    
    <div class="dashboard-container">
        <h1>TOM Dashboard</h1>
        
        <!-- Display Error Message if Any -->
        <?php if ($error_message): ?>
            <p class="error"><?php echo nl2br(htmlspecialchars($error_message)); ?></p>
        <?php endif; ?>
        <?php if ($success_message): ?>
            <p class="success"><?php echo nl2br(htmlspecialchars($success_message)); ?></p>
        <?php endif; ?>

        <!-- Display grouped order documents -->
        <h2>Grouped Order and Supportive Documents</h2>
        <table>
            <thead>
                <tr>
                    <th>Application ID</th>
                    <th>Files</th>
                    <th>Order IDs</th>
                    <th>Vehicle IDs</th>
                    <th>Expected Register Dates</th>
                    <th>Upload Document</th> <!-- New Column for Document Upload -->
                </tr>
            </thead>
            <tbody>
                <?= $documentTable; ?>
            </tbody>
        </table>
    </div>
</body>
</html>
