CREATE PROCEDURE GetTotalGrantsAllocated
AS
BEGIN
    SELECT 
        g.GrantCategory,
        g.Description,
        COUNT(a.ApplicationID) AS TotalApplications,
        SUM(g.GrantPrice) AS TotalGrantAllocated
    FROM Grants g
    LEFT JOIN Applications a ON g.GrantCategory = a.GrantCategory
    GROUP BY g.GrantCategory, g.Description
    ORDER BY TotalGrantAllocated DESC;
END;

EXEC GetTotalGrantsAllocated;


CREATE PROCEDURE GetRemainingGrantAmounts
AS
BEGIN
    SELECT 
        g.GrantCategory,
        g.Description,
        g.SumPrice - ISNULL(SUM(g.GrantPrice), 0) AS RemainingAmount
    FROM Grants g
    LEFT JOIN Applications a ON g.GrantCategory = a.GrantCategory
    GROUP BY g.GrantCategory, g.Description, g.SumPrice
    ORDER BY RemainingAmount DESC;
END;

EXEC GetRemainingGrantAmounts;

--------------------------------------------------------------------------

CREATE PROCEDURE GetApplicationCounts
AS
BEGIN
    SELECT 
        a.GrantCategory,
        COUNT(a.ApplicationID) AS ApplicationCount
    FROM Applications a
    GROUP BY a.GrantCategory
    ORDER BY ApplicationCount DESC;
END;

EXEC GetApplicationCounts;


CREATE PROCEDURE GetApplicationTrends
AS
BEGIN
    SELECT 
        a.GrantCategory,
        COUNT(a.ApplicationID) * 100.0 / (SELECT COUNT(*) FROM Applications) AS Percentage
    FROM Applications a
    GROUP BY a.GrantCategory;
END;

EXEC GetApplicationTrends;


CREATE PROCEDURE GetSuccessRate
AS
BEGIN
    SELECT 
        a.GrantCategory,
        COUNT(CASE WHEN s.Status = 'approved' THEN 1 END) * 100.0 / COUNT(*) AS SuccessRate
    FROM Applications a
    INNER JOIN StatusHistory s ON a.ApplicationID = s.ApplicationID
    WHERE s.Status IN ('approved', 'rejected')
    GROUP BY a.GrantCategory;
END;

EXEC GetSuccessRate;


CREATE PROCEDURE GetHighActivityPeriods
AS
BEGIN
    SELECT 
        YEAR(a.ApplicationDate) AS Year,
        MONTH(a.ApplicationDate) AS Month,
        COUNT(*) AS ApplicationCount
    FROM Applications a
    GROUP BY YEAR(a.ApplicationDate), MONTH(a.ApplicationDate)
    ORDER BY ApplicationCount DESC;
END;

EXEC GetHighActivityPeriods;


------------------------------------------------------------------------------------

CREATE PROCEDURE GetAverageGrantAmount
AS
BEGIN
    SELECT 
        g.GrantCategory,
        AVG(g.GrantPrice) AS AverageGrantAmount
    FROM Applications a
    INNER JOIN Grants g ON a.GrantCategory = g.GrantCategory
    INNER JOIN StatusHistory s ON a.ApplicationID = s.ApplicationID
    WHERE s.Status = 'approved'
    GROUP BY g.GrantCategory;
END;
EXEC GetAverageGrantAmount;


CREATE PROCEDURE GetGrantExtremes
AS
BEGIN
    SELECT TOP 1
        g.GrantCategory,
        SUM(g.GrantPrice) AS TotalGrantAllocated
    FROM Applications a
    INNER JOIN Grants g ON a.GrantCategory = g.GrantCategory
    GROUP BY g.GrantCategory
    ORDER BY TotalGrantAllocated DESC;

    SELECT TOP 1
        g.GrantCategory,
        SUM(g.GrantPrice) AS TotalGrantAllocated
    FROM Applications a
    INNER JOIN Grants g ON a.GrantCategory = g.GrantCategory
    GROUP BY g.GrantCategory
    ORDER BY TotalGrantAllocated ASC;
END;
-- Highest Allocation
EXEC GetGrantExtremes;

---------------------------------------------------------------------------------
CREATE PROCEDURE GetLegalEntitiesPerformance
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    SELECT 
        le.CompanyName,
        le.RegistrationNumber,
        COUNT(a.ApplicationID) AS TotalApplications
    FROM LegalEntities le
    LEFT JOIN Applications a ON le.UserID = a.UserID
    WHERE a.ApplicationDate BETWEEN @StartDate AND @EndDate
    GROUP BY le.CompanyName, le.RegistrationNumber;
END;

DECLARE @StartDate DATE = '2024-11-01';
DECLARE @EndDate DATE = '2024-12-31';
EXEC GetLegalEntitiesPerformance @StartDate, @EndDate;


CREATE PROCEDURE GetMonthlyGrantActivity
AS
BEGIN
    SELECT 
        g.GrantCategory,
        MONTH(a.ApplicationDate) AS Month,
        COUNT(a.ApplicationID) AS ApplicationCount
    FROM Grants g
    INNER JOIN Applications a ON g.GrantCategory = a.GrantCategory
    WHERE a.ApplicationDate >= DATEADD(MONTH, -4, GETDATE())
    GROUP BY g.GrantCategory, MONTH(a.ApplicationDate);
END;

EXEC GetMonthlyGrantActivity;


CREATE PROCEDURE GetCategoriesWithMinApplications
    @Year INT,
    @MinApplications INT
