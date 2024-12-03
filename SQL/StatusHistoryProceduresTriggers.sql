CREATE TRIGGER trg_InsertStatusHistory
ON Applications
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert a record into StatusHistory for each new application
    INSERT INTO StatusHistory (ApplicationID, Status, StatusDate)
    SELECT ApplicationID, 'submitted', GETDATE()
    FROM inserted;
END;

CREATE PROCEDURE DisplayStatusHistory
AS
BEGIN
    SET NOCOUNT ON;

    -- Select all records from the StatusHistory table
    SELECT 
        StatusID,
        ApplicationID,
        Status,
        StatusDate
    FROM StatusHistory
    ORDER BY StatusDate DESC; -- Order by the most recent status changes
END;

EXEC DisplayStatusHistory;


CREATE PROCEDURE UpdateApplicationStatus
    @UserID INT,
    @ApplicationID NVARCHAR(20),
    @NewStatus NVARCHAR(20),
    @Comments NVARCHAR(500) = NULL -- Allow NULL for comments
AS
BEGIN
    SET NOCOUNT ON;

    -- Declare variable for user role
    DECLARE @UserRole NVARCHAR(20);

    -- Fetch the user's role
    SELECT @UserRole = Role
    FROM Users
    WHERE UserID = @UserID;

    -- Check if the user is an admin
    IF @UserRole <> 'admin'
    BEGIN
        RAISERROR ('Only an admin can change the application status.', 16, 1);
        RETURN;
    END;

    -- Validate the new status
    IF @NewStatus NOT IN ('submitted', 'approved', 'rejected', 'expired')
    BEGIN
        RAISERROR ('Invalid status provided.', 16, 1);
        RETURN;
    END;

    -- Check if the application exists
    IF NOT EXISTS (
        SELECT 1
        FROM Applications
        WHERE ApplicationID = @ApplicationID
    )
    BEGIN
        RAISERROR ('Application not found.', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insert the status change and comments into the StatusHistory table
        INSERT INTO StatusHistory (ApplicationID, Status, StatusDate, Comments)
        VALUES (@ApplicationID, @NewStatus, GETDATE(), @Comments);

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Propagate the error
        THROW;
    END CATCH;
END;

EXEC UpdateApplicationStatus 
    @UserID = 5, 
    @ApplicationID = 'GC14.0005', 
    @NewStatus = 'approved';


CREATE TRIGGER trg_UpdateExpiredStatus
ON Applications
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Update statuses to 'rejected' for expired applications
    UPDATE StatusHistory
    SET Status = 'rejected', 
        StatusDate = GETDATE()
    FROM StatusHistory sh
    INNER JOIN Applications a ON sh.ApplicationID = a.ApplicationID
    WHERE a.ExpirationDate <= GETDATE()
      AND a.ExpirationDate IS NOT NULL
      AND sh.Status IN ('submitted', 'approved');
END;

CREATE TRIGGER IncrementGrantSumPriceOnRejectionOrExpiration
ON StatusHistory
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the inserted status is 'rejected' or 'expired'
    IF EXISTS (
        SELECT 1 
        FROM inserted
        WHERE Status IN ('rejected', 'expired')
    )
    BEGIN
        -- Update the SumPrice of the relevant grant
        UPDATE Grants
        SET SumPrice = SumPrice + GrantPrice
        FROM Grants
        INNER JOIN Applications ON Grants.GrantCategory = Applications.GrantCategory
        INNER JOIN inserted ON Applications.ApplicationID = inserted.ApplicationID
        WHERE inserted.Status IN ('rejected', 'expired');
    END
END;

