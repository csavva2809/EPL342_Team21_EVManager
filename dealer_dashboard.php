<?php
session_start();
include 'connect.php'; // Ensure this file sets up the SQL Server connection

if (!isset($_SESSION['userName']) || $_SESSION['role'] !== 'dealer') {
    header("Location: index.php"); // Redirect to the home page if not a dealer
    exit();
}

$userId = $_SESSION['UserID'];  // Fetch dealer's UserID from session

// Initialize error and success messages
$error_message = '';
$success_message = '';

// Fetch all applications using the DisplayApplications stored procedure
$sql = "{CALL DisplayApplications()}";
$stmt = sqlsrv_query($conn, $sql);

if ($stmt === false) {
    $error_message = "Error fetching applications: " . print_r(sqlsrv_errors(), true);
} else {
    $applicationTable = '';
    while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
        $applicationTable .= "<tr>
            <td>" . htmlspecialchars($row['ApplicationID']) . "</td>
            <td>" . htmlspecialchars($row['UserID']) . "</td>
            <td>" . htmlspecialchars($row['UserName']) . "</td>
            <td>" . htmlspecialchars($row['UserType']) . "</td>
            <td>" . htmlspecialchars($row['GrantCategory']) . "</td>
            <td>" . htmlspecialchars($row['VehicleType']) . "</td>
            <td>" . htmlspecialchars($row['WithdrawalVehicleID']) . "</td>
            <td>" . htmlspecialchars($row['ApplicationDate']->format('Y-m-d')) . "</td>
            <td>" . htmlspecialchars($row['ExpirationDate'] ? $row['ExpirationDate']->format('Y-m-d') : 'N/A') . "</td>
            <td>" . htmlspecialchars($row['Email']) . "</td>
        </tr>";
    }
    sqlsrv_free_stmt($stmt);
}

// Fetch all vehicles using the ViewVehicle stored procedure
$vehicleTable = '';  // Table will be generated here
$sql = "{CALL ViewVehicle()}";  // Assuming ViewVehicle is the name of your stored procedure

$stmt = sqlsrv_query($conn, $sql);

if ($stmt === false) {
    $error_message = "Error fetching vehicles: " . print_r(sqlsrv_errors(), true);
} else {
    while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
   

        // Append the vehicle row to the table
        $vehicleTable .= "<tr>
            <td>" . htmlspecialchars($row['VehicleID']) . "</td>
            <td>" . htmlspecialchars($row['Maker']) . "</td>
            <td>" . htmlspecialchars($row['Model']) . "</td>
            <td>" . htmlspecialchars($row['CO2grPerKm']) . "</td>
            <td>" . htmlspecialchars($row['Price']) . "</td>
        </tr>";
    }
    sqlsrv_free_stmt($stmt);
}


// Handle vehicle addition
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_POST['add_vehicle'])) {
    $maker = $_POST['maker'] ?? '';
    $model = $_POST['model'] ?? '';
    $co2 = $_POST['co2'] ?? '';
    $price = $_POST['price'] ?? '';

    // Validate input fields
    if (empty($maker) || empty($model) || empty($co2) || empty($price)) {
        $error_message = "All fields are required to add a vehicle.";
    } else {
        // Declare the $success variable as an integer
        $success = 0;

        // Prepare the SQL to call the stored procedure
        $addVehicleSql = "{CALL AddVehicle(?, ?, ?, ?, ?)}";  // Last ? is for the @Success output parameter
        $params = array(
            array($maker, SQLSRV_PARAM_IN),
            array($model, SQLSRV_PARAM_IN),
            array($co2, SQLSRV_PARAM_IN),
            array($price, SQLSRV_PARAM_IN),
            array(&$success, SQLSRV_PARAM_OUT)  // Reference to the output parameter
        );

        // Execute the stored procedure
        $stmt = sqlsrv_query($conn, $addVehicleSql, $params);

        // Check if the execution was successful
        if ($stmt === false) {
            $error_message = "Error adding vehicle: " . print_r(sqlsrv_errors(), true);
        } else {
            if ($success) {
                $success_message = "Vehicle added successfully!";
            } else {
                $error_message = "Failed to add vehicle.";
            }
        }
        sqlsrv_free_stmt($stmt);
    }
}

