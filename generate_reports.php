<?php
include 'connect.php'; // Ensure connect.php is correctly configured

// Enable error reporting for debugging
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Initialize variables
$data = [];
$report_type = $_GET['report_type'] ?? null;
$start_date = $_GET['start_date'] ?? null;
$end_date = $_GET['end_date'] ?? null;
$application_categories = $_GET['application_categories'] ?? null;
$applicant_category = $_GET['applicant_category'] ?? null;
$sort_option = $_GET['sort_option'] ?? null;
$time_period = $_GET['time_period'] ?? null; // For high activity periods

if ($report_type) {
    try {
        $sql = null;

        // Handle various report types
        if ($report_type === 'overview_total_grants') {
            $sql = "{CALL sp_GetTotalGrantAmounts(?)}";
            $params = [$sort_option];
        } elseif ($report_type === 'overview_remaining_grants') {
            $sql = "{CALL sp_GetRemainingGrantAmounts(?)}";
            $params = [$sort_option];
        } elseif ($report_type === 'analysis_application_count') {
            $params = [
                $start_date ?: null,                // Start date or NULL
                $end_date ?: null,                  // End date or NULL
                $application_categories ?: null,    // Comma-separated categories or NULL
                $applicant_category ?: null         // Applicant category ('individual', 'legal', or NULL)
            ];
            $sql = "{CALL sp_AnalysisApplicationCount(?, ?, ?, ?)}";
        } elseif ($report_type === 'compare_application_trends') {
           // Prepare parameters with null defaults
            $params = [
                $start_date ? date('Y-m-d', strtotime($start_date)) : null, // Format date or set NULL
                $end_date ? date('Y-m-d', strtotime($end_date)) : null,     // Format date or set NULL
                $applicant_category ?: null                               // Use value or NULL
            ];
            $sql = "{CALL sp_CompareApplicationTrends(?, ?, ?)}";
        } elseif ($report_type === 'success_rate') {
            $params = [
                $start_date ?: null,                // Start date or NULL
                $end_date ?: null,                  // End date or NULL
                $application_categories ?: null,    // Comma-separated categories or NULL
                $applicant_category ?: null         // Applicant category ('individual', 'legal', or NULL)
            ];
            $sql = "{CALL sp_SuccessRateApplications(?, ?, ?, ?)}";
        }
        elseif ($report_type === 'high_activity_periods') {
            $params = [$time_period];
            $sql = "{CALL sp_HighActivityPeriods(?)}";
        }elseif ($report_type === 'average_grant_amount') {
            $params = [
                $start_date ?: null,
                $end_date ?: null,
                $application_categories ?: null,
                $applicant_category ?: null
            ];
            $sql = "{CALL sp_AverageGrantAmount(?, ?, ?, ?)}";
        }elseif ($report_type === 'extreme_grant_categories') {
            $params = [
                $start_date ?: null,
                $end_date ?: null,
                $application_categories ?: null,
                $applicant_category ?: null
            ];
            $sql = "{CALL sp_ExtremeGrantCategories(?, ?, ?, ?)}";
        }elseif ($report_type === 'legal_entities_by_category') {
            $params = [
                $start_date ?: null,
                $end_date ?: null,
                $application_categories ?: null
            ];
            $sql = "{CALL sp_LegalEntitiesByCategory(?, ?, ?)}";
        }elseif ($report_type === 'categories_with_at_least_x_applications') {
            // Retrieve year and min applications from the form
            $year = $_GET['year'] ?? null; // User-specified year
            $min_applications = $_GET['min_applications'] ?? null; // Minimum applications parameter
        
            // Validate the inputs
            if (!$year || !$min_applications) {
                throw new Exception("Both Year and Minimum Applications are required.");
            }
        
            $params = [$year, $min_applications]; // Pass both parameters
            $sql = "{CALL sp_CategoriesWithAtLeastXApplications(?, ?)}"; // Call the stored procedure
        }elseif ($report_type === 'categories_with_monthly_applications') {
            $params = []; // No parameters required for this procedure
            $sql = "{CALL sp_CategoriesWithMonthlyApplications()}"; // Call the stored procedure
        }
        
        
        
        

        if ($sql) {
            $stmt = sqlsrv_query($conn, $sql, $params);

            if ($stmt === false) {
                throw new Exception("Failed to execute stored procedure: " . print_r(sqlsrv_errors(), true));
            }

            while ($row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC)) {
                $data[] = $row;
            }

            sqlsrv_free_stmt($stmt);
        }
    } catch (Exception $e) {
        echo "Error: " . $e->getMessage();
    }
}

