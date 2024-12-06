CREATE PROCEDURE Add1000Users
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Counter INT = 7105;
    DECLARE @PersonID NVARCHAR(20);
    DECLARE @LastName NVARCHAR(25);
    DECLARE @FirstName NVARCHAR(25);
    DECLARE @UserName NVARCHAR(25);
    DECLARE @Email NVARCHAR(40);
    DECLARE @PasswordHash NVARCHAR(255);
    DECLARE @Address NVARCHAR(100);
    DECLARE @BirthDate DATE;
    DECLARE @Phone VARCHAR(15);
    DECLARE @Role VARCHAR(10);
    DECLARE @Sex CHAR(6);

    -- Loop to insert 1000 users
    WHILE @Counter <= 20000
    BEGIN
        -- Generate random data
        SET @PersonID = LEFT(NEWID(), 8); -- Random string for PersonID
        SET @LastName = LEFT(NEWID(), 10); -- Random string for LastName
        SET @FirstName = LEFT(NEWID(), 10); -- Random string for FirstName
        SET @UserName = CONCAT('user', @Counter); -- UserName as "user1", "user2", ...
        SET @Email = CONCAT('user', @Counter, '@example.com'); -- Email as "user1@example.com"
        SET @PasswordHash = CONVERT(NVARCHAR(255), HASHBYTES('SHA2_256', CAST(NEWID() AS NVARCHAR(36))), 1); -- Random hash for password
        SET @Address = CONCAT(@Counter, ' Example Street'); -- Random address
        SET @BirthDate = DATEADD(DAY, -ROUND(RAND() * 36500, 0), GETDATE()); -- Random birthdate (18-99 years old)
        SET @Phone = CONCAT('12345', RIGHT(CONVERT(VARCHAR, ABS(CHECKSUM(NEWID()))), 5)); -- Random 10-digit phone
        SET @Role = CASE ROUND(RAND() * 3, 0) 
                    WHEN 0 THEN 'user' 
                    WHEN 1 THEN 'TOM' 
                    WHEN 2 THEN 'dealer' 
                    ELSE 'admin' 
                    END; -- Random role
        SET @Sex = CASE ROUND(RAND() * 2, 0) 
                   WHEN 0 THEN 'male' 
                   WHEN 1 THEN 'female' 
                   ELSE 'other' 
                   END; -- Random sex

        -- Insert the generated user into the table
        INSERT INTO Users (PersonID, LastName, FirstName, UserName, Email, PasswordHash, Address, BirthDate, Phone, Role, Sex)
        VALUES (@PersonID, @LastName, @FirstName, @UserName, @Email, @PasswordHash, @Address, @BirthDate, @Phone, @Role, @Sex);

        -- Increment the counter
        SET @Counter = @Counter + 1;
    END
END;

DROP PROCEDURE Add1000Users;
EXEC Add1000Users;

CREATE PROCEDURE GenerateLegalEntities
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Counter INT = 1;
    DECLARE @CompanyName NVARCHAR(100);
    DECLARE @RegistrationNumber NVARCHAR(50);
    DECLARE @TaxNumber NVARCHAR(50);
    DECLARE @EstablishedDate DATE;
    DECLARE @Address NVARCHAR(100);
    DECLARE @Phone VARCHAR(15);
    DECLARE @Email NVARCHAR(40);
    DECLARE @PasswordHash NVARCHAR(255);

    WHILE @Counter <= 10000
    BEGIN
        -- Generate random CompanyName
        SET @CompanyName = CONCAT('Company_', @Counter, LEFT(NEWID(), 5));
        
        -- Generate unique RegistrationNumber
        SET @RegistrationNumber = CONCAT('REG-', @Counter, LEFT(NEWID(), 5));
        
        -- Generate unique TaxNumber
        SET @TaxNumber = CONCAT('TAX-', @Counter, LEFT(NEWID(), 5));
        
        -- Generate random EstablishedDate (random date within the past 100 years)
        SET @EstablishedDate = DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 36500), GETDATE());

        -- Generate random Address
        SET @Address = CONCAT('Street ', @Counter, ', Building ', RIGHT(ABS(CHECKSUM(NEWID())), 3));

        -- Generate random Phone number (10 digits)
        SET @Phone = CONCAT('12345', RIGHT(CONVERT(VARCHAR, ABS(CHECKSUM(NEWID()))), 5));

        -- Generate unique Email
        SET @Email = CONCAT('legalentity', @Counter, '@example.com');
        
        -- Generate random PasswordHash
        SET @PasswordHash = CONVERT(NVARCHAR(255), HASHBYTES('SHA2_256', CAST(NEWID() AS NVARCHAR(36))), 1);

        -- Insert the generated values into LegalEntities table
        INSERT INTO LegalEntities (CompanyName, RegistrationNumber, TaxNumber, EstablishedDate, Address, Phone, Email, PasswordHash)
        VALUES (@CompanyName, @RegistrationNumber, @TaxNumber, @EstablishedDate, @Address, @Phone, @Email, @PasswordHash);

        -- Increment the counter
        SET @Counter = @Counter + 1;
    END
