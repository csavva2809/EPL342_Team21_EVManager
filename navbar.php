<?php
session_start();
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
            <a href="apply_for_grant.php">Apply For Grants</a>
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
