CREATE PROCEDURE ValidateLogin
    @UserName NVARCHAR(25),
    @Password NVARCHAR(255),
    @IsValid BIT OUTPUT
AS
BEGIN
    DECLARE @StoredPassword NVARCHAR(255);

    -- Retrieve the hashed password for the given username
    SELECT @StoredPassword = Password
    FROM Users
    WHERE UserName = @UserName;

    -- Verify the password if the username exists
    IF @StoredPassword IS NOT NULL AND @StoredPassword = @Password
        SET @IsValid = 1;
    ELSE
        SET @IsValid = 0;
END;

DROP PROCEDURE IF EXISTS ValidateLogin;

CREATE PROCEDURE RegisterUser
	@PersonID NVARCHAR(20),
    @LastName NVARCHAR(25),
    @FirstName NVARCHAR(25),
    @UserName NVARCHAR(25),
    @Email NVARCHAR(40),
    @Password NVARCHAR(255),
    @Address NVARCHAR(50),
    @BirthDate NVARCHAR(11),
    @Phone NVARCHAR(15),
    @Sex NVARCHAR(10),
    @Success BIT OUTPUT,
    @Message NVARCHAR(255) OUTPUT
AS
BEGIN
    -- Declare variables to check for existing username and email
    DECLARE @UsernameExists INT;
    DECLARE @EmailExists INT;

    -- Check if the username already exists
    SELECT @UsernameExists = COUNT(*)
    FROM Users
    WHERE UserName = @UserName;

    -- Check if the email already exists
    SELECT @EmailExists = COUNT(*)
    FROM Users
    WHERE Email = @Email;

    -- Handle duplicate username or email
    IF @UsernameExists > 0
    BEGIN
        SET @Success = 0;
        SET @Message = 'Username already exists.';
        RETURN;
    END
    ELSE IF @EmailExists > 0
    BEGIN
        SET @Success = 0;
        SET @Message = 'Email already exists.';
        RETURN;
    END

    -- Insert the new user into the Users table
    BEGIN TRY
        INSERT INTO Users (
            PersonID, LastName, FirstName, UserName, Email, Password, Address, BirthDate, Phone, Sex
        )
        VALUES (
            (SELECT ISNULL(MAX(PersonID), 0) + 1 FROM Users), -- Auto-generate PersonID
            @LastName, @FirstName, @UserName, @Email, @Password, @Address, @BirthDate, @Phone, @Sex
        );

        SET @Success = 1;
        SET @Message = 'Registration successful.';
    END TRY
    BEGIN CATCH
        SET @Success = 0;
        SET @Message = ERROR_MESSAGE(); -- Capture and return the error message
    END CATCH
END;
DROP PROCEDURE IF EXISTS RegisterUser;