END;

EXEC GenerateLegalEntities;
DELETE FROM LegalEntities;

DROP PROCEDURE GenerateApplications;
CREATE PROCEDURE GenerateApplications
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Counter INT = 1;
    DECLARE @UserID INT;
    DECLARE @UserType NVARCHAR(20);
    DECLARE @GrantCategory NVARCHAR(10);
    DECLARE @VehicleType NVARCHAR(10);
    DECLARE @WithdrawalVehicleID NVARCHAR(20);
    DECLARE @ApplicationDate DATE;
    DECLARE @ExpirationDate DATE;
    DECLARE @Email NVARCHAR(255);
    DECLARE @ApplicationID NVARCHAR(20); -- This will be generated automatically
    DECLARE @ApplicationPrefix NVARCHAR(2);

    -- User Types
    DECLARE @UserTypes TABLE (UserType NVARCHAR(20));
    INSERT INTO @UserTypes (UserType) VALUES ('individual'), ('legal_entity');

    -- Grant Categories (Example)
    DECLARE @GrantCategories TABLE (GrantCategory NVARCHAR(10));
    INSERT INTO @GrantCategories (GrantCategory) VALUES ('?1'), ('?2'), ('?3'), ('?4'), ('?5');

    -- Vehicle Types (Example)
    DECLARE @VehicleTypes TABLE (VehicleType NVARCHAR(10));
    INSERT INTO @VehicleTypes (VehicleType) VALUES ('M1'), ('M2'), ('N1'), ('N2'), ('L');

    WHILE @Counter <= 100000
    BEGIN
        -- Generate random UserID (Assuming UserID exists in Users table)
        SET @UserID = (SELECT TOP 1 UserID FROM Users ORDER BY NEWID()); -- Random UserID from Users table

        -- Get random UserType
        SET @UserType = (SELECT TOP 1 UserType FROM @UserTypes ORDER BY NEWID());

        -- Get random GrantCategory
        SET @GrantCategory = (SELECT TOP 1 GrantCategory FROM @GrantCategories ORDER BY NEWID());

        -- Get random VehicleType (optional)
        SET @VehicleType = (SELECT TOP 1 VehicleType FROM @VehicleTypes ORDER BY NEWID());

        -- Generate random WithdrawalVehicleID (optional)
        SET @WithdrawalVehicleID = CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0 THEN NULL ELSE CONCAT('V', ABS(CHECKSUM(NEWID())) % 1000) END;

        -- Generate random ApplicationDate (within the last 30 days)
        SET @ApplicationDate = DATEADD(DAY, -ABS(CHECKSUM(NEWID()) % 30), GETDATE());

        -- Generate ExpirationDate (14 days after ApplicationDate)
        SET @ExpirationDate = DATEADD(DAY, 14, @ApplicationDate);

        -- Generate random Email (use a unique identifier for the email)
        SET @Email = CONCAT('user', @Counter, '@example.com');

        -- Generate ApplicationID (e.g., ?1.2024, following the format ?<XX>.<YYYY>)
        SET @ApplicationPrefix = (SELECT TOP 1 GrantCategory FROM @GrantCategories ORDER BY NEWID());
        SET @ApplicationID = CONCAT(@ApplicationPrefix, '.', YEAR(@ApplicationDate));

        -- Insert into Applications Table
        INSERT INTO Applications (ApplicationID, UserID, UserType, GrantCategory, VehicleType, WithdrawalVehicleID, ApplicationDate, ExpirationDate, Email)
        VALUES (@ApplicationID, @UserID, @UserType, @GrantCategory, @VehicleType, @WithdrawalVehicleID, @ApplicationDate, @ExpirationDate, @Email);

        -- Increment the counter
        SET @Counter = @Counter + 1;
    END