?>

<!DOCTYPE html>
<html lang="el">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dynamic Reports</title>
    <style>
/* General Reset */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: Arial, sans-serif;
    line-height: 1.6;
    background-color: #f4f7f9;
    color: #333;
    padding: 20px;
}

h3 {
    color: #2c3e50;
    margin-bottom: 15px;
}

/* Main button container */
.button-container {
    margin-bottom: 20px;
    text-align: center;
}

.button-container button {
    background-color: #003366; /* Navy Blue */
    color: white;
    padding: 12px 20px;
    font-size: 16px;
    margin: 5px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    transition: background-color 0.3s ease;
}

.button-container button:hover {
    background-color: #002a47; /* Slightly darker navy */
}

/* Form container */
.form-container {
    display: none;
    margin-top: 20px;
    padding: 20px;
    border: 1px solid #ccc;
    border-radius: 5px;
    background-color: white;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    max-width: 600px;
    margin-left: auto;
    margin-right: auto;
}

label {
    display: block;
    margin-bottom: 8px;
    font-weight: bold;
    color: #34495e;
}

input[type="text"],
input[type="date"],
input[type="number"],
select {
    width: 100%;
    padding: 10px;
    margin: 8px 0 15px;
    border: 1px solid #ccc;
    border-radius: 4px;
    box-sizing: border-box;
}

select {
    cursor: pointer;
}

button[type="submit"] {
    background-color: #2ecc71;
    color: white;
    padding: 12px 20px;
    font-size: 16px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    transition: background-color 0.3s ease;
}

button[type="submit"]:hover {
    background-color: #27ae60;
}

