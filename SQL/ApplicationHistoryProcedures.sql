DROP PROCEDURE GetApplicationStatus;

EXEC GetApplicationStatus;
CREATE PROCEDURE GetApplicationStatus
AS
BEGIN
    SELECT 
        a.ApplicationID,
        a.UserID,
        a.GrantCategory,
        sh.Status AS LatestStatus,
        sh.StatusDate AS LatestStatusDate
    FROM 
        Applications a
    LEFT JOIN 
        StatusHistory sh ON a.ApplicationID = sh.ApplicationID
    WHERE
        sh.StatusID = (
            SELECT MAX(StatusID)
            FROM StatusHistory
            WHERE ApplicationID = a.ApplicationID
        )
    ORDER BY 
        a.ApplicationID;
END;