END;

EXEC GenerateApplications;
DROP PROCEDURE InsertApplication2;
CREATE PROCEDURE InsertApplication2
    @UserID INT,
    @UserType NVARCHAR(20),
    @GrantCategory NVARCHAR(10),
    @VehicleType NVARCHAR(10) = NULL,
    @WithdrawalVehicleID NVARCHAR(20) = NULL,
    @ApplicationDate DATE = NULL,
    @ExpirationDate DATE = NULL,
    @Email NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validate the UserType
    IF @UserType NOT IN ('individual', 'legal_entity')
    BEGIN
        RAISERROR('Invalid UserType. Allowed values are ''individual'' or ''legal_entity''.', 16, 1);
        RETURN;
    END

    -- Validate the GrantCategory
    IF @GrantCategory NOT IN ('?1', '?2', '?3', '?4', '?5')
    BEGIN
        RAISERROR('Invalid GrantCategory. Allowed values are ''?1'', ''?2'', ''?3'', ''?4'', ''?5''.', 16, 1);
        RETURN;
    END

    -- Set ApplicationDate to today's date if not provided
    IF @ApplicationDate IS NULL
    BEGIN
        SET @ApplicationDate = GETDATE();
    END

    -- Set ExpirationDate to 14 days after ApplicationDate if not provided
    IF @ExpirationDate IS NULL
    BEGIN
        SET @ExpirationDate = DATEADD(DAY, 14, @ApplicationDate);
    END

    -- Generate unique ApplicationID: Format ?<XX>.<YYYY>.<SEQ>
    DECLARE @ApplicationID NVARCHAR(20);
    DECLARE @NextSequence INT;

    -- Get the next sequence number for the GrantCategory and Year
    SELECT @NextSequence = ISNULL(MAX(CAST(RIGHT(ApplicationID, LEN(ApplicationID) - CHARINDEX('.', ApplicationID, CHARINDEX('.', ApplicationID) + 1)) AS INT)), 0) + 1
    FROM Applications
    WHERE GrantCategory = @GrantCategory
      AND YEAR(ApplicationDate) = YEAR(@ApplicationDate);

    -- Generate the unique ApplicationID
    SET @ApplicationID = CONCAT(@GrantCategory, '.', YEAR(@ApplicationDate), '.', @NextSequence);

    -- Insert into Applications table
    INSERT INTO Applications (ApplicationID, UserID, UserType, GrantCategory, VehicleType, WithdrawalVehicleID, ApplicationDate, ExpirationDate, Email)
    VALUES (@ApplicationID, @UserID, @UserType, @GrantCategory, @VehicleType, @WithdrawalVehicleID, @ApplicationDate, @ExpirationDate, @Email);

    PRINT 'Application inserted successfully with ApplicationID: ' + @ApplicationID;
END;


DROP PROCEDURE InsertApplication2
EXEC InsertApplication2
    @UserID = 2042, -- Replace with a valid UserID from the Users table
    @UserType = 'individual',
    @GrantCategory = 'G3',
    @VehicleType = 'M1',
    @WithdrawalVehicleID = NULL,
    @ApplicationDate = '2024-07-02',
    @ExpirationDate = '2024-07-16',
    @Email = 'user2041@example.com';

-- Insert application for UserID 2041
DECLARE @ApplicationID NVARCHAR(20);
EXEC InsertApplication
    @UserID = 2041,
    @UserType = 'individual',
    @GrantCategory = 'C1',
    @VehicleType = 'M1',
    @WithdrawalVehicleID = NULL,
    @ApplicationDate = '2024-01-01',
    @Email = 'ksavva05@ucy.ac.cy',
    @FileName = 'Document1.pdf',
    @FilePath = '/path/to/Document1.pdf',
    @Size = 500000,
    @DocType = 'Order',
    @ApplicationID = @ApplicationID OUTPUT;