// Handle the order creation
if ($_SERVER["REQUEST_METHOD"] === "POST" && isset($_POST['create_order'])) {
    $application_id = $_POST['application_id'] ?? '';
    $vehicle_id = $_POST['vehicle_id'] ?? '';
    $expected_register_date = $_POST['expected_register_date'] ?? '';
    
    // File handling
    $document_id = $_FILES['document_id'] ?? null;

    if (!$document_id || $document_id['error'] !== UPLOAD_ERR_OK) {
        $error_message = "Error uploading file. ";
        
        // Check for specific error code
        $error_code = $_FILES['document_id']['error'];
        switch ($error_code) {
            case UPLOAD_ERR_INI_SIZE:
                $error_message .= "File exceeds max size limit in php.ini.";
                break;
            case UPLOAD_ERR_FORM_SIZE:
                $error_message .= "File exceeds the MAX_FILE_SIZE limit in the form.";
                break;
            case UPLOAD_ERR_PARTIAL:
                $error_message .= "File was only partially uploaded.";
                break;
            case UPLOAD_ERR_NO_FILE:
                $error_message .= "No file uploaded.";
                break;
            case UPLOAD_ERR_NO_TMP_DIR:
                $error_message .= "Missing temporary folder.";
                break;
            case UPLOAD_ERR_CANT_WRITE:
                $error_message .= "Failed to write file to disk.";
                break;
            case UPLOAD_ERR_EXTENSION:
                $error_message .= "File upload stopped by PHP extension.";
                break;
            default:
                $error_message .= "Unknown upload error.";
        }
    } else {
        // Get file details
        $file_name = uniqid("doc_") . "_" . $_FILES['document_id']['name'];
        $file_tmp_name = $_FILES['document_id']['tmp_name'];
        $file_size = $_FILES['document_id']['size'];
        $file_type = "Order";
        
        // Define upload directory
        $upload_dir = '/home/students/cs/2021/ksavva05/public_html/epl342/dbpro/filled_forms/'; // Your desired upload directory
        $file_path = $upload_dir . basename($file_name);
        
        // Move the uploaded file to the server
        if (move_uploaded_file($file_tmp_name, $file_path)) {
            // Call the AddOrder stored procedure
            $sql_add_order = "{CALL AddOrder(?, ?, ?, ?, ?, ?, ?)}";
            $params = array(
                array($application_id, SQLSRV_PARAM_IN),
                array($vehicle_id, SQLSRV_PARAM_IN),
                array($expected_register_date, SQLSRV_PARAM_IN),
                array($file_name, SQLSRV_PARAM_IN),
                array($file_path, SQLSRV_PARAM_IN),
                array($file_size, SQLSRV_PARAM_IN),
                array($file_type, SQLSRV_PARAM_IN)
            );
            
            $stmt = sqlsrv_query($conn, $sql_add_order, $params);
            
            // Check if the execution was successful
            if ($stmt === false) {
                $error_message = "Error creating order: " . print_r(sqlsrv_errors(), true);
            } else {
                $success_message = "Order created successfully!";
            }
            
            sqlsrv_free_stmt($stmt);
        } else {
            $error_message = "Failed to move uploaded file.";
        }
    }
}

?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dealer Dashboard</title>
    <link rel="stylesheet" href="style.css">
    <style>
        /* Add the CSS here */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f4f6f9;    <link rel="stylesheet" href="style.css">

            line-height: 1.6;
        }

        .dashboard-container {
            padding: 20px;
            text-align: center;
        }

        .form-container {
            display: none;
            margin-top: 20px;
        }

        .form-container table {
            width: 100%;
            margin-top: 20px;
            border-collapse: collapse;
        }

        .form-container th, .form-container td {
            padding: 12px;
            text-align: left;
            border: 1px solid #ddd;
        }

        .error {
            color: #d9534f;
            background-color: #f2dede;
            padding: 10px;
            border-radius: 5px;
        }

        .success {
            color: #28a745;
            background-color: #dff0d8;
            padding: 10px;
            border-radius: 5px;
        }

        button {
            background-color: #007bff;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin: 10px;
            transition: background-color 0.3s ease;
        }

        button:hover {
            background-color: #0056b3;
        }

        /* More styles can go here... */
    </style>
