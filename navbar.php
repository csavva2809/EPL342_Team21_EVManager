<?php
session_start();
?>
<?php
if (isset($_SESSION['user'])) {
    echo "Logged in as: " . htmlspecialchars($_SESSION['user']);
    echo " Role: " . htmlspecialchars($_SESSION['role']);
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="navbar.css"> <!-- Link to your CSS file -->
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
            <a href="about.php">About</a>
            <a href="services.php">Services</a>
            <a href="contact.php">Contact</a>
        </div>

        <!-- Right: Login, Register, and Role-Specific Dashboard Buttons -->
        <div class="navbar-auth">
            <?php if (isset($_SESSION['user'])): ?>
                <?php
                // Fetch user's role from the session
                $userRole = isset($_SESSION['role']) ? $_SESSION['role'] : 'user';

                // Display a dashboard button based on the role
                if ($userRole === 'admin') {
                    echo '<a href="admin_dashboard.php" class="btn">Admin Dashboard</a>';
                } elseif ($userRole === 'TOM') {
                    echo '<a href="tom_dashboard.php" class="btn">TOM Dashboard</a>';
                } elseif ($userRole === 'dealer') {
                    echo '<a href="dealer_dashboard.php" class="btn">Dealer Dashboard</a>';
                } else {
                    echo '<a href="user_dashboard.php" class="btn">User Dashboard</a>';
                }
                ?>
                <a href="logout.php" class="btn">Logout</a>
            <?php else: ?>
                <a href="login.php" class="btn">Login</a>
                <a href="register.php" class="btn btn-register">Register</a>
            <?php endif; ?>
        </div>
    </nav>
</body>
</html>

