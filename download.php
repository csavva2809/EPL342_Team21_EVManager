<?php
// Ensure the file parameter is passed
if (isset($_GET['file'])) {
    $fileName = basename($_GET['file']);  // Prevent directory traversal attacks
    $filePath = '/home/students/cs/2021/ksavva05/public_html/epl342/dbpro/filled_forms/' . $fileName;

    // Check if file exists
    if (file_exists($filePath)) {
        // Set headers to trigger a file download
        header('Content-Type: application/octet-stream');
        header('Content-Disposition: attachment; filename="' . basename($filePath) . '"');
        header('Content-Length: ' . filesize($filePath));

        // Read the file and send it to the user
        readfile($filePath);
        exit;
    } else {
        echo "File not found!";
    }
} else {
    echo "No file specified!";
}
?>