</head>
<body>
    <?php include 'navbar.php'; ?>

    <div class="dashboard-container">
        <h1>Dealer Dashboard</h1>

        <?php if ($error_message): ?>
            <p class="error"><?php echo nl2br(htmlspecialchars($error_message)); ?></p>
        <?php elseif ($success_message): ?>
            <p class="success"><?php echo htmlspecialchars($success_message); ?></p>
        <?php endif; ?>

        <!-- Buttons to Show Different Forms -->
        <button onclick="showForm('applications')">See All Applications</button>
        <button onclick="showForm('view_vehicles')">See All Vehicles</button>
        <button onclick="showForm('add_vehicle')">Add a Vehicle</button>
        <button onclick="showForm('create_order')">Create an Order</button>

        <!-- Form Containers (Initially Hidden) -->
        <div id="applications" class="form-container" style="display:none;">
            <h2>Applications</h2>
            <table>
                <thead>
                    <tr>
                        <th>Application ID</th>
                        <th>User ID</th>
                        <th>Username</th>
                        <th>User Type</th>
                        <th>Grant Category</th>
                        <th>Vehicle Type</th>
                        <th>Withdrawal Vehicle ID</th>
                        <th>Application Date</th>
                        <th>Expiration Date</th>
                        <th>Email</th>
                    </tr>
                </thead>
                <tbody>
                    <?= $applicationTable; ?>
                </tbody>
            </table>
        </div>
        <!-- View All Vehicles Form -->
        <div id="view_vehicles" class="form-container" style="display:none;">
            <h2>All Available Vehicles</h2>
            <table>
                <thead>
                    <tr>
                        <th>Vehicle ID</th>
                        <th>Maker</th>
                        <th>Model</th>
                        <th>CO2 (g/km)</th>
                        <th>Price (€)</th>
                    </tr>
                </thead>
                <tbody>
                    <?= $vehicleTable; ?>
                </tbody>
            </table>
        </div>


        <div id="add_vehicle" class="form-container" style="display:none;">
            <h2>Add a Vehicle</h2>
            <form method="POST">
                <label for="maker">Maker:</label>
                <input type="text" id="maker" name="maker" required>

                <label for="model">Model:</label>
                <input type="text" id="model" name="model" required>

                <label for="co2">CO2 (g/km):</label>
                <input type="float" id="co2" name="co2" step = "0.01"  required>

                <label for="price">Price (€):</label>
                <input type="number" id="price" name="price" step="0.01" required>

                <input type="submit" name="add_vehicle" value="Add Vehicle">
            </form>
        </div>

        <div id="create_order" class="form-container" style="display:none;">
            <h2>Create an Order</h2>
            <form method="POST" enctype="multipart/form-data">
                <label for="application_id">Application ID:</label>
                <input type="text" id="application_id" name="application_id" required>

                <label for="vehicle_id">Vehicle ID:</label>
                <input type="text" id="vehicle_id" name="vehicle_id" required>

                <label for="document_id">Document ID:</label>
                <input type="file" id="document_id" name="document_id" required>

                <label for="expected_register_date">Expected Register Date:</label>
                <input type="date" id="expected_register_date" name="expected_register_date" placeholder="YYYY-MM-DD" required>

                <input type="submit" name="create_order" value="Create Order">
            </form>
        </div>
    </div>

    <script>
    // Function to toggle form visibility
    function showForm(formId) {
        // Hide all forms
        const forms = document.querySelectorAll('.form-container');
        forms.forEach(form => form.style.display = 'none');

        // Show the selected form
        document.getElementById(formId).style.display = 'block';
    }
    </script>

</body>
</html>
