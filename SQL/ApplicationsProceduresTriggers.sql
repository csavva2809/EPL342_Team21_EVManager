CREATE TRIGGER trg_SetExpirationDate
ON Applications
AFTER INSERT
AS
BEGIN
    UPDATE Applications
    SET ExpirationDate = DATEADD(DAY, 14, ApplicationDate)
    WHERE ApplicationID IN (SELECT ApplicationID FROM inserted);
END;

DROP TRIGGER trg_SetExpirationDate;

CREATE PROCEDURE InsertApplication
    @UserID INT,
    @UserType NVARCHAR(20),
    @GrantCategory NVARCHAR(10),
    @VehicleType NVARCHAR(10) = NULL,
    @WithdrawalVehicleID NVARCHAR(20) = NULL,
    @ApplicationDate DATE,
    @Email NVARCHAR(255),
    @FileName NVARCHAR(255) = NULL,  -- File name parameter
    @FilePath NVARCHAR(255) = NULL,  -- File path parameter
    @Size INT = NULL,                -- File size parameter
    @DocType NVARCHAR(15) = NULL,    -- DocType parameter
    @ApplicationID NVARCHAR(20) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NextID INT, @Error NVARCHAR(255);

    BEGIN TRY
        -- Generate ApplicationID
        SELECT @NextID = ISNULL(MAX(CAST(SUBSTRING(ApplicationID, CHARINDEX('.', ApplicationID) + 1, LEN(ApplicationID)) AS INT)), 0) + 1
        FROM Applications
        WHERE GrantCategory = @GrantCategory;

        SET @ApplicationID = CONCAT('Γ', @GrantCategory, '.', FORMAT(@NextID, 'D4'));

        -- Insert Application
        INSERT INTO Applications (ApplicationID, UserID, UserType, GrantCategory, VehicleType, WithdrawalVehicleID, ApplicationDate, Email)
        VALUES (@ApplicationID, @UserID, @UserType, @GrantCategory, @VehicleType, @WithdrawalVehicleID, @ApplicationDate, @Email);

        -- Adjust Grant SumPrice (decrement it by GrantPrice)
        UPDATE Grants
        SET SumPrice = SumPrice - GrantPrice
        WHERE GrantCategory = @GrantCategory;

        -- Upload Document if provided
        IF @FileName IS NOT NULL AND @FilePath IS NOT NULL AND @Size IS NOT NULL AND @DocType IS NOT NULL
        BEGIN
            EXEC UploadDocument @ApplicationID, @FileName, @FilePath, @Size, @DocType;
        END;

    END TRY
    BEGIN CATCH
        -- Capture and re-throw errors
        SET @Error = ERROR_MESSAGE();
        THROW 50000, @Error, 1;
    END CATCH;
END;


DROP PROCEDURE InsertApplication;

DROP TRIGGER trg_EnforceApplicationRules;

CREATE TRIGGER trg_EnforceApplicationRules
ON Applications
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Declare variables for validation
    DECLARE @UserID INT, @UserType NVARCHAR(20), @GrantCategory NVARCHAR(10), @WithdrawalVehicleID NVARCHAR(20);
    DECLARE @CategoryGroup NVARCHAR(10);
    DECLARE @ApplicationCount INT;

    -- Extract values from the inserted row
    SELECT 
        @UserID = UserID, 
        @UserType = UserType, 
        @GrantCategory = GrantCategory, 
        @WithdrawalVehicleID = WithdrawalVehicleID
    FROM inserted;

		-- Treat empty strings as NULL
	SET @WithdrawalVehicleID = NULLIF(@WithdrawalVehicleID, '');

	-- Ensure unique non-NULL WithdrawalVehicleID
	IF @WithdrawalVehicleID IS NOT NULL AND EXISTS (
		SELECT 1
		FROM Applications
		WHERE WithdrawalVehicleID = @WithdrawalVehicleID
		  AND WithdrawalVehicleID IS NOT NULL -- Exclude NULL values
	)
	BEGIN
		RAISERROR ('Duplicate WithdrawalVehicleID is not allowed.', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN;
END;


    -- Determine the category group
    IF @GrantCategory IN ('C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10', 'C11', 'C12', 'C13')
        SET @CategoryGroup = 'C1-C13';
    ELSE
        SET @CategoryGroup = @GrantCategory; -- Group matches the category (C14, C15, or C16)

    -- Individual user validation
    IF @UserType = 'individual'
    BEGIN
        -- Check if the individual has already submitted an application in this group
        IF EXISTS (
            SELECT 1
            FROM Applications
            WHERE UserID = @UserID
              AND (
                (@CategoryGroup = 'C1-C13' AND GrantCategory IN ('C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10', 'C11', 'C12', 'C13'))
                OR GrantCategory = @CategoryGroup
              )
        )
        BEGIN
            RAISERROR ('Individual users can only submit one application per allowed group (C1-C13, C14, C15, C16).', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
    END
    -- Legal entity validation
    ELSE IF @UserType = 'legal_entity'
    BEGIN
        -- Validate that the grant category is allowed for legal entities
        IF @GrantCategory NOT IN ('C1', 'C2', 'C5', 'C6', 'C10', 'C11', 'C12', 'C13', 'C14')
        BEGIN
            RAISERROR ('Legal entities can only apply for the allowed grant categories (C1, C2, C5, C6, C10, C11, C12, C13, C14).', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- Ensure legal entities submit at most 20 applications for allowed categories
        SELECT @ApplicationCount = COUNT(*)
        FROM Applications
        WHERE UserID = @UserID
          AND GrantCategory IN ('C1', 'C2', 'C5', 'C6', 'C10', 'C11', 'C12', 'C13', 'C14');

        IF @ApplicationCount >= 20
        BEGIN
            RAISERROR ('Legal entities can only submit up to 20 applications for the allowed categories.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;
    END

	-- Decrement the SumPrice for the grant category
	--UPDATE Grants
	--SET SumPrice = SumPrice - GrantPrice
	--FROM Grants g
	--INNER JOIN inserted i ON g.GrantCategory = i.GrantCategory
	--WHERE g.SumPrice >= g.GrantPrice; -- Ensure sufficient funds for at least one grant


    -- Insert the row(s) if all checks pass
    INSERT INTO Applications (ApplicationID, UserID, UserType, GrantCategory, VehicleType, WithdrawalVehicleID, ApplicationDate, ExpirationDate, Email)
    SELECT ApplicationID, UserID, UserType, GrantCategory, VehicleType, WithdrawalVehicleID, ApplicationDate, ExpirationDate, Email
    FROM inserted;
END;

CREATE PROCEDURE DisplayApplications
AS
BEGIN
    SET NOCOUNT ON;

    -- Select all records from the Applications table along with user details (if needed)
    SELECT 
        A.ApplicationID,
        A.UserID,
        U.Username AS UserName, -- Assuming Users table has a Username column
        A.UserType,
        A.GrantCategory,
        A.VehicleType,
        A.WithdrawalVehicleID,
        A.ApplicationDate,
        A.ExpirationDate,
        A.Email
    FROM Applications A
    INNER JOIN Users U ON A.UserID = U.UserID -- Join to fetch user details
    ORDER BY A.ApplicationDate DESC; -- Sort by most recent applications
END;

