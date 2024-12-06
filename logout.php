<?php 
session_start();
session_destroy();
  header("Location: index.php"); // Redirect to a dashboard or home page
exit();
?>

