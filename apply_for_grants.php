<?php
session_start();
include 'connect.php'; // Ensure this file sets up the SQL Server connection

// Ensure the user is logged in
if (!isset($_SESSION['UserID'])) {
    die("User not logged in. Redirect to login.");
}

$userId = $_SESSION['UserID'];

// Initialize error and success messages
$error_message = '';
$success_message = '';
$grantOptions = '';

// Fetch grant categories for the dropdown
$sql = "{CALL GetAllGrantCategories()}";
$stmt = sqlsrv_query($conn, $sql);

if ($stmt === false) {
    die("Error fetching grants: " . print_r(sqlsrv_errors(), true));
} else {
    while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
        $grantOptions .= "<option value='" . htmlspecialchars($row['GrantCategory']) . "'>" . htmlspecialchars($row['GrantCategory']) . "</option>";
    }
    sqlsrv_free_stmt($stmt);
}

// Handle form submission
if ($_SERVER["REQUEST_METHOD"] == "POST" && isset($_POST['grantCategory'])) {
    // Sanitize inputs
    $grantCategory = $_POST['grantCategory'] ?? '';
    $vehicleType = $_POST['vehicleType'] ?? '';
    $email = $_POST['email'] ?? '';
    $applicationDate = date('Y-m-d');
    $withdrawalVehicleID = $_POST['withdrawalVehicleID'] ?? null; // Only if visible for the category
    $userID = $_SESSION['UserID'];
    $userType = $_SESSION['userType'];
    $applicationID = null;

    // Validate the form
    if (empty($grantCategory)) {
        $error_message .= "Κατηγορία Χορηγίας είναι υποχρεωτική. ";
    }

    if (empty($vehicleType)) {
        $error_message .= "Επιλογή Χορηγίας είναι υποχρεωτική. ";
    }

    if (empty($email)) {
        $error_message .= "Η διεύθυνση ηλεκτρονικού ταχυδρομείου είναι υποχρεωτική. ";
    } elseif (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $error_message .= "Μη έγκυρη διεύθυνση ηλεκτρονικού ταχυδρομείου.<br>";
    }

    // Handle file upload if provided
    $fileName = null;
    $filePath = null;
    $fileSize = null;
    if (isset($_FILES["document"]) && $_FILES["document"]["error"] === 0) {
        $upload_dir = '/home/students/cs/2021/ksavva05/public_html/epl342/dbpro/filled_forms/'; // Update path if needed
        $original_file_name = $_FILES["document"]["name"];
        $fileSize = $_FILES["document"]["size"]; // Get file size in bytes

        // Validate file size
        if ($fileSize > 2000000) { // 2 MB limit
            $error_message .= "The uploaded file exceeds the size limit of 2 MB.";
        } else {
            $fileName = uniqid("doc_") . "_" . $original_file_name;
            $filePath = $upload_dir . $fileName;

            // Validate upload directory
            if (!is_dir($upload_dir) || !is_writable($upload_dir)) {
                $error_message .= "Error: Upload directory does not exist or is not writable.";
            } elseif (!move_uploaded_file($_FILES["document"]["tmp_name"], $filePath)) {
                $error_message .= "Failed to move the uploaded file.";
            }
        }
    }

    // Insert application and upload document if no errors
    if (empty($error_message)) {
        $insertApplicationSql = "{CALL InsertApplication(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}";
        $params = array(
            array($userID, SQLSRV_PARAM_IN),
            array($userType, SQLSRV_PARAM_IN),
            array($grantCategory, SQLSRV_PARAM_IN),
            array($vehicleType, SQLSRV_PARAM_IN),
            array($withdrawalVehicleID, SQLSRV_PARAM_IN), // Can be null
            array($applicationDate, SQLSRV_PARAM_IN),
            array($email, SQLSRV_PARAM_IN),
            array($fileName, SQLSRV_PARAM_IN), // File name parameter
            array($filePath, SQLSRV_PARAM_IN), // File path parameter
            array($fileSize, SQLSRV_PARAM_IN), // File size parameter
            array(&$applicationID, SQLSRV_PARAM_OUT, SQLSRV_PHPTYPE_STRING(SQLSRV_ENC_CHAR))
        );

        $stmt = sqlsrv_query($conn, $insertApplicationSql, $params);

        if ($stmt === false) {
            $error_message = "Error submitting application: " . print_r(sqlsrv_errors(), true);
        } else {
            sqlsrv_free_stmt($stmt);
            if ($applicationID) {
                $success_message = "Application submitted successfully! Your Application ID is " . htmlspecialchars($applicationID) . ".";
            } else {
                $error_message = "Failed to retrieve Application ID.";
            }
        }
    }
}
?>