AS
BEGIN
    SELECT 
        g.GrantCategory,
        COUNT(a.ApplicationID) AS ApplicationCount
    FROM Grants g
    INNER JOIN Applications a ON g.GrantCategory = a.GrantCategory
    WHERE YEAR(a.ApplicationDate) = @Year
    GROUP BY g.GrantCategory
    HAVING COUNT(a.ApplicationID) >= @MinApplications;
END;

DECLARE @Year INT = 2024;
DECLARE @MinApplications INT = 5;
EXEC GetCategoriesWithMinApplications @Year, @MinApplications;



CREATE PROCEDURE GetApplicationsByDateRange
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    -- Check if the dates are valid
    IF @StartDate IS NULL OR @EndDate IS NULL
    BEGIN
        PRINT 'StartDate and EndDate cannot be NULL.'
        RETURN;
    END

    -- Check if the start date is earlier than the end date
    IF @StartDate > @EndDate
    BEGIN
        PRINT 'StartDate must be earlier than or equal to EndDate.'
        RETURN;
    END

    -- Retrieve applications within the date range
    SELECT ApplicationID, UserID, UserType, GrantCategory, VehicleType, WithdrawalVehicleID, ApplicationDate, ExpirationDate, Email
    FROM Applications
    WHERE ApplicationDate BETWEEN @StartDate AND @EndDate
    ORDER BY ApplicationDate;
END;


DECLARE @StartDate DATE = '2024-12-01';
DECLARE @EndDate DATE = '2024-12-01';
EXEC GetApplicationsByDateRange @StartDate,@EndDate;

CREATE PROCEDURE GetApplicationsByGrantCategory
    @GrantCategories NVARCHAR(MAX) -- Comma-separated list of categories
AS
BEGIN
    -- Validate input
    IF @GrantCategories IS NULL OR LEN(@GrantCategories) = 0
    BEGIN
        PRINT 'GrantCategories cannot be NULL or empty.'
        RETURN;
    END

    -- Convert the comma-separated list into a table variable for filtering
    DECLARE @Categories TABLE (GrantCategory NVARCHAR(10));
    DECLARE @Category NVARCHAR(10);
    DECLARE @Pos INT;

    -- Split the input string into individual categories and insert into the table variable
    WHILE LEN(@GrantCategories) > 0
    BEGIN
        SET @Pos = CHARINDEX(',', @GrantCategories);
        IF @Pos = 0
        BEGIN
            SET @Category = LTRIM(RTRIM(@GrantCategories));
            SET @GrantCategories = '';
        END
        ELSE
        BEGIN
            SET @Category = LTRIM(RTRIM(SUBSTRING(@GrantCategories, 1, @Pos - 1)));
            SET @GrantCategories = SUBSTRING(@GrantCategories, @Pos + 1, LEN(@GrantCategories) - @Pos);
        END

        IF LEN(@Category) > 0
            INSERT INTO @Categories (GrantCategory) VALUES (@Category);
    END

    -- Select applications matching the specified grant categories
    SELECT ApplicationID, UserID, UserType, GrantCategory, VehicleType, WithdrawalVehicleID, ApplicationDate, ExpirationDate, Email
    FROM Applications
    WHERE GrantCategory IN (SELECT GrantCategory FROM @Categories)
    ORDER BY GrantCategory, ApplicationDate;
END;

-- Replace with your desired grant categories (comma-separated)
EXEC GetApplicationsByGrantCategory @GrantCategories = 'C4,';

CREATE PROCEDURE GetApplicationsByApplicantType
    @ApplicantTypes NVARCHAR(MAX) -- Comma-separated list of applicant types (e.g., 'individual,legal_entity')
AS
BEGIN
    -- Validate input
    IF @ApplicantTypes IS NULL OR LEN(@ApplicantTypes) = 0
    BEGIN
        PRINT 'ApplicantTypes cannot be NULL or empty.';
        RETURN;
    END

    -- Convert the comma-separated list into a table variable for filtering
    DECLARE @Types TABLE (UserType NVARCHAR(20));
    DECLARE @Type NVARCHAR(20);
    DECLARE @Pos INT;

    -- Split the input string into individual applicant types and insert into the table variable
    WHILE LEN(@ApplicantTypes) > 0
    BEGIN
        SET @Pos = CHARINDEX(',', @ApplicantTypes);
        IF @Pos = 0
        BEGIN
            SET @Type = LTRIM(RTRIM(@ApplicantTypes));
            SET @ApplicantTypes = '';
        END
        ELSE
        BEGIN
            SET @Type = LTRIM(RTRIM(SUBSTRING(@ApplicantTypes, 1, @Pos - 1)));
            SET @ApplicantTypes = SUBSTRING(@ApplicantTypes, @Pos + 1, LEN(@ApplicantTypes) - @Pos);
        END

        IF LEN(@Type) > 0
            INSERT INTO @Types (UserType) VALUES (@Type);
    END

    -- Select applications matching the specified applicant types
    SELECT ApplicationID, UserID, UserType, GrantCategory, VehicleType, WithdrawalVehicleID, ApplicationDate, ExpirationDate, Email
    FROM Applications
    WHERE UserType IN (SELECT UserType FROM @Types)
    ORDER BY UserType, ApplicationDate;
END;

-- Replace with your desired applicant types (comma-separated)
EXEC GetApplicationsByApplicantType @ApplicantTypes = 'Individual';