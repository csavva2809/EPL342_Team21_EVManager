DROP TABLE Application, Criteria, Documents, Grand, Grand_Criteria, StatusHistory, User_Application, User_Document;
-- Create the Users table with IDENTITY property and revised without phone constraints
CREATE TABLE Users (
    Id INT IDENTITY(1,1) PRIMARY KEY, -- Id is now an auto-increment column
    Name NVARCHAR(50),
    Surname NVARCHAR(50),
    Username NVARCHAR(50) UNIQUE,
    Email NVARCHAR(100) CHECK (Email LIKE '%@%'),
    Address NVARCHAR(255),
    Role NVARCHAR(50),
    Phone NVARCHAR(20),  -- No constraint on the phone field
    DateOfBirth DATE,
    Password NVARCHAR(255)
);

-- Rest of your tables and relationships as previously defined remain unchanged

-- Create the Documents table
CREATE TABLE Documents (
    DocumentID INT PRIMARY KEY,
    Type NVARCHAR(50),
    DateOfSubmission DATE,
    FilePath NVARCHAR(255) NOT NULL CHECK (FilePath <> ''),
    VehicleType NVARCHAR(50),
    AssignedTo INT,
    FOREIGN KEY (AssignedTo) REFERENCES Users(Id)
);

-- Create the Application table
CREATE TABLE Application (
    ApplicationID INT PRIMARY KEY,
    Date DATE,
    UserId INT,
    FOREIGN KEY (UserId) REFERENCES Users(Id)
);

-- Create the StatusHistory table
CREATE TABLE StatusHistory (
    StatusHistoryID INT PRIMARY KEY,
    ApplicationID INT,
    Status NVARCHAR(50) CHECK (Status IN ('Submitted', 'Reviewed', 'Approved', 'Rejected')),
    Date DATE,
    FOREIGN KEY (ApplicationID) REFERENCES Application(ApplicationID)
);

-- Create the Grand table
CREATE TABLE Grand (
    GrandID INT PRIMARY KEY,
    Category NVARCHAR(50),
    Description NVARCHAR(MAX),
    Amount DECIMAL(18, 2) CHECK (Amount >= 0)
);

-- Create the Criteria table
CREATE TABLE Criteria (
    CriteriaID INT PRIMARY KEY,
    Description NVARCHAR(MAX) CHECK (DATALENGTH(Description) > 0 AND DATALENGTH(Description) <= 8000)
);

-- Create the User_Application table to track relationships (Review, Create)
CREATE TABLE User_Application (
    UserID INT,
    ApplicationID INT,
    Action NVARCHAR(10) CHECK (Action IN ('Review', 'Create')), -- Either 'Review' or 'Create'
    PRIMARY KEY (UserID, ApplicationID, Action),
    FOREIGN KEY (UserID) REFERENCES Users(Id),
    FOREIGN KEY (ApplicationID) REFERENCES Application(ApplicationID)
);

-- Create the User_Document table to track document provision relationships
CREATE TABLE User_Document (
    UserID INT,
    DocumentID INT,
    PRIMARY KEY (UserID, DocumentID),
    FOREIGN KEY (UserID) REFERENCES Users(Id),
    FOREIGN KEY (DocumentID) REFERENCES Documents(DocumentID)
);

-- Create the Grand_Criteria table to track satisfy relationships
CREATE TABLE Grand_Criteria (
    GrandID INT,
    CriteriaID INT,
    PRIMARY KEY (GrandID, CriteriaID),
    FOREIGN KEY (GrandID) REFERENCES Grand(GrandID),
    FOREIGN KEY (CriteriaID) REFERENCES Criteria(CriteriaID)
);


--Admin import
INSERT INTO Users (Name, Surname, Username, Email, Address, Role, Phone, DateOfBirth, Password)
VALUES 
(
    'Stefanos',             -- First Name
    'Efstathiou',              -- Last Name
    'sefsta',          -- Username
    'sefsta@ucy.ac.cy', -- Email
    '123 Example St, Anytown, AT 12345', -- Address
    'Admin',            -- Role
    '+11234567890',     -- Phone number
    '1980-01-01',       -- Date of Birth
    '$2y$10$fqsORuNfVGmLFcw6DjmCReMFfErh9Lo4fEWkM0Gkltwk4mg/bnOOi'  -- Securely hashed password
);

INSERT INTO Users (Name, Surname, Username, Email, Address, Role, Phone, DateOfBirth, Password)
VALUES 
('John', 'Doe', 'john.doe', 'john.doe@example.com', '1234 Main St', 'admin', '+11234567890', '1980-01-01', '$2y$10$fqsORuNfVGmLFcw6DjmCReMFfErh9Lo4fEWkM0Gkltwk4mg/bnOOi'),
('Jane', 'Smith', 'jane.smith', 'jane.smith@example.com', '1234 Elm St', 'TOM', '+11234567891', '1985-02-02', '$2y$10$fqsORuNfVGmLFcw6DjmCReMFfErh9Lo4fEWkM0Gkltwk4mg/bnOOi'),
('Mike', 'Brown', 'mike.brown', 'mike.brown@example.com', '1234 Pine St', 'representative', '+11234567892', '1990-03-03', '$2y$10$fqsORuNfVGmLFcw6DjmCReMFfErh9Lo4fEWkM0Gkltwk4mg/bnOOi'),
('Alice', 'Johnson', 'alice.johnson', 'alice.johnson@example.com', '1234 Oak St', 'user', '+11234567893', '1995-04-04', '$2y$10$fqsORuNfVGmLFcw6DjmCReMFfErh9Lo4fEWkM0Gkltwk4mg/bnOOi');
