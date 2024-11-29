<?php
session_start();
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="style.css"> <!-- Link to your CSS file -->
</head>
<body>
    <nav class="navbar">
        <!-- Left: Logo -->
        <div class="navbar-logo">
            <a href="index.php">
                <img src="logo.png" alt="Logo" class="logo">
            </a>
        </div>

        <!-- Middle: Navigation Buttons -->
        <div class="navbar-menu">
            <a href="index.php">Home</a>
            <a href="grants.php">Available Grants</a>
            <a href="create_application.php">Apply For Grants</a>
        </div>

        <!-- Right: Login, Register, and Dashboard Buttons -->
        <div class="navbar-auth">
            <?php if (isset($_SESSION['userName']) || isset($_SESSION['companyName'])): ?>
                <!-- Display user info when logged in -->
                <?php if (isset($_SESSION['userName'])): ?>
                    <span>Logged in as: <?php echo htmlspecialchars($_SESSION['userName']); ?></span>
                <?php elseif (isset($_SESSION['companyName'])): ?>
                    <span>Logged in as: <?php echo htmlspecialchars($_SESSION['companyName']); ?></span>
                <?php endif; ?>

                <?php
                // Fetch user's role from the session
                $userRole = $_SESSION['role'];

                // Display a role-specific dashboard button based on the role
                if ($userRole === 'admin') {
                    echo '<a href="admin_dashboard.php" class="btn">Admin Dashboard</a>';
                } elseif ($userRole === 'TOM') {
                    echo '<a href="tom_dashboard.php" class="btn">TOM Dashboard</a>';
                } elseif ($userRole === 'dealer') {
                    echo '<a href="dealer_dashboard.php" class="btn">Dealer Dashboard</a>';
                } elseif ($userRole === 'user') {
                    echo '<a href="user_dashboard.php" class="btn">User Dashboard</a>';
                }
                ?>

                <!-- Logout button -->
                <a href="logout.php" class="btn">Logout</a>
            <?php else: ?>
                <!-- Show login and register buttons when not logged in -->
                <a href="login.php" class="btn">Login</a>
                <a href="register.php" class="btn btn-register">Register</a>
            <?php endif; ?>                
        </div>
    </nav>
</body>
</html>
