<?php
$serverName = "mssql.cs.ucy.ac.cy"; // Replace with your server name
$connectionOptions = array(
    "Database" => "ksavva05", // Replace with your database name
    "Uid" => "ksavva05",           // Replace with your username
    "PWD" => "hNRTkrtS"            // Replace with your password
);

// Establishes the connection
$conn = sqlsrv_connect($serverName, $connectionOptions);

// Check if the connection was successful
if ($conn === false) {
    die(print_r(sqlsrv_errors(), true));
}
?>
