<?php
session_start();
include 'connect.php'; // Ensure this file sets up the sqlsrv connection

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Retrieve login form data
    $userName = $_POST['userName'];
    $password = $_POST['password'];

    // Initialize variables
    $error_message = ''; // For error feedback
    $storedPassword = ''; // To retrieve the hashed password

    // Prepare the query to fetch the hashed password
    $sqlFetch = "SELECT Password, Role FROM Users WHERE UserName = ?";
    $stmtFetch = sqlsrv_query($conn, $sqlFetch, array($userName));

    if ($stmtFetch === false) {
        // Output error details
        $error_message = "Error fetching hashed password: " . print_r(sqlsrv_errors(), true);
    } else {
        // Fetch the hashed password and role
        $row = sqlsrv_fetch_array($stmtFetch, SQLSRV_FETCH_ASSOC);
        sqlsrv_free_stmt($stmtFetch);

        if ($row) {
            $storedPassword = $row['Password'];
            $userRole = $row['Role']; // Fetch the role directly

            // Verify the provided password against the stored hash
            if (password_verify($password, $storedPassword)) {
                // Successful login
                $_SESSION['user'] = $userName;
                $_SESSION['role'] = $userRole; // Store the role in the session
                header("Location: index.php"); // Redirect to a dashboard or home page
                exit();
            } else {
                // Invalid credentials
                $error_message = "Invalid username or password.";
            }
        } else {
            // Username not found
            $error_message = "Invalid username or password.";
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
    <link rel="stylesheet" href="style.css"> <!-- Link to your CSS file -->
</head>
<body>
    <?php include 'navbar.php'; ?>

    <div class="login-form">
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

