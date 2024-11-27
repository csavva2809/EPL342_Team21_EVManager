--Creation of Users Table
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    PersonID NVARCHAR(20) NOT NULL CHECK (LEN(PersonID) BETWEEN 5 AND 20),
    LastName NVARCHAR(25) NOT NULL CHECK (LEN(LastName) > 1),
    FirstName NVARCHAR(25) NOT NULL CHECK (LEN(FirstName) > 1), 
    UserName NVARCHAR(25) NOT NULL UNIQUE CHECK (LEN(UserName) >= 5), 
    Email NVARCHAR(40) NOT NULL UNIQUE CHECK (Email LIKE '%@%' AND Email LIKE '%.%'), 
    PasswordHash NVARCHAR(255) NOT NULL CHECK (LEN(PasswordHash) >= 8), 
    Address NVARCHAR(100) NOT NULL CHECK (LEN(Address) > 5),
    BirthDate DATE NOT NULL CHECK (DATEDIFF(YEAR, BirthDate, GETDATE()) >= 18),
    Phone VARCHAR(15) NOT NULL CHECK (Phone LIKE '[0-9]%'),
    Role VARCHAR(10) DEFAULT 'user' NOT NULL CHECK (Role IN ('user', 'TOM', 'dealer', 'admin')),
    Sex CHAR(6) DEFAULT 'other' NOT NULL CHECK (Sex IN ('male', 'female', 'other'))
);

CREATE TABLE LegalEntities (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    CompanyName NVARCHAR(100) NOT NULL CHECK (LEN(CompanyName) > 2),
    RegistrationNumber NVARCHAR(50) NOT NULL UNIQUE CHECK (LEN(RegistrationNumber) >= 5),
    TaxNumber NVARCHAR(50) NOT NULL UNIQUE CHECK (LEN(TaxNumber) >= 5),
    EstablishedDate DATE NOT NULL CHECK (EstablishedDate <= GETDATE()),
    Address NVARCHAR(100) NOT NULL CHECK (LEN(Address) > 5),
    Phone VARCHAR(15) NOT NULL CHECK (Phone LIKE '[0-9]%'),
    Email NVARCHAR(40) NOT NULL UNIQUE CHECK (Email LIKE '%@%' AND Email LIKE '%.%'),
	PasswordHash NVARCHAR(255) NOT NULL CHECK (LEN(PasswordHash) >= 8)
);
DROP TABLE LegalEntities;

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
(1, 'FIMAS', 'AuthorityForPaymentsFromFimas', '/~ksavva/public_html/epl342/dbpro/forms/FIMAS.pdf'),
(2, 'C2_C6', 'CommitmentToMaintainTaxiFor5Years', '/~ksavva/public_html/epl342/dbpro/forms/C2_C6.pdf'),
(3, 'C9', 'OrderConfirmation', '/~ksavva/public_html/epl342/dbpro/forms/C9.pdf'),
(4, 'C15', 'OrderConfirmation(Bike)', '/~ksavva/public_html/epl342/dbpro/forms/C15.pdf'),
(5, 'C16', 'ReceiveConfirmationForAllowanceTickets', '/~ksavva/public_html/epl342/dbpro/forms/C16.pdf')

CREATE TABLE Documents (
    DocumentID INT IDENTITY(1,1) PRIMARY KEY,
    FileName NVARCHAR(255) NOT NULL,
    CriteriaID INT NOT NULL,
    FilePath NVARCHAR(255) NOT NULL,
    SubmissionDate DATETIME DEFAULT GETDATE()
);


EXEC sp_help 'Documents';
ALTER TABLE Documents
ALTER COLUMN FileName NVARCHAR(255);
ALTER TABLE Documents
ALTER COLUMN FilePath NVARCHAR(255);


--Creation of Applications Table
CREATE TABLE Applications (
    ApplicationID NVARCHAR(20) NOT NULL ,
    UserID NVARCHAR(20) NOT NULL,
	UserName NVARCHAR(25) NOT NULL,
    ApplicantType NVARCHAR(10) NOT NULL CHECK (ApplicantType IN ('individual', 'legal_entity')),
    GrantCategory NVARCHAR(10) NOT NULL CHECK (GrantCategory IN ('C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10', 'C11', 'C12', 'C13', 'C14', 'C15', 'C16')),
    ApplicationDate DATE NOT NULL,
    VehicleType NVARCHAR(10) NOT NULL CHECK (VehicleType IN ('M1', 'M2', 'N1', 'N2', 'L')),
    WithdrawalVehicleID NVARCHAR(20),
    Status NVARCHAR(15) DEFAULT 'submitted' CHECK (Status IN ('submitted', 'approved', 'rejected', 'expired')),
    ExpirationDate NVARCHAR(11) NOT NULL, 
	CONSTRAINT PK_Application PRIMARY KEY (ApplicationID),
);

CREATE TABLE Grants (
    GrantID INT IDENTITY(1,1) PRIMARY KEY, -- Auto-incrementing primary key
    GrantCategory VARCHAR(5) NOT NULL CHECK (GrantCategory IN ('C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10', 'C11', 'C12', 'C13', 'C14', 'C15', 'C16')), -- Valid categories
    Description NVARCHAR(255) NOT NULL,
    GrantPrice FLOAT NOT NULL CHECK (GrantPrice > 0), -- Must be positive
    SumPrice FLOAT NOT NULL CHECK (SumPrice > 0), -- Must be positive
    AvailableGrants INT NOT NULL CHECK (AvailableGrants >= 0), -- Non-negative value

    -- Table-level CHECK constraint for logical comparison between columns
    CONSTRAINT CK_SumPrice_GrantPrice CHECK (SumPrice >= GrantPrice)
);

CREATE TABLE Criteria (
    CriteriaID INT IDENTITY(1,1) PRIMARY KEY,
    Description NVARCHAR(255) NOT NULL,
    Category NVARCHAR(50) NOT NULL
);

CREATE TABLE GrantCriteria (
    GrantID INT NOT NULL,          -- Refers to GrantID in the Grants table
    CriteriaID INT NOT NULL,       -- Refers to CriteriaID in the Criteria table
    PRIMARY KEY (GrantID, CriteriaID), -- Composite Primary Key (each Grant can have multiple criteria and each Criteria can belong to multiple grants)
    FOREIGN KEY (GrantID) REFERENCES Grants(GrantID), -- Link to Grants table
    FOREIGN KEY (CriteriaID) REFERENCES Criteria(CriteriaID) -- Link to Criteria table
);
