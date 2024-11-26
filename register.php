<?php
session_start();
include 'connect.php'; // Ensure this file sets up the sqlsrv connection

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Retrieve form data
    $personId = $_POST['personId']; // Ensure this is provided as a string
    $lastName = $_POST['lastName'];
    $firstName = $_POST['firstName'];
    $userName = $_POST['userName'];
    $email = $_POST['email'];
    $password = password_hash($_POST['password'], PASSWORD_DEFAULT); // Securely hash the password
    $address = $_POST['address'];
    $birthDate = $_POST['birthDate'];
    $phone = $_POST['phone'];
    $sex = $_POST['sex'];

    // Initialize output parameters
    $success = 0; // BIT output parameter
    $message = ''; // NVARCHAR output parameter

    // Prepare the stored procedure and parameters
    $sql = "{CALL RegisterUser(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}";
    $params = array(
        array($personId, SQLSRV_PARAM_IN),
        array($lastName, SQLSRV_PARAM_IN),
        array($firstName, SQLSRV_PARAM_IN),
        array($userName, SQLSRV_PARAM_IN),
        array($email, SQLSRV_PARAM_IN),
        array($password, SQLSRV_PARAM_IN), 
        array($address, SQLSRV_PARAM_IN),
        array($birthDate, SQLSRV_PARAM_IN),
        array($phone, SQLSRV_PARAM_IN),
        array($sex, SQLSRV_PARAM_IN),
        array(&$success, SQLSRV_PARAM_OUT), // Output parameter
        array(&$message, SQLSRV_PARAM_OUT)  // Output parameter
    );

    // Execute the stored procedure
    $stmt = sqlsrv_query($conn, $sql, $params);

    if ($stmt === false) {
        // Output error details
        $error_message = "Error in executing stored procedure: " . print_r(sqlsrv_errors(), true);
    } else {
        // Advance the result set for output parameters
        sqlsrv_next_result($stmt);
        sqlsrv_free_stmt($stmt);

        // Check the output parameters
        if ($success === 1) {
            $_SESSION['success_message'] = $message;
            header("Location: login.php");
            exit();
        } else {
            $error_message = $message;
        }
    }
}
?>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register</title>
    <link rel="stylesheet" href="style.css"> <!-- Link to your CSS file -->
</head>
<body>
    <?php include 'navbar.php'; ?>

    <div class="registration-form">
        <h2>Register</h2>
        <?php if (!empty($error_message)): ?>
            <p class="error"><?php echo htmlspecialchars($error_message); ?></p>
        <?php endif; ?>
        <form action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" method="post">
            <label for="personId">Person ID:</label>
            <input type="number" id="personId" name="personId" required>

            <label for="firstName">First Name:</label>
            <input type="text" id="firstName" name="firstName" required>

            <label for="lastName">Last Name:</label>
            <input type="text" id="lastName" name="lastName" required>

            <label for="userName">Username:</label>
            <input type="text" id="userName" name="userName" required>

            <label for="email">Email:</label>
            <input type="email" id="email" name="email" required>

            <label for="password">Password:</label>
            <input type="password" id="password" name="password" required>

            <label for="address">Address:</label>
            <input type="text" id="address" name="address">

            <label for="birthDate">Birth Date:</label>
            <input type="date" id="birthDate" name="birthDate" required>

            <label for="phone">Phone:</label>
            <input type="tel" id="phone" name="phone">

            <label for="sex">Sex:</label>
            <select id="sex" name="sex" required>
                <option value="male">Male</option>
                <option value="female">Female</option>
                <option value="other">Other</option>
            </select>

            <input type="submit" value="Register">
        </form>
    </div>
</body>
</html>

