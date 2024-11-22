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