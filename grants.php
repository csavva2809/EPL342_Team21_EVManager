<?php
session_start();
include 'connect.php'; // Ensure this file sets up the sqlsrv connection
include 'navbar.php';

// Call the stored procedure
$sql = "{CALL DisplayGrant}";
$stmt = sqlsrv_query($conn, $sql);

if ($stmt === false) {
    die(print_r(sqlsrv_errors(), true)); // Display query errors
}

// Display results in an HTML table
echo "<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Grants</title>
    <style>
        table {
            width: 80%;
            border-collapse: collapse;
            margin: 20px auto;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <h1 style='text-align: center;'>Grant Records</h1>
    <table>
        <thead>
            <tr>
                <th>Grant Category</th>
                <th>Description</th>
                <th>Grant Price</th>
                <th>Available Grants</th>
            </tr>
        </thead>
        <tbody>";

// Fetch data and populate the table
while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
    echo "<tr>
            <td>" . htmlspecialchars($row['GrantCategory']) . "</td> <!-- Fixed column name -->
            <td>" . htmlspecialchars($row['Description']) . "</td>
            <td>" . htmlspecialchars($row['GrantPrice']) . "</td>
            <td>" . htmlspecialchars($row['AvailableGrants']) . "</td>
        </tr>";
}

echo "    </tbody>
    </table>
</body>
</html>";

// Free the statement and close the connection
sqlsrv_free_stmt($stmt);
sqlsrv_close($conn);
?>