<!DOCTYPE html>
<html lang="el">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apply for Grant</title>
    <link rel="stylesheet" href="style.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>
    <?php include 'navbar.php'; ?>

    <div class="apply-container">
        <h2>Σχέδιο Προώθησης Της Ηλεκτροκίνησης Στην Κύπρο</h2>

        <?php if ($error_message): ?>
            <p class="error"><?php echo nl2br(htmlspecialchars($error_message)); ?></p>
        <?php elseif ($success_message): ?>
            <p class="success"><?php echo htmlspecialchars($success_message); ?></p>
        <?php endif; ?>

        <form action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" method="post" id="grantForm" enctype="multipart/form-data">
            <label for="grantCategory">Κατηγορία Χορηγίας:</label>
            <select id="grantCategory" name="grantCategory" required>
                <option value="">Παρακαλώ επιλέξτε</option>
                <?= $grantOptions; ?>
            </select>

            <label for="vehicleType">Επιλογή Χορηγίας:</label>
            <select id="vehicleType" name="vehicleType" required>
                <option value="">Παρακαλώ επιλέξτε</option>
                <option value="M1">M1</option>
                <option value="M2">M2</option>
                <option value="N1">N1</option>
                <option value="N2">N2</option>
                <option value="L">L</option>
            </select>

            <label for="email">Διεύθυνση ηλεκτρονικού ταχυδρομείου:</label>
            <input type="email" id="email" name="email" placeholder="email_address@email.com" required>

            <div id="withdrawalVehicleDiv" style="display: none;">
                <label for="withdrawalVehicleID">Αριθμός Οχήματος προς Απόσυρση:</label>
                <input type="text" id="withdrawalVehicleID" name="withdrawalVehicleID" title="Αριθμός Οχήματος πρέπει να είναι αριθμός">
            </div>

            <div id="justificationDiv" style="display: none;">
                <label for="justification">Αιτιολογία Χορηγίας (PDF, JPEG, PNG only, Max 2MB):</label>
                <input type="file" name="document">
            </div>
            <input type="submit" value="Καταχώρηση">
        </form>
    </div>

    <script>
        $(document).ready(function () {
            // Listen for changes on the grant category dropdown
            $('#grantCategory').change(function () {
                var grantCategory = $(this).val();

                // If a category is selected, fetch the relevant criteria
                if (grantCategory) {
                    $.ajax({
                        url: 'fetchGrantCriteria.php',
                        type: 'POST',
                        data: { grantCategory: grantCategory },
                        dataType: 'json',
                        success: function (response) {
                            if (response.success) {
                                var criteria = response.criteria;

                                // Show or hide WithdrawalVehicle field based on criteria
                                if (criteria.RequiresWithdrawalVehicle == 1) {
                                    $('#withdrawalVehicleDiv').show();
                                    $('#withdrawalVehicleID').prop('required', true);
                                } else {
                                    $('#withdrawalVehicleDiv').hide();
                                    $('#withdrawalVehicleID').removeAttr('required').val('');
                                }

                                // Show or hide the Justification field and populate it if necessary
                                if (criteria.RequiredJustification) {
                                    $('#justificationDiv').show();
                                } else {
                                    $('#justificationDiv').hide();
                                }
                            } else {
                                alert(response.message || 'Error fetching requirements.');
                            }
                        },
                        error: function () {
                            alert('An error occurred while fetching grant requirements.');
                        }
                    });
                } else {
                    $('#withdrawalVehicleDiv').hide();
                    $('#justificationDiv').hide();
                    $('#withdrawalVehicleID').removeAttr('required');
                }
            });
        });
    </script>

</body>
</html>
