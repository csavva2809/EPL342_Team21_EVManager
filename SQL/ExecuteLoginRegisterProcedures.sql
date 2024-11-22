
DECLARE @Success BIT;
DECLARE @Message NVARCHAR(255);

EXEC RegisterUser
    @LastName = 'Theocharidi',
    @FirstName = 'Anthia',
    @UserName = 'atheoc',
    @Email = 'atheoc@example.com',
    @Password = 'securepassword',
    @Address = '123 Main St',
    @BirthDate = '1990-01-01',
    @Phone = '1234567890',
    @Sex = 'male',
    @Success = @Success OUTPUT,
    @Message = @Message OUTPUT;

SELECT @Success AS Success, @Message AS Message;



DECLARE @IsValid BIT;

-- Replace 'testUser' and 'testPassword' with actual username and password
EXEC ValidateLogin
    @UserName = 'atheoc',
    @Password = 'securepassword',
    @IsValid = @IsValid OUTPUT;

-- Output the result
SELECT @IsValid AS IsValid; -- 1 if valid, 0 otherwise

-- Create temporary tables to store names and surnames
CREATE TABLE #FirstNames (Name NVARCHAR(25));
CREATE TABLE #LastNames (Name NVARCHAR(25));

-- Insert sample first names
INSERT INTO #FirstNames (Name) VALUES 
('John'), ('Jane'), ('Michael'), ('Emily'), ('David'),
('Sarah'), ('James'), ('Anna'), ('Robert'), ('Jessica'),
('William'), ('Olivia'), ('Thomas'), ('Sophia'), ('Daniel'),
('Isabella'), ('Matthew'), ('Emma'), ('Joshua'), ('Ava');

-- Insert sample last names
INSERT INTO #LastNames (Name) VALUES 
('Smith'), ('Johnson'), ('Williams'), ('Brown'), ('Jones'),
('Garcia'), ('Miller'), ('Davis'), ('Rodriguez'), ('Martinez'),
('Hernandez'), ('Lopez'), ('Gonzalez'), ('Wilson'), ('Anderson'),
('Taylor'), ('Thomas'), ('Moore'), ('Jackson'), ('Martin');

-- Initialize counter for unique PersonID
DECLARE @i INT = 1;

-- Loop to insert 100 users
WHILE @i <= 100
BEGIN
    -- Generate random first and last names
    DECLARE @FirstName NVARCHAR(25) = (SELECT TOP 1 Name FROM #FirstNames ORDER BY NEWID());
    DECLARE @LastName NVARCHAR(25) = (SELECT TOP 1 Name FROM #LastNames ORDER BY NEWID());

    -- Insert user into the Users table
    INSERT INTO Users (
        PersonID, LastName, FirstName, UserName, Email, Password, Address, BirthDate, Phone, Role, Sex
    )
    VALUES (
        @i, -- PersonID
        @LastName, -- LastName
        @FirstName, -- FirstName
        CONCAT(LOWER(@FirstName), '.', LOWER(@LastName), @i), -- UserName (e.g., john.smith1)
        CONCAT(LOWER(@FirstName), '.', LOWER(@LastName), @i, '@example.com'), -- Email
        CONCAT('Password', @i), -- Password
        CONCAT('123 ', @LastName, ' St'), -- Address
        DATEADD(YEAR, -20 - (@i % 10), GETDATE()), -- BirthDate (20-29 years ago)
        CONCAT('555-', RIGHT('000000000' + CAST(@i AS NVARCHAR), 9)), -- Phone (e.g., 555-000000001)
        CASE 
            WHEN @i % 4 = 0 THEN 'admin' 
            WHEN @i % 4 = 1 THEN 'user' 
            WHEN @i % 4 = 2 THEN 'dealer' 
            ELSE 'TOM' 
        END, -- Role
        CASE 
            WHEN @i % 3 = 0 THEN 'male'
            WHEN @i % 3 = 1 THEN 'female'
            ELSE 'other'
        END -- Sex
    );

    -- Increment counter
    SET @i = @i + 1;
END;

-- Drop temporary tables
DROP TABLE #FirstNames;
DROP TABLE #LastNames;