/* Table */
table {
    width: 100%;
    margin-top: 30px;
    border-collapse: collapse;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

th, td {
    padding: 12px 15px;
    text-align: left;
    border-bottom: 1px solid #ddd;
}

th {
    background-color: #003366; /* Navy Blue for table header */
    color: white;
}

tr:nth-child(even) {
    background-color: #f9f9f9;
}

tr:hover {
    background-color: #f1f1f1;
}

.error-message {
    color: red;
    font-size: 14px;
    margin-bottom: 20px;
}

/* Sub-button container for Filters */
.sub-button-container {
    display: none;
    text-align: center;
    margin-top: 20px;
}

.sub-button-container button {
    background-color: #85C1E9; /* Light Blue for filter buttons */
    color: white;
    font-size: 16px;
    padding: 10px 15px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    transition: background-color 0.3s ease;
    margin: 5px;
}

.sub-button-container button:hover {
    background-color: #76A8C8; /* Slightly darker light blue */
}
    </style>
    <script>
        function toggleForm(formId) {
            const forms = document.querySelectorAll('.form-container');
            forms.forEach(form => form.style.display = 'none');
            const selectedForm = document.getElementById(formId);
            if (selectedForm) {
                selectedForm.style.display = 'block';
            }
        }

        function showSubButtons(buttonId) {
            const subButtons = document.querySelectorAll('.sub-button-container');
            subButtons.forEach(btn => btn.style.display = 'none');
            const selectedSubButton = document.getElementById(buttonId);
            if (selectedSubButton) {
                selectedSubButton.style.display = 'block';
            }
        }
    </script>
</head>
<?php include 'navbar.php' ?>
<body>
    <!-- Main Buttons -->
    <div class="button-container">
        <button onclick="showSubButtons('sub-buttons-grants')">Αναφορά Επιχορηγήσεων</button>
        <button onclick="showSubButtons('sub-buttons-stats')">Αναφορές Στατιστικών</button>
        <button onclick="showSubButtons('sub-buttons-grant-amounts')">Αναφορές Ύψους Επιχορηγήσεων</button>
        <button onclick="showSubButtons('sub-buttons-grant-performance')">Αναφορές Απόδοσης</button>
    </div>

    <!-- Sub-Buttons for Αναφορά Επιχορηγήσεων -->
    <div id="sub-buttons-grants" class="sub-button-container" style="display: none;">
        <button onclick="toggleForm('form1-1')">Επισκόπηση Συνολικών Ποσών</button>
        <button onclick="toggleForm('form1-2')">Επισκόπηση Υπολειπόμενων Διαθέσιμων</button>
    </div>

    <!-- Sub-Buttons for Αναφορές Στατιστικών -->
    <div id="sub-buttons-stats" class="sub-button-container" style="display: none;">
        <button onclick="toggleForm('form2-1')">Ανάλυση του αριθμού αιτήσεων</button>
        <button onclick="toggleForm('form2-2')">Σύγκριση των τάσεων αιτήσεων</button>
        <button onclick="toggleForm('form2-3')">Ποσοστό επιτυχών αιτήσεων</button>
        <button onclick="toggleForm('form2-4')">Αναγνώριση περιόδων υψηλής δραστηριότητας</button>
    </div>

    <div id="sub-buttons-grant-amounts" class="sub-button-container" style="display: none;">
        <button onclick="toggleForm('form3-1')">Μέσο ποσό επιχορήγησης</button>
        <button onclick="toggleForm('form3-2')">Κατηγορίες με υψηλότερες/χαμηλότερες επιχορηγήσεις</button>
    </div>

    <div id="sub-buttons-grant-performance" class="sub-button-container" style="display: none;">
        <button onclick="toggleForm('form4-1')">Νομικά Πρόσωπα ανά Κατηγορία με Επιτυχείς και Ανεπιτυχείς Αιτήσεις</button>
        <button onclick="toggleForm('form4-2')">Αναφορά με τις κατηγορίες επιχορήγησης τα οποία είχαν τουλάχιστον μια αίτηση κάθε μήνα του τελευταίου τετράμηνου</button>
        <button onclick="toggleForm('form4-3')">Αναφορά με τις κατηγορίες επιχορήγησης για τις οποίες έγιναν τουλάχιστον X αιτήσεις σε κάποιο ημερολογιακό έτος</button>
    </div>

    <!-- Form for Επισκόπηση Συνολικών Ποσών -->
    <div id="form1-1" class="form-container">
        <h3>Επισκόπηση Συνολικών Ποσών</h3>
        <form method="GET">
            <label for="sort_option">Ταξινόμηση κατά:</label>
            <select id="sort_option" name="sort_option">
                <option value="amount_asc">Ποσό Επιχορήγησης (Αύξουσα)</option>
                <option value="amount_desc">Ποσό Επιχορήγησης (Φθίνουσα)</option>
                <option value="category_asc">Κατηγορία Αίτησης (Αύξουσα)</option>
                <option value="category_desc">Κατηγορία Αίτησης (Φθίνουσα)</option>
            </select>
            <br><br>
            <input type="hidden" name="report_type" value="overview_total_grants">
            <button type="submit">Εκτέλεση</button>
        </form>
    </div>

    <!-- Form for Επισκόπηση Υπολειπόμενων Διαθέσιμων -->
    <div id="form1-2" class="form-container">
        <h3>Επισκόπηση Υπολειπόμενων Διαθέσιμων</h3>
        <form method="GET">
            <label for="sort_option">Ταξινόμηση κατά:</label>
            <select id="sort_option" name="sort_option">
                <option value="remaining_asc">Διαθέσιμο Ποσό (Αύξουσα)</option>
                <option value="remaining_desc">Διαθέσιμο Ποσό (Φθίνουσα)</option>
                <option value="category_asc">Κατηγορία Αίτησης (Αύξουσα)</option>
                <option value="category_desc">Κατηγορία Αίτησης (Φθίνουσα)</option>
            </select>
            <br><br>
            <input type="hidden" name="report_type" value="overview_remaining_grants">
            <button type="submit">Εκτέλεση</button>
        </form>
    </div>

    <!-- Form for Ανάλυση του αριθμού αιτήσεων -->
    <div id="form2-1" class="form-container">
        <h3>Ανάλυση του αριθμού αιτήσεων</h3>
        <form method="GET">
            <input type="hidden" name="report_type" value="analysis_application_count">
            <label for="start_date">Από:</label>
            <input type="date" id="start_date" name="start_date">
            <label for="end_date">Έως:</label>
            <input type="date" id="end_date" name="end_date">
            <br><br>
            <label for="application_categories">Κατηγορίες αιτήσεων (διαχωρίστε με κόμμα):</label>
            <input type="text" id="application_categories" name="application_categories">
            <br><br>
            <label for="applicant_category">Κατηγορία αιτούντων:</label>
            <select id="applicant_category" name="applicant_category">
                <option value="">Όλες</option>
                <option value="individual">Φυσικά Πρόσωπα</option>
                <option value="legal">Νομικά Πρόσωπα</option>
            </select>
            <br><br>
            <button type="submit">Εκτέλεση</button>
        </form>
    </div>

    <!-- Form for Σύγκριση των τάσεων αιτήσεων -->
    <div id="form2-2" class="form-container">
        <h3>Σύγκριση των τάσεων αιτήσεων</h3>
        <form method="GET">
            <input type="hidden" name="report_type" value="compare_application_trends">
            <label for="start_date">Από:</label>
            <input type="date" id="start_date" name="start_date">
            <label for="end_date">Έως:</label>
            <input type="date" id="end_date" name="end_date">
            <br><br>
            <label for="applicant_category">Κατηγορία αιτούντων:</label>
            <select id="applicant_category" name="applicant_category">
                <option value="">Όλες</option>
                <option value="individual">Φυσικά Πρόσωπα</option>
                <option value="legal">Νομικά Πρόσωπα</option>
            </select>
            <br><br>
            <button type="submit">Εκτέλεση</button>
        </form>
    </div>

    <!-- Form for Ποσοστό Επιτυχών Αιτήσεων -->
    <div id="form2-3" class="form-container">
        <h3>Ποσοστό Επιτυχών Αιτήσεων</h3>
        <form method="GET">
            <input type="hidden" name="report_type" value="success_rate">
            <label for="start_date">Από:</label>
            <input type="date" id="start_date" name="start_date">
            <label for="end_date">Έως:</label>
            <input type="date" id="end_date" name="end_date">
            <br><br>
            <label for="application_categories">Κατηγορίες αιτήσεων (διαχωρίστε με κόμμα):</label>
            <input type="text" id="application_categories" name="application_categories">
            <br><br>
            <label for="applicant_category">Κατηγορία αιτούντων:</label>
            <select id="applicant_category" name="applicant_category">
                <option value="">Όλες</option>
                <option value="individual">Φυσικά Πρόσωπα</option>
                <option value="legal">Νομικά Πρόσωπα</option>
            </select>
            <br><br>
            <button type="submit">Εκτέλεση</button>
        </form>
    </div>

    <!-- Form for Αναγνώριση περιόδων υψηλής δραστηριότητας -->
    <div id="form2-4" class="form-container">
        <h3>Αναγνώριση περιόδων υψηλής δραστηριότητας</h3>
        <form method="GET">
            <input type="hidden" name="report_type" value="high_activity_periods">
            <label for="time_period">Επιλέξτε Περίοδο:</label>
            <select id="time_period" name="time_period">
                <option value="daily">Ημερήσια</option>
                <option value="weekly">Εβδομαδιαία</option>
                <option value="monthly">Μηνιαία</option>
                <option value="yearly">Ετήσια</option>
            </select>
            <br><br>
            <button type="submit">Εκτέλεση</button>
        </form>
    </div>


    <!-- Form for Μέσο ποσό επιχορήγησης -->
    <div id="form3-1" class="form-container">
        <h3>Μέσο ποσό επιχορήγησης επιτυχών αιτήσεων</h3>
        <form method="GET">
            <input type="hidden" name="report_type" value="average_grant_amount">
            <label for="start_date">Από:</label>
            <input type="date" id="start_date" name="start_date">
            <label for="end_date">Έως:</label>
            <input type="date" id="end_date" name="end_date">
            <br><br>
            <label for="application_categories">Κατηγορίες αιτήσεων (διαχωρίστε με κόμμα):</label>
            <input type="text" id="application_categories" name="application_categories">
            <br><br>
            <label for="applicant_category">Κατηγορία αιτούντων:</label>
            <select id="applicant_category" name="applicant_category">
                <option value="">Όλες</option>
                <option value="individual">Φυσικά Πρόσωπα</option>
                <option value="legal">Νομικά Πρόσωπα</option>
            </select>
            <br><br>
            <button type="submit">Εκτέλεση</button>
        </form>
    </div>


    <div id="form3-2" class="form-container">
        <h3>Κατηγορίες με υψηλότερες/χαμηλότερες επιχορηγήσεις</h3>
        <form method="GET">
            <input type="hidden" name="report_type" value="extreme_grant_categories">
            <label for="start_date">Από:</label>
            <input type="date" id="start_date" name="start_date">
            <label for="end_date">Έως:</label>
            <input type="date" id="end_date" name="end_date">
            <br><br>
            <label for="application_categories">Κατηγορίες αιτήσεων (διαχωρίστε με κόμμα):</label>
            <input type="text" id="application_categories" name="application_categories">
            <br><br>
            <label for="applicant_category">Κατηγορία αιτούντων:</label>
            <select id="applicant_category" name="applicant_category">
                <option value="">Όλες</option>
                <option value="individual">Φυσικά Πρόσωπα</option>
                <option value="legal">Νομικά Πρόσωπα</option>
            </select>
            <br><br>
            <button type="submit">Εκτέλεση</button>
        </form>
    </div>

    <!-- Form for Legal Entities by Category -->
    <div id="form4-1" class="form-container">
        <h3>Νομικά Πρόσωπα ανά Κατηγορία με Επιτυχείς και Ανεπιτυχείς Αιτήσεις</h3>
        <form method="GET">
            <input type="hidden" name="report_type" value="legal_entities_by_category">
            <label for="start_date">Από:</label>
            <input type="date" id="start_date" name="start_date">
            <label for="end_date">Έως:</label>
            <input type="date" id="end_date" name="end_date">
            <br><br>
            <label for="application_categories">Κατηγορίες αιτήσεων (διαχωρίστε με κόμμα):</label>
            <input type="text" id="application_categories" name="application_categories">
            <br><br>
            <button type="submit">Εκτέλεση</button>
        </form>
    </div>
    
    <!-- Form for Κατηγορίες με τουλάχιστον μια αίτηση κάθε μήνα -->
    <div id="form4-2" class="form-container">
        <h3>Κατηγορίες με τουλάχιστον μια αίτηση κάθε μήνα</h3>
        <form method="GET">
            <input type="hidden" name="report_type" value="categories_with_monthly_applications">
            <p>Αυτή η αναφορά δεν απαιτεί επιπλέον κριτήρια φιλτραρίσματος.</p>
            <br><br>
            <button type="submit">Εκτέλεση</button>
        </form>
    </div>



    <div id="form4-3" class="form-container">
        <h3>Κατηγορίες με τουλάχιστον X αιτήσεις</h3>
        <form method="GET">
            <input type="hidden" name="report_type" value="categories_with_at_least_x_applications">
            <label for="year">Έτος:</label>
            <input type="number" id="year" name="year" required>
            <br><br>
            <label for="min_applications">Ελάχιστος αριθμός αιτήσεων:</label>
            <input type="number" id="min_applications" name="min_applications" required>
            <br><br>
            <button type="submit">Εκτέλεση</button>
        </form>
    </div>
    <!-- Display Report Results -->
    <?php if (!empty($data)): ?>
        <table>
            <thead>
                <tr>
                    <?php foreach (array_keys($data[0]) as $column): ?>
                        <th><?php echo htmlspecialchars($column); ?></th>
                    <?php endforeach; ?>
                </tr>
            </thead>
            <tbody>
    <?php foreach ($data as $row): ?>
        <tr>
            <?php foreach ($row as $value): ?>
                <td>
                    <?php 
                    // Check if the value is a DateTime object
                    if ($value instanceof DateTime) {
                        echo htmlspecialchars($value->format('Y-m-d H:i:s')); // Format the DateTime as a string
                    } else {
                        echo htmlspecialchars((string)$value); // Safely convert other values to string
                    }
                    ?>
                </td>
            <?php endforeach; ?>
        </tr>
    <?php endforeach; ?>
</tbody>

        </table>
    <?php elseif ($report_type): ?>
        <p>No data found for the selected report.</p>
    <?php endif; ?>
</body>
</html>
