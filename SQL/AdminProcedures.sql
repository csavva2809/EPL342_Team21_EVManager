CREATE PROCEDURE ChangeRole
    @AdminUserName NVARCHAR(25), -- Username of the admin initiating the role change
    @TargetUserName NVARCHAR(25), -- Username of the user whose role will be changed
    @NewRole NVARCHAR(10) -- New role to assign
AS
BEGIN
    -- Declare variables for validation
    DECLARE @IsAdmin BIT;
    DECLARE @RoleCount INT;

    -- Check if the requesting user is an admin
    SELECT @IsAdmin = CASE WHEN Role = 'admin' THEN 1 ELSE 0 END
    FROM Users
    WHERE UserName = @AdminUserName;

    IF @IsAdmin = 1
    BEGIN
        -- Check if the new role is valid
        SELECT @RoleCount = COUNT(*)
        FROM (VALUES ('user'), ('admin'), ('TOM'), ('dealer')) AS Roles(RoleName)
        WHERE RoleName = @NewRole;

        IF @RoleCount = 1
        BEGIN
            -- Update the target user's role
            UPDATE Users
            SET Role = @NewRole
            WHERE UserName = @TargetUserName;

            IF @@ROWCOUNT = 0
            BEGIN
                -- No rows affected, target user does not exist
                PRINT 'Error: Target user does not exist.';
            END
            ELSE
            BEGIN
                PRINT 'Success: Role updated successfully.';
            END
        END
        ELSE
        BEGIN
            -- Invalid role provided
            PRINT 'Error: Invalid role provided.';
        END
    END
    ELSE
    BEGIN
        -- Requesting user is not an admin
        PRINT 'Error: Only admins can change user roles.';
    END
END;

EXEC ChangeRole 
    @AdminUserName = 'user2041', 
    @TargetUserName = 'ksavva05', 
    @NewRole = 'admin';

-- Create a stored procedure to fetch application statuses
CREATE PROCEDURE GetApplicationStatuses
AS
BEGIN
    SELECT 
        a.ApplicationID, 
        u.UserName, 
        a.Email, 
        sh.Status, 
        sh.StatusDate 
    FROM Applications a
    INNER JOIN StatusHistory sh ON a.ApplicationID = sh.ApplicationID
    INNER JOIN Users u ON a.UserID = u.UserID
    WHERE sh.StatusID = (
        SELECT MAX(StatusID)
        FROM StatusHistory
        WHERE ApplicationID = a.ApplicationID
    )
    ORDER BY sh.StatusDate DESC;
END