PRINT 'Inserted Application: ' + @ApplicationID;

-- Insert application for UserID 2042
EXEC InsertApplication
    @UserID = 2042,
    @UserType = 'legal_entity',
    @GrantCategory = 'C2',
    @VehicleType = 'N1',
    @WithdrawalVehicleID = 'W001',
    @ApplicationDate = '2024-02-01',
    @Email = 'user2041@example.com',
    @FileName = 'Document2.pdf',
    @FilePath = '/path/to/Document2.pdf',
    @Size = 800000,
    @DocType = 'Supportive',
    @ApplicationID = @ApplicationID OUTPUT;
PRINT 'Inserted Application: ' + @ApplicationID;

-- Insert application for UserID 2043
EXEC InsertApplication
    @UserID = 2043,
    @UserType = 'legal_entity',
    @GrantCategory = 'C3',
    @VehicleType = 'L',
    @WithdrawalVehicleID = 'W002',
    @ApplicationDate = '2024-03-01',
    @Email = 'user2042@example.com',
    @FileName = 'Document3.pdf',
    @FilePath = '/path/to/Document3.pdf',
    @Size = 600000,
    @DocType = 'Justification',
    @ApplicationID = @ApplicationID OUTPUT;
PRINT 'Inserted Application: ' + @ApplicationID;

-- Insert application for UserID 2044
EXEC InsertApplication
    @UserID = 2044,
    @UserType = 'individual',
    @GrantCategory = 'C1',
    @VehicleType = 'M2',
    @WithdrawalVehicleID = NULL,
    @ApplicationDate = '2024-01-15',
    @Email = 'user2043@example.com',
    @FileName = 'Document4.pdf',
    @FilePath = '/path/to/Document4.pdf',
    @Size = 400000,
    @DocType = 'Order',
    @ApplicationID = @ApplicationID OUTPUT;
PRINT 'Inserted Application: ' + @ApplicationID;

-- Insert application for UserID 2045
EXEC InsertApplication
    @UserID = 2045,
    @UserType = 'individual',
    @GrantCategory = 'C4',
    @VehicleType = 'N2',
    @WithdrawalVehicleID = 'W003',
    @ApplicationDate = '2024-02-15',
    @Email = 'user2044@example.com',
    @FileName = 'Document5.pdf',
    @FilePath = '/path/to/Document5.pdf',
    @Size = 700000,
    @DocType = 'Supportive',
    @ApplicationID = @ApplicationID OUTPUT;
PRINT 'Inserted Application: ' + @ApplicationID;

-- Insert application for UserID 2046
EXEC InsertApplication
    @UserID = 2046,
    @UserType = 'legal_entity',
    @GrantCategory = 'C5',
    @VehicleType = 'L',
    @WithdrawalVehicleID = NULL,
    @ApplicationDate = '2024-03-15',
    @Email = 'user2045@example.com',
    @FileName = 'Document6.pdf',
    @FilePath = '/path/to/Document6.pdf',
    @Size = 300000,
    @DocType = 'Justification',
    @ApplicationID = @ApplicationID OUTPUT;
PRINT 'Inserted Application: ' + @ApplicationID;

-- Insert application for UserID 2124
DECLARE @ApplicationID NVARCHAR(20);
EXEC InsertApplication
    @UserID = 2124,
    @UserType = 'individual',
    @GrantCategory = '?1',
    @VehicleType = 'M1',
    @WithdrawalVehicleID = NULL,
    @ApplicationDate = '2024-01-01',
    @Email = 'user2123@example.com',
    @FileName = 'Document1.pdf',
    @FilePath = '/documents/Document1.pdf',
    @Size = 500000,
    @DocType = 'Order',
    @ApplicationID = @ApplicationID OUTPUT;
PRINT 'Inserted Application for UserID 2124: ' + @ApplicationID;

