<?php
session_start();
include 'connect.php'; // Ensure this file sets up the sqlsrv connection

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Retrieve login form data
    $userName = trim($_POST['userName']);
    $password = trim($_POST['password']);
    $error_message = '';

    // Validate user input
    if (empty($userName) || empty($password)) {
        $error_message = "Username and password are required.";
    } else {
        // Initialize output parameter for hashed password
        $hashedPassword = null;

        // Call ValidateLogin stored procedure
        $validateLoginSql = "{CALL ValidateLogin(?, ?)}";
        $validateParams = array(
            array($userName, SQLSRV_PARAM_IN),  // Input: Username
            array(&$hashedPassword, SQLSRV_PARAM_OUT, SQLSRV_PHPTYPE_STRING(SQLSRV_ENC_CHAR)) // Output: Hashed password
        );

        $stmt = sqlsrv_query($conn, $validateLoginSql, $validateParams);

        if ($stmt === false) {
            $error_message = "Database error during login validation: " . print_r(sqlsrv_errors(), true);
        } else {
            sqlsrv_next_result($stmt); // Ensure output parameters are available
            sqlsrv_free_stmt($stmt);

            // Step 2: Verify password using password_verify
            if ($hashedPassword && password_verify($password, $hashedPassword)) {
                // Step 3: Retrieve user details (PersonID and Role) using GetUseDetails
                $personId = null;
                $role = null;

                $getUserDetailsSql = "{CALL GetUseDetails(?, ?, ?)}";
                $detailsParams = array(
                    array($userName, SQLSRV_PARAM_IN),  // Input: Username
                    array(&$personId, SQLSRV_PARAM_OUT, SQLSRV_PHPTYPE_STRING(SQLSRV_ENC_CHAR)), // Output: PersonID
                    array(&$role, SQLSRV_PARAM_OUT, SQLSRV_PHPTYPE_STRING(SQLSRV_ENC_CHAR))      // Output: Role
                );

                $stmt = sqlsrv_query($conn, $getUserDetailsSql, $detailsParams);
                if ($stmt === false) {
                    $error_message = "Database error during user details retrieval: " . print_r(sqlsrv_errors(), true);
                } else {
                    sqlsrv_next_result($stmt);
                    sqlsrv_free_stmt($stmt);

                    if ($personId && $role) {
                        $_SESSION['user'] = $userName;
                        $_SESSION['personId'] = $personId;
                        $_SESSION['role'] = $role;

                        header("Location: user_dashboard.php");
                        exit();
                    } else {
                        $error_message = "Failed to retrieve user details.";
                    }
                }
            } else {
                $error_message = "Invalid username or password.";
            }
        }
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    <link rel="stylesheet" href="style.css"> <!-- Adjust the path if necessary -->
</head>
<body>
    <?php include 'navbar.php'; ?>

    <div class="form-container">
        <h2>Login</h2>
        <?php if (!empty($error_message)): ?>
            <p class="error"><?php echo htmlspecialchars($error_message); ?></p>
        <?php endif; ?>
        <form action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" method="post">
            <label for="userName">Username:</label>
            <input type="text" id="userName" name="userName" required>

            <label for="password">Password:</label>
            <input type="password" id="password" name="password" required>

            <input type="submit" value="Login">
        </form>
    </div>
</body>
</html>

