SELECT TOP (1000) [UserID]
      ,[CompanyName]
      ,[RegistrationNumber]
      ,[TaxNumber]
      ,[EstablishedDate]
      ,[Address]
      ,[Phone]
      ,[Email]
  FROM [ksavva05].[ksavva05].[LegalEntities]

  DROP PROCEDURE RegisterIndividualUser;

  CREATE PROCEDURE RegisterIndividualUser
    @PersonID NVARCHAR(20),
    @LastName NVARCHAR(25),
    @FirstName NVARCHAR(25),
    @UserName NVARCHAR(25),
    @Email NVARCHAR(40),
    @PasswordHash NVARCHAR(255),
    @Address NVARCHAR(100),
    @BirthDate DATE,
    @Phone VARCHAR(15),
    @Role VARCHAR(10),
    @Sex CHAR(6),
    @Success BIT OUTPUT,
    @Message NVARCHAR(255) OUTPUT
AS
BEGIN
    -- Check if the username or email already exists
    IF EXISTS (SELECT 1 FROM Users WHERE UserName = @UserName OR Email = @Email)
    BEGIN
        SET @Success = 0;
        SET @Message = 'Username or Email already exists.';
        RETURN;
    END

    BEGIN TRY
        -- Insert the individual user into Users table
        INSERT INTO Users (PersonID, LastName, FirstName, UserName, Email, PasswordHash, Address, BirthDate, Phone, Role, Sex, UserType)
        VALUES (@PersonID, @LastName, @FirstName, @UserName, @Email, @PasswordHash, @Address, @BirthDate, @Phone, @Role, @Sex, 'individual');

        SET @Success = 1;
        SET @Message = 'Individual user registered successfully.';
    END TRY
    BEGIN CATCH
        SET @Success = 0;
        SET @Message = ERROR_MESSAGE();
    END CATCH
END;

DROP PROCEDURE RegisterIndividualUser;
DROP PROCEDURE RegisterLegalEntity;

CREATE PROCEDURE RegisterLegalEntity
    @UserName NVARCHAR(25),
    @Email NVARCHAR(40),
    @PasswordHash NVARCHAR(255),
    @Address NVARCHAR(100),
    @Phone VARCHAR(15),
    @Role VARCHAR(10),
    @CompanyName NVARCHAR(100),
    @RegistrationNumber NVARCHAR(50),
    @TaxNumber NVARCHAR(50),
    @EstablishedDate DATE,
    @Success BIT OUTPUT,
    @Message NVARCHAR(255) OUTPUT
AS
BEGIN
    -- Declare a scalar variable to capture the inserted UserID
    DECLARE @UserID INT;

    -- Check if the username, email, or registration number already exists
    IF EXISTS (SELECT 1 FROM Users WHERE UserName = @UserName OR Email = @Email) OR
       EXISTS (SELECT 1 FROM LegalEntities WHERE RegistrationNumber = @RegistrationNumber)
    BEGIN
        SET @Success = 0;
        SET @Message = 'Username, Email, or Registration Number already exists.';
        RETURN;
    END

    BEGIN TRY
        -- Insert into Users table and capture the generated UserID
        INSERT INTO Users (UserName, Email, PasswordHash, Address, Phone, Role, UserType)
        VALUES (@UserName, @Email, @PasswordHash, @Address, @Phone, @Role, 'legal');

        -- Retrieve the last inserted UserID
        SET @UserID = SCOPE_IDENTITY();

        -- Insert into LegalEntities table using the captured UserID
        INSERT INTO LegalEntities (UserID, CompanyName, RegistrationNumber, TaxNumber, EstablishedDate, Address, Phone, Email)
        VALUES (@UserID, @CompanyName, @RegistrationNumber, @TaxNumber, @EstablishedDate, @Address, @Phone, @Email);

        SET @Success = 1;
        SET @Message = 'Legal entity registered successfully.';
    END TRY
    BEGIN CATCH
        SET @Success = 0;
        SET @Message = ERROR_MESSAGE();
    END CATCH
END;
