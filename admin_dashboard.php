<?php
session_start();
include 'connect.php'; // Ensure this file sets up the sqlsrv connection

// Check if the logged-in user is an admin
if (!isset($_SESSION['user']) || $_SESSION['role'] !== 'admin') {
    header("Location: index.php"); // Redirect to the home page if not an admin
    exit();
}

// Handle form submission for role change
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $adminUserName = $_SESSION['user']; // Admin's username from the session
    $targetUserName = $_POST['targetUserName'];
    $newRole = $_POST['newRole'];

    // Prepare the stored procedure and parameters
    $sql = "{CALL ChangeRole(?, ?, ?)}";
    $params = array(
        array($adminUserName, SQLSRV_PARAM_IN),
        array($targetUserName, SQLSRV_PARAM_IN),
        array($newRole, SQLSRV_PARAM_IN)
    );

    // Execute the stored procedure
    $stmt = sqlsrv_query($conn, $sql, $params);

    if ($stmt === false) {
        $error_message = "Error executing stored procedure: " . print_r(sqlsrv_errors(), true);
    } else {
        $success_message = "Role updated successfully for user: $targetUserName";
        sqlsrv_free_stmt($stmt);
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard</title>
    <link rel="stylesheet" href="style.css"> <!-- Link to your CSS file -->
</head>
<body>
    <?php include 'navbar.php'; ?>

    <div class="dashboard-container">
        <h2>Admin Dashboard</h2>
        <p>Welcome, <?php echo htmlspecialchars($_SESSION['user']); ?>!</p>

        <!-- Role Changing Section -->
        <div class="role-management-section">
            <button id="toggleFormBtn" class="btn">Change User Roles</button>

            <!-- Form to change user role -->
            <div id="roleChangeForm" style="display: none; margin-top: 20px;">
                <h3>Change User Role</h3>
                <?php if (!empty($error_message)): ?>
                    <p class="error"><?php echo htmlspecialchars($error_message); ?></p>
                <?php elseif (!empty($success_message)): ?>
                    <p class="success"><?php echo htmlspecialchars($success_message); ?></p>
                <?php endif; ?>
                <form class="role-change-form" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" method="post">
                    <label for="targetUserName">Target Username:</label>
                    <input type="text" id="targetUserName" name="targetUserName" placeholder="Enter username" required>

                    <label for="newRole">New Role:</label>
                    <select id="newRole" name="newRole" required>
                        <option value="user">User</option>
                        <option value="admin">Admin</option>
                        <option value="TOM">TOM</option>
                        <option value="dealer">Dealer</option>
                    </select>

                    <input type="submit" value="Change Role">
                </form>
            </div>
        </div>
    </div>

    <script>
        // JavaScript to toggle form visibility
        document.getElementById('toggleFormBtn').addEventListener('click', function () {
            const form = document.getElementById('roleChangeForm');
            form.style.display = form.style.display === 'none' ? 'block' : 'none';
        });
    </script>
</body>
</html>