-- Insert application for UserID 2125
EXEC InsertApplication
    @UserID = 2125,
    @UserType = 'legal_entity',
    @GrantCategory = 'C2',
    @VehicleType = 'N1',
    @WithdrawalVehicleID = 'W001',
    @ApplicationDate = '2024-02-01',
    @Email = 'user2124@example.com',
    @FileName = 'Document2.pdf',
    @FilePath = '/documents/Document2.pdf',
    @Size = 800000,
    @DocType = 'Supportive',
    @ApplicationID = @ApplicationID OUTPUT;
PRINT 'Inserted Application for UserID 2125: ' + @ApplicationID;

-- Insert application for UserID 2126
EXEC InsertApplication
    @UserID = 2126,
    @UserType = 'legal_entity',
    @GrantCategory = 'C3',
    @VehicleType = 'L',
    @WithdrawalVehicleID = NULL,
    @ApplicationDate = '2024-03-01',
    @Email = 'user2125@example.com',
    @FileName = 'Document3.pdf',
    @FilePath = '/documents/Document3.pdf',
    @Size = 600000,
    @DocType = 'Justification',
    @ApplicationID = @ApplicationID OUTPUT;
PRINT 'Inserted Application for UserID 2126: ' + @ApplicationID;

-- Insert application for UserID 2127
EXEC InsertApplication
    @UserID = 2127,
    @UserType = 'individual',
    @GrantCategory = 'C4',
    @VehicleType = 'M2',
    @WithdrawalVehicleID = 'W002',
    @ApplicationDate = '2024-01-15',
    @Email = 'user2126@example.com',
    @FileName = 'Document4.pdf',
    @FilePath = '/documents/Document4.pdf',
    @Size = 700000,
    @DocType = 'Supportive',
    @ApplicationID = @ApplicationID OUTPUT;
PRINT 'Inserted Application for UserID 2127: ' + @ApplicationID;

-- Insert application for UserID 2128
EXEC InsertApplication
    @UserID = 2128,
    @UserType = 'individual',
    @GrantCategory = 'C5',
    @VehicleType = 'N2',
    @WithdrawalVehicleID = 'W003',
    @ApplicationDate = '2024-02-15',
    @Email = 'user2127@example.com',
    @FileName = 'Document5.pdf',
    @FilePath = '/documents/Document5.pdf',
    @Size = 400000,
    @DocType = 'Order',
    @ApplicationID = @ApplicationID OUTPUT;
PRINT 'Inserted Application for UserID 2128: ' + @ApplicationID;

-- Insert application for UserID 2130
EXEC InsertApplication
    @UserID = 2130,
    @UserType = 'legal_entity',
    @GrantCategory = 'C1',
    @VehicleType = 'M1',
    @WithdrawalVehicleID = NULL,
    @ApplicationDate = '2024-03-01',
    @Email = 'user2129@example.com',
    @FileName = 'Document6.pdf',
    @FilePath = '/documents/Document6.pdf',
    @Size = 600000,
    @DocType = 'Order',
    @ApplicationID = @ApplicationID OUTPUT;
PRINT 'Inserted Application for UserID 2130: ' + @ApplicationID;

-- Insert application for UserID 2189
EXEC InsertApplication
    @UserID = 2189,
    @UserType = 'legal_entity',
    @GrantCategory = 'C2',
    @VehicleType = 'L',
    @WithdrawalVehicleID = 'W004',
    @ApplicationDate = '2024-01-15',
    @Email = 'user2188@example.com',
    @FileName = 'Document7.pdf',
    @FilePath = '/documents/Document7.pdf',
    @Size = 450000,
    @DocType = 'Supportive',
    @ApplicationID = @ApplicationID OUTPUT;
PRINT 'Inserted Application for UserID 2189: ' + @ApplicationID;

-- Insert application for UserID 2191
EXEC InsertApplication
    @UserID = 2191,
    @UserType = 'individual',
    @GrantCategory = 'C3',
    @VehicleType = 'N1',
    @WithdrawalVehicleID = 'W005',
    @ApplicationDate = '2024-02-15',
    @Email = 'user2190@example.com',
    @FileName = 'Document8.pdf',
    @FilePath = '/documents/Document8.pdf',
    @Size = 500000,
    @DocType = 'Justification',
    @ApplicationID = @ApplicationID OUTPUT;
PRINT 'Inserted Application for UserID 2191: ' + @ApplicationID;
