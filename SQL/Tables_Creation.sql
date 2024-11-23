--Creation of Users Table
CREATE TABLE Users (
    PersonID NVARCHAR(20) NOT NULL,
    LastName NVARCHAR(25) NOT NULL,
    FirstName NVARCHAR(25) NOT NULL,
    UserName NVARCHAR(25) NOT NULL UNIQUE,
    Email NVARCHAR(40) NOT NULL UNIQUE CHECK (Email LIKE '%@%'),
    Password NVARCHAR(255) NOT NULL, 
    Address NVARCHAR(50) NOT NULL,
    BirthDate NVARCHAR(11) NOT NULL,
    Phone NVARCHAR(15) NOT NULL,
    Role NVARCHAR(10) DEFAULT 'user' CHECK (Role IN ('user','TOM', 'dealer', 'admin')),
    Sex NVARCHAR NOT NULL CHECK (Sex IN ('male', 'female', 'other')),
    CONSTRAINT PK_Users PRIMARY KEY (PersonID, UserName)
);
DROP TABLE Users;

--Creation of the Forms Table
CREATE TABLE Forms(
	FormID NVARCHAR(20) NOT NULL,
	FormName NVARCHAR(20) NOT NULL,
	Description NVARCHAR(50) NOT NULL,
	Path NVARCHAR(255) NOT NULL,
	CONSTRAINT PK_Forms PRIMARY KEY (FormID)
);

--Store Forms Into Forms Table
INSERT INTO Forms(FormID, FormName, Description, Path)
VALUES (1, 'FIMAS', 'AuthorityForPaymentsFromFimas', '/home/students/cs/2021/ksavva05/public_html/dbpro/forms/FIMAS.pdf')
INSERT INTO Forms(FormID, FormName, Description, Path)
VALUES (2, 'C2_C6', 'CommitmentToMaintainTaxiFor5Years', '/home/students/cs/2021/ksavva05/public_html/dbpro/forms/C2_C6.pdf')
INSERT INTO Forms(FormID, FormName, Description, Path)
VALUES (3, 'C9', 'OrderConfirmation', '/home/students/cs/2021/ksavva05/public_html/dbpro/forms/C9.pdf')
INSERT INTO Forms(FormID, FormName, Description, Path)
VALUES (4, 'C15', 'OrderConfirmation(Bike)', '/home/students/cs/2021/ksavva05/public_html/dbpro/forms/C15.pdf')
INSERT INTO Forms(FormID, FormName, Description, Path)
VALUES (5, 'C16', 'ReceiveConfirmationForAllowanceTickets', '/home/students/cs/2021/ksavva05/public_html/dbpro/forms/C16.pdf')