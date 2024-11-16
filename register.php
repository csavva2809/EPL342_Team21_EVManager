<?php
session_start();
include 'connect.php'; // Include the database connection

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Collect and sanitize user input
    $name = htmlspecialchars($_POST['name']);
    $surname = htmlspecialchars($_POST['surname']);
    $username = htmlspecialchars($_POST['username']);
    $email = htmlspecialchars($_POST['email']);
    $address = htmlspecialchars($_POST['address']);
    $role = htmlspecialchars($_POST['role']);
    $phone = htmlspecialchars($_POST['phone']);
    $dob = htmlspecialchars($_POST['dob']);
    $password = htmlspecialchars($_POST['password']);
    $hashedPassword = password_hash($password, PASSWORD_DEFAULT); // Hash the password

    // Prepare the SQL call to the stored procedure
    $sql = "{CALL RegisterUser(?, ?, ?, ?, ?, ?, ?, ?, ?)}";
    $params = array($name, $surname, $username, $email, $address, $role, $phone, $dob, $hashedPassword);

    // Execute the stored procedure
    $stmt = sqlsrv_query($conn, $sql, $params);

    if ($stmt === false) {
        // If there is an error, show an alert and print the error details
        echo "<script>alert('Registration failed! Please try again.');</script>";
        die(print_r(sqlsrv_errors(), true));
    } else {
        // If registration is successful, show a success message
        echo "<script>alert('Registration successful! You can now log in.');</script>";
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
    <title>Register Page</title>
    <style>
        /* Basic styling */
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
        .register-container {
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 500px;
        }
        .register-container h2 {
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
        .register-btn {
            width: 100%;
            padding: 10px;
            background-color: #007bff;
            border: none;
            color: white;
            font-weight: bold;
            border-radius: 5px;
            cursor: pointer;
        }
        .register-btn:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>
    <div class="register-container">
        <h2>Register</h2>
        <form method="POST" action="register.php">
            <div class="form-group">
                <label for="name">Name:</label>
                <input type="text" id="name" name="name" required>
            </div>
            <div class="form-group">
                <label for="surname">Surname:</label>
                <input type="text" id="surname" name="surname" required>
            </div>
            <div class="form-group">
                <label for="username">Username:</label>
                <input type="text" id="username" name="username" required>
            </div>
            <div class="form-group">
                <label for="email">Email:</label>
                <input type="email" id="email" name="email" required>
            </div>
            <div class="form-group">
                <label for="address">Address:</label>
                <input type="text" id="address" name="address">
            </div>
            <div class="form-group">
                <label for="role">Role:</label>
                <input type="text" id="role" name="role">
            </div>
            <div class="form-group">
                <label for="phone">Phone:</label>
                <input type="text" id="phone" name="phone">
            </div>
            <div class="form-group">
                <label for="dob">Date of Birth:</label>
                <input type="date" id="dob" name="dob">
            </div>
            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>
            </div>
            <button type="submit" class="register-btn">Register</button>
        </form>
    </div>
</body>
</html>
