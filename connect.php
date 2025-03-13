<?php
$serverName = ""; // Replace with your server name
$connectionOptions = array(
    "Database" => "", // Replace with your database name
    "Uid" => "",           // Replace with your username
    "PWD" => ""            // Replace with your password
);

// Establishes the connection
$conn = sqlsrv_connect($serverName, $connectionOptions);

// Check if the connection was successful
if ($conn === false) {
    die(print_r(sqlsrv_errors(), true));
}
?>
