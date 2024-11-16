<?php
session_start();
include 'connect.php'; // Include the database connection

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Collect and sanitize user input
    $username = htmlspecialchars($_POST['username']);
    $password = htmlspecialchars($_POST['password']);

    // Prepare and execute the SQL query
    $sql = "SELECT * FROM Users WHERE Username = ?"; // Use a parameterized query
    $params = array($username);
    $stmt = sqlsrv_query($conn, $sql, $params);

    if ($stmt === false) {
        die(print_r(sqlsrv_errors(), true));
    }

    // Check if a user was found
    if ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
        // Verify the password
        if (password_verify($password, $row['Password'])) {
            $_SESSION['user_id'] = $row['Id']; // Store the user ID in the session
            $_SESSION['username'] = $row['Username'];
            echo "<script>alert('Login successful! Welcome, " . $row['Name'] . "');</script>";
        } else {
            echo "<script>alert('Invalid password. Please try again.');</script>";
        }
    } else {
        echo "<script>alert('Invalid username. Please try again.');</script>";
    }

    // Free the statement and close the connection
    sqlsrv_free_stmt($stmt);
    sqlsrv_close($conn);
}
?>

<?php include 'navbar.php'; ?>


<!DOCTYPE html>
<html>
<head>
    <title>Login Page</title>
    <style>
        /* Basic reset and styling */
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .login-container {
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 400px;
        }
        .login-container h2 {
            text-align: center;
            margin-bottom: 20px;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            font-weight: bold;
            margin-bottom: 5px;
        }
        .form-group input {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }
        .login-btn {
            width: 100%;
            padding: 10px;
            background-color: #5cb85c;
            border: none;
            color: white;
            font-weight: bold;
            border-radius: 5px;
            cursor: pointer;
        }
        .login-btn:hover {
            background-color: #4cae4c;
        }
        .alert {
            color: red;
            font-size: 0.9em;
            text-align: center;
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <h2>Login</h2>
        <form method="POST" action="login.php">
            <div class="form-group">
                <label for="username">Username:</label>
                <input type="text" id="username" name="username" required>
            </div>
            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>
            </div>
            <button type="submit" class="login-btn">Login</button>
        </form>
    </div>
</body>
</html>

