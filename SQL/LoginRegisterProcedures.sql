CREATE PROCEDURE RegisterUser
    @PersonID NVARCHAR(20),
    @LastName NVARCHAR(25),
    @FirstName NVARCHAR(25),
    @UserName NVARCHAR(25),
    @Email NVARCHAR(40),
    @PasswordHash NVARCHAR(255),
    @Address NVARCHAR(100),
    @BirthDate DATE,
    @Phone VARCHAR(15),
    @Sex CHAR(6),
    @Success BIT OUTPUT,
    @Message NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UsernameExists INT;
    DECLARE @EmailExists INT;
    DECLARE @PersonIDExists INT;

    -- Check if PersonID already exists
    SELECT @PersonIDExists = COUNT(*)
    FROM Users
    WHERE PersonID = @PersonID;

    IF @PersonIDExists > 0
    BEGIN
        SET @Success = 0;
        SET @Message = 'PersonID already exists.';
        RETURN;
    END;

    -- Check if Username exists
    SELECT @UsernameExists = COUNT(*)
    FROM Users
    WHERE UserName = @UserName;

    IF @UsernameExists > 0
    BEGIN
        SET @Success = 0;
        SET @Message = 'Username already exists.';
        RETURN;
    END;

    -- Check if Email exists
    SELECT @EmailExists = COUNT(*)
    FROM Users
    WHERE Email = @Email;

    IF @EmailExists > 0
    BEGIN
        SET @Success = 0;
        SET @Message = 'Email already exists.';
        RETURN;
    END;

    -- Try to insert user
    BEGIN TRY
        INSERT INTO Users (
            PersonID, LastName, FirstName, UserName, Email, PasswordHash, Address, BirthDate, Phone, Sex
        )
        VALUES (
            @PersonID, @LastName, @FirstName, @UserName, @Email, @PasswordHash, @Address, @BirthDate, @Phone, @Sex
        );

        SET @Success = 1;
        SET @Message = 'Registration successful.';
    END TRY
    BEGIN CATCH
        SET @Success = 0;
        SET @Message = ERROR_MESSAGE(); -- Capture and return the error message
    END CATCH;
END;


CREATE PROCEDURE ValidateLogin
    @UserName NVARCHAR(25),
    @PasswordHash NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT @PasswordHash = PasswordHash
    FROM Users
    WHERE UserName = @UserName;
END;
