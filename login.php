<?php
session_start();
include 'connect.php'; // Ensure this file sets up the sqlsrv connection

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $loginType = $_POST['loginType']; // 'user' or 'legal'
    $error_message = '';

    if ($loginType === 'user') {
        // Individual user login
        $userName = trim($_POST['userName']);
        $password = trim($_POST['password']);

        if (empty($userName) || empty($password)) {
            $error_message = "Username and password are required.";
        } else {
            // Retrieve hashed password
            $hashedPassword = null;
            $validateLoginSql = "{CALL ValidateLogin(?, ?)}";
            $validateParams = array(
                array($userName, SQLSRV_PARAM_IN),
                array(&$hashedPassword, SQLSRV_PARAM_OUT, SQLSRV_PHPTYPE_STRING(SQLSRV_ENC_CHAR))
            );

            $stmt = sqlsrv_query($conn, $validateLoginSql, $validateParams);

            if ($stmt === false) {
                $error_message = "Database error during login validation: " . print_r(sqlsrv_errors(), true);
            } else {
                sqlsrv_next_result($stmt);
                sqlsrv_free_stmt($stmt);

                if ($hashedPassword && password_verify($password, $hashedPassword)) {
                    // Retrieve user details
                    $personId = null;
                    $role = null;

                    $getUserDetailsSql = "{CALL GetUserDetails(?, ?, ?)}";
                    $detailsParams = array(
                        array($userName, SQLSRV_PARAM_IN),
                        array(&$personId, SQLSRV_PARAM_OUT, SQLSRV_PHPTYPE_STRING(SQLSRV_ENC_CHAR)),
                        array(&$role, SQLSRV_PARAM_OUT, SQLSRV_PHPTYPE_STRING(SQLSRV_ENC_CHAR))
                    );

                    $stmt = sqlsrv_query($conn, $getUserDetailsSql, $detailsParams);
                    if ($stmt === false) {
                        $error_message = "Database error during user details retrieval: " . print_r(sqlsrv_errors(), true);
                    } else {
                        sqlsrv_next_result($stmt);
                        sqlsrv_free_stmt($stmt);

                        if ($personId && $role) {
                            // Set session variables for a user
                            $_SESSION['userType'] = 'user';
                            $_SESSION['userName'] = $userName;
                            $_SESSION['personId'] = $personId;
                            $_SESSION['role'] = $role;

                            // Redirect to user dashboard
                            header("Location: index.php");
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
    } elseif ($loginType === 'legal') {
        // Legal entity login
        $email = trim($_POST['email']);
        $password = trim($_POST['password']);

        if (empty($email) || empty($password)) {
            $error_message = "Email and password are required.";
        } else {
            // Retrieve hashed password for legal entities
            $hashedPassword = null;
            $validateLoginSql = "{CALL ValidateLegalEntityLogin(?, ?)}";
            $validateParams = array(
                array($email, SQLSRV_PARAM_IN),
                array(&$hashedPassword, SQLSRV_PARAM_OUT, SQLSRV_PHPTYPE_STRING(SQLSRV_ENC_CHAR))
            );

            $stmt = sqlsrv_query($conn, $validateLoginSql, $validateParams);

            if ($stmt === false) {
                $error_message = "Database error during legal entity login validation: " . print_r(sqlsrv_errors(), true);
            } else {
                sqlsrv_next_result($stmt);
                sqlsrv_free_stmt($stmt);

                if ($hashedPassword && password_verify($password, $hashedPassword)) {
                    // Retrieve legal entity details
                    $userId = null;
                    $companyName = null;

                    $getLegalEntityDetailsSql = "{CALL GetLegalEntityDetails(?, ?, ?)}";
                    $detailsParams = array(
                        array($email, SQLSRV_PARAM_IN),
                        array(&$userId, SQLSRV_PARAM_OUT, SQLSRV_PHPTYPE_INT),
                        array(&$companyName, SQLSRV_PARAM_OUT, SQLSRV_PHPTYPE_STRING(SQLSRV_ENC_CHAR))
                    );

                    $stmt = sqlsrv_query($conn, $getLegalEntityDetailsSql, $detailsParams);

                    if ($stmt === false) {
                        $error_message = "Database error during legal entity details retrieval: " . print_r(sqlsrv_errors(), true);
                    } else {
                        sqlsrv_next_result($stmt);
                        sqlsrv_free_stmt($stmt);

                        if ($userId && $companyName) {
                            // Set session variables for a legal entity
                            $_SESSION['userType'] = 'legal';
                            $_SESSION['userId'] = $userId;
                            $_SESSION['companyName'] = $companyName;

                            // Redirect to the appropriate dashboard
                            header("Location: index_dashboard.php");
                            exit();
                        } else {
                            $error_message = "Failed to retrieve legal entity details.";
                        }
                    }
                } else {
                    $error_message = "Invalid email or password.";
                }
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
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <?php include 'navbar.php'; ?>

    <div class="form-container">
        <h2>Login</h2>
        <?php if (!empty($error_message)): ?>
            <p class="error"><?php echo htmlspecialchars($error_message); ?></p>
        <?php endif; ?>

        <button id="toggleFormBtn">Switch to Legal Entity Login</button>

        <!-- Individual User Login Form -->
        <form id="userForm" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" method="post" style="display: block;">
            <input type="hidden" name="loginType" value="user">

            <label for="userName">Username:</label>
            <input type="text" id="userName" name="userName" required>

            <label for="password">Password:</label>
            <input type="password" id="password" name="password" required>

            <input type="submit" value="Login">
        </form>

        <!-- Legal Entity Login Form -->
        <form id="legalForm" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" method="post" style="display: none;">
            <input type="hidden" name="loginType" value="legal">

            <label for="email">Email:</label>
            <input type="email" id="email" name="email" required>

            <label for="passwordLegal">Password:</label>
            <input type="password" id="passwordLegal" name="password" required>

            <input type="submit" value="Login">
        </form>
    </div>

    <script>
        const toggleFormBtn = document.getElementById('toggleFormBtn');
        const userForm = document.getElementById('userForm');
        const legalForm = document.getElementById('legalForm');

        toggleFormBtn.addEventListener('click', () => {
            if (userForm.style.display === 'none') {
                userForm.style.display = 'block';
                legalForm.style.display = 'none';
                toggleFormBtn.textContent = 'Switch to Legal Entity Login';
            } else {
                userForm.style.display = 'none';
                legalForm.style.display = 'block';
                toggleFormBtn.textContent = 'Switch to Individual User Login';
            }
        });
    </script>
</body>
</html>
