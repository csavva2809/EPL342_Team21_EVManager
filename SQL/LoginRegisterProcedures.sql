CREATE PROCEDURE ValidateLogin
    @UserName NVARCHAR(25),
    @Password NVARCHAR(255) OUTPUT
AS
BEGIN
   SELECT @Password = Password
   FROM Users
   WHERE UserName = @UserName
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
    DECLARE @UsernameExists INT;
    DECLARE @EmailExists INT;

    SELECT @UsernameExists = COUNT(*)
    FROM Users
    WHERE UserName = @UserName;

    SELECT @EmailExists = COUNT(*)
    FROM Users
    WHERE Email = @Email;

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