<?php
session_start();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="style.css">
    <title>Government Portal</title>
</head>
<body>
    <?php include 'navbar.php'; ?>

    <div class="home-container">
        <h1>Welcome to the Government Portal</h1>
        <p>Start your application for available grants to promote innovation and sustainability.</p>
        <div class="cta-section">
            <a href="grants.php" class="btn btn-cta">Start Application</a>
        </div>
    </div>
</body>
</html>
