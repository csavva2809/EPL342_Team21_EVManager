<?php
session_start();
include 'connect.php'; // Ensure this file sets up the SQL Server connection

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $loginType = $_POST['loginType']; // 'individual' or 'legal_entity'
    $error_message = '';

    if ($loginType === 'individual') {
        // Individual user login
        $userName = trim($_POST['userName']);
        $password = trim($_POST['password']);

        if (empty($userName) || empty($password)) {
            $error_message = "Username and password are required.";
        } else {
            // Validate login
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
                    // Get user details
                    $userId = null;
                    $role = null;
                    $getUserDetailsSql = "{CALL GetUserDetails(?, ?, ?)}";
                    $detailsParams = array(
                        array($userName, SQLSRV_PARAM_IN),
                        array(&$userId, SQLSRV_PARAM_OUT, SQLSRV_PHPTYPE_INT),
                        array(&$role, SQLSRV_PARAM_OUT, SQLSRV_PHPTYPE_STRING(SQLSRV_ENC_CHAR))
                    );

                    $stmt = sqlsrv_query($conn, $getUserDetailsSql, $detailsParams);
                    if ($stmt === false) {
                        $error_message = "Error retrieving user details: " . print_r(sqlsrv_errors(), true);
                    } else {
                        sqlsrv_next_result($stmt);
                        sqlsrv_free_stmt($stmt);

                        if ($userId !== null && $role !== null) {
                            $_SESSION['userType'] = 'individual';
                            $_SESSION['userName'] = $userName;
                            $_SESSION['UserID'] = $userId; // Store UserID in session
                            $_SESSION['role'] = $role;
                            header("Location: index.php");
                            exit();
                        } else {
                            $error_message = "User details not found.";
                        }
                    }
                } else {
                    $error_message = "Invalid username or password.";
                }
            }
        }
    } elseif ($loginType === 'legal_entity') {
        // Legal entity login
        $email = trim($_POST['email']);
        $password = trim($_POST['password']);

        if (empty($email) || empty($password)) {
            $error_message = "Email and password are required.";
        } else {
            // Validate login
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
                    // Get legal entity details
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
                        $error_message = "Error retrieving legal entity details: " . print_r(sqlsrv_errors(), true);
                    } else {
                        sqlsrv_next_result($stmt);
                        sqlsrv_free_stmt($stmt);

                        if ($userId !== null && $companyName !== null) {
                            $_SESSION['userType'] = 'legal_entity';
                            $_SESSION['UserID'] = $userId; // Store UserID in session
                            $_SESSION['companyName'] = $companyName;
                            header("Location: index_dashboard.php");
                            exit();
                        } else {
                            $error_message = "Legal entity details not found.";
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
    <style>
        /* Basic reset and body styling */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f9;
            padding-top: 50px; /* Space for the navbar */
        }

        /* Navbar Styling */
        nav {
            background-color: #333;
            color: #fff;
            padding: 10px 20px;
            text-align: center;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 10;
        }

        nav a {
            color: white;
            text-decoration: none;
            padding: 10px 20px;
            margin: 0 10px;
        }

        nav a:hover {
            background-color: #575757;
        }

        /* Form container styling */
        .form-container {
            background-color: #fff;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 400px;
            margin: 100px auto 0; /* Adjust for navbar space */
        }

        h2 {
            text-align: center;
            color: #333;
        }

        /* Styling for form labels and inputs */
        form {
            display: flex;
            flex-direction: column;
        }

        label {
            margin-bottom: 8px;
            font-size: 14px;
            color: #555;
        }

        input[type="text"],
        input[type="email"],
        input[type="password"] {
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 14px;
        }

        input[type="submit"] {
            padding: 10px;
            font-size: 16px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        input[type="submit"]:hover {
            background-color: #0056b3;
        }

        /* Error message styling */
        .error {
            color: #d9534f;
            background-color: #f2dede;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 15px;
        }

        /* Button for switching forms */
        button {
            padding: 8px 15px;
            background-color: #6c757d;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            width: 100%;
            margin-bottom: 20px;
            transition: background-color 0.3s ease;
        }

        button:hover {
            background-color: #5a6268;
        }

        /* Mobile responsiveness: Make form container full width on small screens */
        @media (max-width: 600px) {
            .form-container {
                width: 90%;
            }
        }
    </style>
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
            <input type="hidden" name="loginType" value="individual">
            <label for="userName">Username:</label>
            <input type="text" id="userName" name="userName" required>
            <label for="password">Password:</label>
            <input type="password" id="password" name="password" required>
            <input type="submit" value="Login">
        </form>

        <!-- Legal Entity Login Form -->
        <form id="legalForm" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" method="post" style="display: none;">
            <input type="hidden" name="loginType" value="legal_entity">
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
