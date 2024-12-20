﻿SELECT MAX(UserID) AS MaxUserID FROM Users;

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
    UserID INT PRIMARY KEY DEFAULT NEXT VALUE FOR SharedUserIDSequence,
    CompanyName NVARCHAR(100) NOT NULL CHECK (LEN(CompanyName) > 2),
    RegistrationNumber NVARCHAR(50) NOT NULL UNIQUE CHECK (LEN(RegistrationNumber) >= 5),
    TaxNumber NVARCHAR(50) NOT NULL UNIQUE CHECK (LEN(TaxNumber) >= 5),
    EstablishedDate DATE NOT NULL CHECK (EstablishedDate <= GETDATE()),
    Address NVARCHAR(100) NOT NULL CHECK (LEN(Address) > 5),
    Phone VARCHAR(15) NOT NULL CHECK (Phone LIKE '[0-9]%'),
    Email NVARCHAR(40) NOT NULL UNIQUE CHECK (Email LIKE '%@%' AND Email LIKE '%.%'),
    PasswordHash NVARCHAR(255) NOT NULL CHECK (LEN(PasswordHash) >= 8)
);

CREATE TABLE ApplicationSequence (
    GrantCategory NVARCHAR(10) PRIMARY KEY, -- Grant category (e.g., C1, C2)
    LastNumber INT DEFAULT 0               -- Last used number for this grant category
);


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
	ApplicationID NVARCHAR(20) NOT NULL,
    FileName NVARCHAR(255) NOT NULL CHECK (FileName LIKE '%.pdf' OR  FileName LIKE '%.jpeg' OR FileName LIKE'%.png'),
    FilePath NVARCHAR(255) NOT NULL,
	Size INT CHECK (Size <= 2000000),
	DocType NVARCHAR(15) NOT NULL CHECK (DocType IN ('Order' , 'Justification', 'Supportive'))
	CONSTRAINT FK_Documents FOREIGN KEY (ApplicationID) REFERENCES Applications(ApplicationID)
);

CREATE TABLE Applications (
    ApplicationID NVARCHAR(20) NOT NULL PRIMARY KEY,
    UserID INT NOT NULL,
    UserType NVARCHAR(20) NOT NULL CHECK (UserType IN ('individual', 'legal_entity')),
    GrantCategory NVARCHAR(10) NOT NULL,
    VehicleType NVARCHAR(10),
    WithdrawalVehicleID NVARCHAR(20) NULL,
    ApplicationDate DATE NOT NULL DEFAULT GETDATE(),
    ExpirationDate DATE NULL,
    CONSTRAINT FK_Applications_Users_UserID FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_Applications_LegalEntities_UserID FOREIGN KEY (UserID) REFERENCES LegalEntities(UserID)
);




-- Add foreign key referencing Users.UserID
ALTER TABLE Applications
ADD CONSTRAINT FK_Applications_Users_UserID
FOREIGN KEY (UserID) REFERENCES Users(UserID);

-- Add foreign key referencing LegalEntities.UserID
ALTER TABLE Applications
ADD CONSTRAINT FK_Applications_LegalEntities_UserID
FOREIGN KEY (UserID) REFERENCES LegalEntities(UserID);


CREATE TABLE StatusHistory (
    StatusID INT IDENTITY(1,1) PRIMARY KEY,
    ApplicationID NVARCHAR(20) NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'submitted' CHECK (Status IN ('submitted', 'approved', 'rejected', 'expired')),
    StatusDate DATETIME NOT NULL DEFAULT GETDATE(), -- Timestamp of the status change
	Comments NVARCHAR(500) NULL,
    FOREIGN KEY (ApplicationID) REFERENCES Applications(ApplicationID) -- Foreign key to Applications
);

CREATE TABLE Grants (
    GrantID INT IDENTITY(1,1) PRIMARY KEY, -- Auto-incrementing primary key
    GrantCategory VARCHAR(5) NOT NULL CHECK (GrantCategory IN ('C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10', 'C11', 'C12', 'C13', 'C14', 'C15', 'C16')), -- Valid categories
    Description NVARCHAR(255) NOT NULL,
    GrantPrice FLOAT NOT NULL CHECK (GrantPrice > 0), -- Must be positive
    SumPrice FLOAT NOT NULL CHECK (SumPrice >= 0), -- Must be positive
    WithdrawalVehicle BIT NOT NULL DEFAULT 0, -- TRUE if withdrawal of a vehicle is required
    Justification NVARCHAR(255) NULL -- Justification name (NULL if not needed)
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

CREATE TABLE Vehicles(
	VehicleID INT  IDENTITY(1,1) PRIMARY KEY,
	Maker NVARCHAR(25) NOT NULL,
	Model NVARCHAR(25) NOT NULL,
	CO2grPerKm FLOAT NOT NULL,
	Price INT NOT NULL
);

CREATE TABLE Orders(
	OrderID INT IDENTITY(1,1) PRIMARY KEY,
	ApplicationID  NVARCHAR(20) NOT NULL,
	VehicleID INT NOT NULL,
	DocumentID INT NOT NULL,
	ExpectedRegisterDate CHAR(15),
	FOREIGN KEY (ApplicationID) REFERENCES Applications(ApplicationID), 
    FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID),
	FOREIGN KEY (DocumentID) REFERENCES Documents(DocumentID)
);


-- Drop existing foreign key constraints and recreate them with ON DELETE CASCADE

-- Documents Table
ALTER TABLE Documents
ADD CONSTRAINT FK_Documents
FOREIGN KEY (ApplicationID) REFERENCES Applications(ApplicationID) ON DELETE CASCADE;

-- StatusHistory Table
ALTER TABLE StatusHistory DROP CONSTRAINT FK_StatusHistory_ApplicationID;
ALTER TABLE StatusHistory
ADD CONSTRAINT FK_StatusHistory_ApplicationID
FOREIGN KEY (ApplicationID) REFERENCES Applications(ApplicationID) ON DELETE CASCADE;

-- Orders Table
ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_ApplicationID
FOREIGN KEY (ApplicationID) REFERENCES Applications(ApplicationID) ON DELETE CASCADE;
ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_VehicleID
FOREIGN KEY (VehicleID) REFERENCES Vehicles(VehicleID) ON DELETE CASCADE;
ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_DocumentID
FOREIGN KEY (DocumentID) REFERENCES Documents(DocumentID) ON DELETE CASCADE;

-- Applications Table
ALTER TABLE Applications
ADD CONSTRAINT FK_Applications_UserID
FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE;

-- GrantCriteria Table
ALTER TABLE GrantCriteria
ADD CONSTRAINT FK_GrantCriteria_GrantID
FOREIGN KEY (GrantID) REFERENCES Grants(GrantID) ON DELETE CASCADE;
ALTER TABLE GrantCriteria
ADD CONSTRAINT FK_GrantCriteria_CriteriaID
FOREIGN KEY (CriteriaID) REFERENCES Criteria(CriteriaID) ON DELETE CASCADE;

-- LegalEntities Table
ALTER TABLE LegalEntities
ADD CONSTRAINT FK_LegalEntities_UserID
FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE;

-- Vehicles Table
-- No updates needed for cascading delete, as it depends only on itself.

-- Forms Table
-- No updates needed for cascading delete, as it depends only on itself.

-- ApplicationSequence Table
-- No updates needed for cascading delete, as it depends only on itself.
