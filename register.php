<?php
session_start();
include 'connect.php'; // Ensure this file sets up the sqlsrv connection

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $registrationType = $_POST['registrationType']; // 'user' or 'legal'
    $success = 0;
    $message = '';

    if ($registrationType === 'user') {
        // Individual user registration
        $personId = $_POST['personId'];
        $lastName = $_POST['lastName'];
        $firstName = $_POST['firstName'];
        $userName = $_POST['userName'];
        $email = $_POST['email'];
        $passwordHash = password_hash($_POST['password'], PASSWORD_DEFAULT); // Hash the password
        $address = $_POST['address'];
        $birthDate = $_POST['birthDate'];
        $phone = $_POST['phone'];
        $sex = $_POST['sex'];

        $sql = "{CALL RegisterUser(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}";
        $params = array(
            array($personId, SQLSRV_PARAM_IN),
            array($lastName, SQLSRV_PARAM_IN),
            array($firstName, SQLSRV_PARAM_IN),
            array($userName, SQLSRV_PARAM_IN),
            array($email, SQLSRV_PARAM_IN),
            array($passwordHash, SQLSRV_PARAM_IN),
            array($address, SQLSRV_PARAM_IN),
            array($birthDate, SQLSRV_PARAM_IN),
            array($phone, SQLSRV_PARAM_IN),
            array($sex, SQLSRV_PARAM_IN),
            array(&$success, SQLSRV_PARAM_OUT),
            array(&$message, SQLSRV_PARAM_OUT)
        );
    } elseif ($registrationType === 'legal') {
        // Legal entity registration
        $companyName = $_POST['companyName'];
        $registrationNumber = $_POST['registrationNumber'];
        $taxNumber = $_POST['taxNumber'];
        $establishedDate = $_POST['establishedDate'];
        $address = $_POST['address'];
        $phone = $_POST['phone'];
        $email = $_POST['email'];
        $passwordHash = password_hash($_POST['password'], PASSWORD_DEFAULT); // Hash the password

        $sql = "{CALL RegisterLegalEntity(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}";
        $params = array(
            array($companyName, SQLSRV_PARAM_IN),
            array($registrationNumber, SQLSRV_PARAM_IN),
            array($taxNumber, SQLSRV_PARAM_IN),
            array($establishedDate, SQLSRV_PARAM_IN),
            array($address, SQLSRV_PARAM_IN),
            array($phone, SQLSRV_PARAM_IN),
            array($email, SQLSRV_PARAM_IN),
            array($passwordHash, SQLSRV_PARAM_IN),
            array(&$success, SQLSRV_PARAM_OUT),
            array(&$message, SQLSRV_PARAM_OUT)
        );
    }

    // Execute the stored procedure based on registration type
    $stmt = sqlsrv_query($conn, $sql, $params);

    if ($stmt === false) {
        $error_message = "Database error: " . print_r(sqlsrv_errors(), true);
    } else {
        sqlsrv_next_result($stmt);
        sqlsrv_free_stmt($stmt);

        if ($success) {
            $_SESSION['success_message'] = $message;
            header("Location: login.php");
            exit();
        } else {
            $error_message = $message;
        }
    }
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register</title>
    <link rel="stylesheet" href="style.css"> <!-- Link to your CSS file -->
</head>
<body>
    <?php include 'navbar.php'; ?>

    <div class="form-container">
        <h2>Register</h2>
        <?php if (!empty($error_message)): ?>
            <p class="error"><?php echo htmlspecialchars($error_message); ?></p>
        <?php endif; ?>

        <button id="toggleFormBtn">Switch to Legal Entity Registration</button>

        <!-- Individual User Registration Form -->
        <form id="userForm" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" method="post" style="display: block;">
            <input type="hidden" name="registrationType" value="user">

            <label for="personId">Person ID:</label>
            <input type="text" id="personId" name="personId" required>

            <label for="firstName">First Name:</label>
            <input type="text" id="firstName" name="firstName" required>

            <label for="lastName">Last Name:</label>
            <input type="text" id="lastName" name="lastName" required>

            <label for="userName">Username:</label>
            <input type="text" id="userName" name="userName" required>

            <label for="email">Email:</label>
            <input type="email" id="email" name="email" required>

            <label for="password">Password:</label>
            <input type="password" id="password" name="password" required>

            <label for="address">Address:</label>
            <input type="text" id="address" name="address" required>

            <label for="birthDate">Birth Date:</label>
            <input type="date" id="birthDate" name="birthDate" required>

            <label for="phone">Phone:</label>
            <input type="int" id="phone" name="phone" required>

            <label for="sex">Sex:</label>
            <select id="sex" name="sex" required>
                <option value="male">Male</option>
                <option value="female">Female</option>
                <option value="other">Other</option>
            </select>

            <input type="submit" value="Register">
        </form>

        <!-- Legal Entity Registration Form -->
        <form id="legalForm" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" method="post" style="display: none;">
            <input type="hidden" name="registrationType" value="legal">

            <label for="companyName">Company Name:</label>
            <input type="text" id="companyName" name="companyName" required>

            <label for="registrationNumber">Registration Number:</label>
            <input type="text" id="registrationNumber" name="registrationNumber" required>

            <label for="taxNumber">Tax Number:</label>
            <input type="text" id="taxNumber" name="taxNumber" required>

            <label for="establishedDate">Established Date:</label>
            <input type="date" id="establishedDate" name="establishedDate" required>

            <label for="address">Address:</label>
            <input type="text" id="address" name="address" required>

            <label for="phone">Phone:</label>
            <input type="tel" id="phone" name="phone" required>

            <label for="email">Email:</label>
            <input type="email" id="email" name="email" required>

            <label for="password">Password:</label>
            <input type="password" id="password" name="password" required>

            <input type="submit" value="Register">
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
                toggleFormBtn.textContent = 'Switch to Legal Entity Registration';
            } else {
                userForm.style.display = 'none';
                legalForm.style.display = 'block';
                toggleFormBtn.textContent = 'Switch to User Registration';
            }
        });
    </script>
</body>
</html>
