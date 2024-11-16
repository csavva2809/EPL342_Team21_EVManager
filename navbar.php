<?php
session_start();
?>
<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" type="text/css" href="style.css">
</head>
<body>
    <nav class="navbar">
        <div class="logo">
            <a href="index.php">MyLogo</a>
        </div>
        <ul class="nav-links">
            <li><a href="services.php">Services</a></li>
            <li><a href="projects.php">Projects</a></li>
            <li><a href="about.php">About</a></li>
            <li><a href="contact.php">Contact</a></li>
        </ul>
        <div class="auth-links">
            <?php
            if (isset($_SESSION['username'])) {
                // If the user is logged in, show the greeting and logout button
                echo "<span class='greeting'>Hello, " . htmlspecialchars($_SESSION['username']) . "!</span>";
                echo '<a href="logout.php" class="logout-button">Log Out</a>';
            } else {
                // If the user is not logged in, show login and sign up links
                echo '<a href="login.php">Log In</a>';
                echo '<a href="register.php" class="signup-button">Sign Up</a>';
            }
            ?>
        </div>
    </nav>
</body>
</html>

