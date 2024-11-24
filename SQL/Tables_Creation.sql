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
VALUES 
(1, 'FIMAS', 'AuthorityForPaymentsFromFimas', '/~ksavva/public_html/epl342/dbpro/forms/FIMAS.pdf')
(2, 'C2_C6', 'CommitmentToMaintainTaxiFor5Years', '/~ksavva/public_html/epl342/dbpro/forms/C2_C6.pdf')
(3, 'C9', 'OrderConfirmation', '/~ksavva/public_html/epl342/dbpro/forms/C9.pdf')
(4, 'C15', 'OrderConfirmation(Bike)', '/~ksavva/public_html/epl342/dbpro/forms/C15.pdf')
(5, 'C16', 'ReceiveConfirmationForAllowanceTickets', '/~ksavva/public_html/epl342/dbpro/forms/C16.pdf')

--Creation of Documents Table
CREATE TABLE Documents (
    DocumentID INT IDENTITY(1,1) NOT NULL,
    PersonID NVARCHAR(20) NOT NULL, 
    UserName NVARCHAR(25) NOT NULL,
    Path NVARCHAR(255) NOT NULL,
    SubmitionDate NVARCHAR(10) NOT NULL, 
    CONSTRAINT PK_Documents PRIMARY KEY (DocumentID),
    CONSTRAINT FK_Documents FOREIGN KEY (PersonID, UserName) REFERENCES Users(PersonID, UserName)
);

--Creation of Applications Table
CREATE TABLE Applications (
    ApplicationID NVARCHAR(20) NOT NULL ,
    PersonID NVARCHAR(20) NOT NULL,
	UserName NVARCHAR(25) NOT NULL,
    ApplicantType NVARCHAR(10) NOT NULL CHECK (ApplicantType IN ('individual', 'legal_entity')),
    GrantCategory NVARCHAR(10) NOT NULL CHECK (GrantCategory IN ('C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10', 'C11', 'C12', 'C13', 'C14', 'C15', 'C16')),
    ApplicationDate DATE NOT NULL,
    VehicleType NVARCHAR(10) NOT NULL CHECK (VehicleType IN ('M1', 'M2', 'N1', 'N2', 'L')),
    WithdrawalVehicleID NVARCHAR(20),
    Status NVARCHAR(15) DEFAULT 'submitted' CHECK (Status IN ('submitted', 'approved', 'rejected', 'expired')),
    ExpirationDate NVARCHAR(11) NOT NULL, 
	CONSTRAINT PK_Application PRIMARY KEY (ApplicationID),
	CONSTRAINT FK_Application FOREIGN KEY (PersonID, UserName) REFERENCES Users(PersonID, UserName)
);

