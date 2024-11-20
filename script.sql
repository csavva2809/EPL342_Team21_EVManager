-- Create the Users table with IDENTITY property
CREATE TABLE Users (
    Id INT IDENTITY(1,1) PRIMARY KEY, -- Id is now an auto-increment column
    Name NVARCHAR(50),
    Surname NVARCHAR(50),
    Username NVARCHAR(50) UNIQUE,
    Email NVARCHAR(100),
    Address NVARCHAR(255),
    Role NVARCHAR(50),
    Phone NVARCHAR(20),
    DateOfBirth DATE,
    Password NVARCHAR(255)
);

-- Create the Documents table
CREATE TABLE Documents (
    DocumentID INT PRIMARY KEY,
    Type NVARCHAR(50),
    DateOfSubmission DATE,
    FilePath NVARCHAR(255),
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
    Status NVARCHAR(50),
    Date DATE,
    FOREIGN KEY (ApplicationID) REFERENCES Application(ApplicationID)
);

-- Create the Grand table
CREATE TABLE Grand (
    GrandID INT PRIMARY KEY,
    Category NVARCHAR(50),
    Description NVARCHAR(MAX),
    Amount DECIMAL(18, 2)
);

-- Create the Criteria table
CREATE TABLE Criteria (
    CriteriaID INT PRIMARY KEY,
    Description NVARCHAR(MAX)
);

-- Create the User_Application table to track relationships (Review, Create)
CREATE TABLE User_Application (
    UserID INT,
    ApplicationID INT,
    Action NVARCHAR(10), -- Either 'Review' or 'Create'
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
