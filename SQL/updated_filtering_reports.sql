CREATE PROCEDURE sp_GetTotalGrantAmounts
    @SortOption NVARCHAR(50) -- Sorting option: 'amount_asc', 'amount_desc', 'category_asc', 'category_desc'
AS
BEGIN
    IF @SortOption = 'amount_asc'
    BEGIN
        SELECT 
            GrantCategory,
            SUM(GrantPrice) AS TotalAmount
        FROM Grants
        GROUP BY GrantCategory
        ORDER BY SUM(GrantPrice) ASC;
    END
    ELSE IF @SortOption = 'amount_desc'
    BEGIN
        SELECT 
            GrantCategory,
            SUM(GrantPrice) AS TotalAmount
        FROM Grants
        GROUP BY GrantCategory
        ORDER BY SUM(GrantPrice) DESC;
    END
    ELSE IF @SortOption = 'category_asc'
    BEGIN
        SELECT 
            GrantCategory,
            SUM(GrantPrice) AS TotalAmount
        FROM Grants
        GROUP BY GrantCategory
        ORDER BY CAST(SUBSTRING(GrantCategory, 2, LEN(GrantCategory)) AS INT) ASC;
    END
    ELSE IF @SortOption = 'category_desc'
    BEGIN
        SELECT 
            GrantCategory,
            SUM(GrantPrice) AS TotalAmount
        FROM Grants
        GROUP BY GrantCategory
        ORDER BY CAST(SUBSTRING(GrantCategory, 2, LEN(GrantCategory)) AS INT) DESC;
    END
END;

CREATE PROCEDURE sp_GetRemainingGrantAmounts
    @SortOption NVARCHAR(50) -- Sorting option: 'remaining_asc', 'remaining_desc', 'category_asc', 'category_desc'
AS
BEGIN
    IF @SortOption = 'remaining_asc'
    BEGIN
        SELECT 
            GrantCategory,
            (SumPrice - ISNULL(SUM(GrantPrice), 0)) AS RemainingAmount
        FROM Grants
        GROUP BY GrantCategory, SumPrice
        ORDER BY (SumPrice - ISNULL(SUM(GrantPrice), 0)) ASC;
    END
    ELSE IF @SortOption = 'remaining_desc'
    BEGIN
        SELECT 
            GrantCategory,
            (SumPrice - ISNULL(SUM(GrantPrice), 0)) AS RemainingAmount
        FROM Grants
        GROUP BY GrantCategory, SumPrice
        ORDER BY (SumPrice - ISNULL(SUM(GrantPrice), 0)) DESC;
    END
    ELSE IF @SortOption = 'category_asc'
    BEGIN
        SELECT 
            GrantCategory,
            (SumPrice - ISNULL(SUM(GrantPrice), 0)) AS RemainingAmount
        FROM Grants
        GROUP BY GrantCategory, SumPrice
        ORDER BY CAST(SUBSTRING(GrantCategory, 2, LEN(GrantCategory)) AS INT) ASC;
    END
    ELSE IF @SortOption = 'category_desc'
    BEGIN
        SELECT 
            GrantCategory,
            (SumPrice - ISNULL(SUM(GrantPrice), 0)) AS RemainingAmount
        FROM Grants
        GROUP BY GrantCategory, SumPrice
        ORDER BY CAST(SUBSTRING(GrantCategory, 2, LEN(GrantCategory)) AS INT) DESC;
    END
END;

CREATE PROCEDURE sp_AnalysisApplicationCount
    @StartDate DATE = NULL,          -- Start date for filtering (NULL for no filter)
    @EndDate DATE = NULL,            -- End date for filtering (NULL for no filter)
    @ApplicationCategories NVARCHAR(MAX) = NULL, -- Comma-separated list of grant categories
    @ApplicantCategory NVARCHAR(50) = NULL      -- Filter by applicant category ('individual', 'legal', or NULL for all)
AS
BEGIN
    SET NOCOUNT ON;

    -- Dynamic SQL to build query
    DECLARE @SQL NVARCHAR(MAX);

    -- Base query
    SET @SQL = N'
        SELECT 
            COUNT(A.ApplicationID) AS ApplicationCount,
            G.GrantCategory AS ApplicationCategory,
            CASE 
                WHEN U.UserID IS NOT NULL THEN ''individual''
                WHEN L.UserID IS NOT NULL THEN ''legal''
                ELSE ''unknown''
            END AS ApplicantType,
            COUNT(CASE WHEN U.UserID IS NOT NULL OR L.UserID IS NOT NULL THEN 1 ELSE NULL END) AS TotalApplicants
        FROM Applications A
        LEFT JOIN Grants G ON A.GrantCategory = G.GrantCategory -- Adjusted join based on likely schema
        LEFT JOIN Users U ON A.UserID = U.UserID -- Join for individual applicants
        LEFT JOIN LegalEntities L ON A.UserID = L.UserID -- Join for legal applicants
        WHERE 1 = 1
    ';

    -- Add time period filter
    IF @StartDate IS NOT NULL AND @EndDate IS NOT NULL
    BEGIN
        SET @SQL += N' AND A.ApplicationDate BETWEEN @StartDate AND @EndDate'; -- Adjusted column name
    END

    -- Add application category filter
    IF @ApplicationCategories IS NOT NULL
    BEGIN
        SET @SQL += N' AND G.GrantCategory IN (SELECT value FROM STRING_SPLIT(@ApplicationCategories, '',''))';
    END

    -- Add applicant category filter
    IF @ApplicantCategory IS NOT NULL
    BEGIN
        SET @SQL += N' AND (
            (@ApplicantCategory = ''individual'' AND U.UserID IS NOT NULL) OR
            (@ApplicantCategory = ''legal'' AND L.UserID IS NOT NULL)
        )';
    END

    -- Group by category and applicant type
    SET @SQL += N'
        GROUP BY G.GrantCategory, 
                 CASE 
                    WHEN U.UserID IS NOT NULL THEN ''individual'' 
                    WHEN L.UserID IS NOT NULL THEN ''legal'' 
                    ELSE ''unknown'' 
                 END
    ';

    -- Execute the dynamically built SQL
    EXEC sp_executesql 
        @SQL,
        N'@StartDate DATE, @EndDate DATE, @ApplicationCategories NVARCHAR(MAX), @ApplicantCategory NVARCHAR(50)',
        @StartDate = @StartDate,
        @EndDate = @EndDate,
        @ApplicationCategories = @ApplicationCategories,
        @ApplicantCategory = @ApplicantCategory;
END;


EXEC sp_AnalysisApplicationCount 
    @StartDate = '2024-01-01',
    @EndDate = '2024-12-31',
    @ApplicationCategories = 'C1,C2',
    @ApplicantCategory = 'individual';

DROP PROCEDURE sp_CompareApplicationTrends;
CREATE PROCEDURE sp_CompareApplicationTrends
    @StartDate DATE = NULL,   -- Start date for filtering (NULL for no filter)
    @EndDate DATE = NULL,     -- End date for filtering (NULL for no filter)
    @UserType NVARCHAR(50) = NULL -- Filter by user type ('individual', 'legal', or NULL for all)
AS
BEGIN
    SET NOCOUNT ON;

    -- Calculate the total number of applications based on the filters
    DECLARE @TotalApplications INT;

    SELECT @TotalApplications = COUNT(*)
    FROM Applications A
    LEFT JOIN Users U ON A.UserID = U.UserID
    LEFT JOIN LegalEntities L ON A.UserID = L.UserID
    WHERE 1 = 1
        AND (@StartDate IS NULL OR A.ApplicationDate >= @StartDate)
        AND (@EndDate IS NULL OR A.ApplicationDate <= @EndDate)
        AND (
            @UserType IS NULL OR 
            (@UserType = 'individual' AND U.UserID IS NOT NULL) OR
            (@UserType = 'legal' AND L.UserID IS NOT NULL)
        );

    -- Select application count and percentage for each grant category
    SELECT 
        A.GrantCategory AS Category, 
        COUNT(A.ApplicationID) AS ApplicationCount,
        (CAST(COUNT(A.ApplicationID) AS FLOAT) / @TotalApplications) * 100 AS PercentageOfTotal
    FROM Applications A
    LEFT JOIN Users U ON A.UserID = U.UserID
    LEFT JOIN LegalEntities L ON A.UserID = L.UserID
    WHERE 1 = 1
        AND (@StartDate IS NULL OR A.ApplicationDate >= @StartDate)
        AND (@EndDate IS NULL OR A.ApplicationDate <= @EndDate)
        AND (
            @UserType IS NULL OR 
            (@UserType = 'individual' AND U.UserID IS NOT NULL) OR
            (@UserType = 'legal' AND L.UserID IS NOT NULL)
        )
    GROUP BY A.GrantCategory
    ORDER BY ApplicationCount DESC;
END;

CREATE PROCEDURE sp_SuccessRateApplications
    @StartDate DATE = NULL,          -- Start date for filtering (NULL for no filter)
    @EndDate DATE = NULL,            -- End date for filtering (NULL for no filter)
    @ApplicationCategories NVARCHAR(MAX) = NULL, -- Comma-separated list of application categories
    @ApplicantCategory NVARCHAR(50) = NULL      -- Filter by applicant category ('individual', 'legal', or NULL for all)
AS
BEGIN
    SET NOCOUNT ON;

    -- Dynamic SQL to build query
    DECLARE @SQL NVARCHAR(MAX);

    -- Base query
    SET @SQL = N'
        SELECT 
            G.GrantCategory AS ApplicationCategory,
            CASE 
                WHEN U.UserID IS NOT NULL THEN ''individual''
                WHEN L.UserID IS NOT NULL THEN ''legal''
                ELSE ''unknown''
            END AS ApplicantType,
            COUNT(CASE WHEN S.Status = ''approved'' THEN 1 END) AS SuccessfulApplications,
            COUNT(A.ApplicationID) AS TotalApplications,
            (CAST(COUNT(CASE WHEN S.Status = ''approved'' THEN 1 END) AS FLOAT) / COUNT(A.ApplicationID)) * 100 AS SuccessRate
        FROM Applications A
        LEFT JOIN Grants G ON A.GrantCategory = G.GrantCategory -- Join for grant categories
        LEFT JOIN Users U ON A.UserID = U.UserID -- Join for individual applicants
        LEFT JOIN LegalEntities L ON A.UserID = L.UserID -- Join for legal applicants
        INNER JOIN StatusHistory S ON A.ApplicationID = S.ApplicationID -- Join for application statuses
        WHERE 1 = 1
    ';

    -- Add time period filter
    IF @StartDate IS NOT NULL AND @EndDate IS NOT NULL
    BEGIN
        SET @SQL += N' AND A.ApplicationDate BETWEEN @StartDate AND @EndDate';
    END

    -- Add application category filter
    IF @ApplicationCategories IS NOT NULL
    BEGIN
        SET @SQL += N' AND G.GrantCategory IN (SELECT value FROM STRING_SPLIT(@ApplicationCategories, '',''))';
    END

    -- Add applicant category filter
    IF @ApplicantCategory IS NOT NULL
    BEGIN
        SET @SQL += N' AND (
            (@ApplicantCategory = ''individual'' AND U.UserID IS NOT NULL) OR
            (@ApplicantCategory = ''legal'' AND L.UserID IS NOT NULL)
        )';
    END

    -- Group by category and applicant type
    SET @SQL += N'
        GROUP BY G.GrantCategory, U.UserID, L.UserID
    ';

    -- Execute the dynamically built SQL
    EXEC sp_executesql 
        @SQL,
        N'@StartDate DATE, @EndDate DATE, @ApplicationCategories NVARCHAR(MAX), @ApplicantCategory NVARCHAR(50)',
        @StartDate = @StartDate,
        @EndDate = @EndDate,
        @ApplicationCategories = @ApplicationCategories,
        @ApplicantCategory = @ApplicantCategory;
END;

DROP PROCEDURE sp_SuccessRateApplications;
EXEC sp_SuccessRateApplications;

EXEC sp_SuccessRateApplications 
    @StartDate = '2024-01-01',
    @EndDate = '2024-12-31',
    @ApplicationCategories = 'C4,C7',
    @ApplicantCategory = 'individual';


CREATE PROCEDURE sp_HighActivityPeriods
    @TimePeriod NVARCHAR(20) -- Possible values: 'daily', 'weekly', 'monthly', 'yearly'
AS
BEGIN
    SET NOCOUNT ON;

    -- Base query logic
    IF @TimePeriod = 'daily'
    BEGIN
        SELECT 
            CAST(A.ApplicationDate AS DATE) AS Period,
            COUNT(A.ApplicationID) AS ApplicationCount
        FROM Applications A
        GROUP BY CAST(A.ApplicationDate AS DATE)
        ORDER BY ApplicationCount DESC;
    END
    ELSE IF @TimePeriod = 'weekly'
    BEGIN
        SELECT 
            DATEPART(YEAR, A.ApplicationDate) AS Year,
            DATEPART(WEEK, A.ApplicationDate) AS Week,
            COUNT(A.ApplicationID) AS ApplicationCount
        FROM Applications A
        GROUP BY DATEPART(YEAR, A.ApplicationDate), DATEPART(WEEK, A.ApplicationDate)
        ORDER BY ApplicationCount DESC;
    END
    ELSE IF @TimePeriod = 'monthly'
    BEGIN
        SELECT 
            DATEPART(YEAR, A.ApplicationDate) AS Year,
            DATEPART(MONTH, A.ApplicationDate) AS Month,
            COUNT(A.ApplicationID) AS ApplicationCount
        FROM Applications A
        GROUP BY DATEPART(YEAR, A.ApplicationDate), DATEPART(MONTH, A.ApplicationDate)
        ORDER BY ApplicationCount DESC;
    END
    ELSE IF @TimePeriod = 'yearly'
    BEGIN
        SELECT 
            DATEPART(YEAR, A.ApplicationDate) AS Year,
            COUNT(A.ApplicationID) AS ApplicationCount
        FROM Applications A
        GROUP BY DATEPART(YEAR, A.ApplicationDate)
        ORDER BY ApplicationCount DESC;
    END
    ELSE
    BEGIN
        THROW 50000, 'Invalid time period specified.', 1;
    END
END;

EXEC sp_HighActivityPeriods @TimePeriod = 'weekly';
EXEC sp_HighActivityPeriods @TimePeriod = 'monthly';
CREATE PROCEDURE sp_AverageGrantAmount
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @ApplicationCategories NVARCHAR(MAX) = NULL,
    @ApplicantCategory NVARCHAR(20) = NULL
AS
BEGIN
    SELECT 
        a.GrantCategory AS ApplicationCategory,
        AVG(g.GrantPrice) AS AverageGrantAmount
    FROM Applications a
    INNER JOIN Grants g ON a.GrantCategory = g.GrantCategory
    WHERE 
        (a.ApplicationDate >= @StartDate OR @StartDate IS NULL)
        AND (a.ApplicationDate <= @EndDate OR @EndDate IS NULL)
        AND (CHARINDEX(a.GrantCategory, @ApplicationCategories) > 0 OR @ApplicationCategories IS NULL)
        AND (a.UserType = @ApplicantCategory OR @ApplicantCategory IS NULL)
    GROUP BY a.GrantCategory;
END;

-- Test with no filters
EXEC sp_AverageGrantAmount NULL, NULL, NULL, NULL;

-- Test with a specific date range
EXEC sp_AverageGrantAmount '2024-01-01', '2024-12-31', NULL, NULL;

-- Test with specific categories
EXEC sp_AverageGrantAmount NULL, NULL, 'C1,C2,C3', 'individual';

-- Test with both date range and applicant category
EXEC sp_AverageGrantAmount '2024-01-01', '2024-12-31', NULL, 'individual';


CREATE PROCEDURE sp_ExtremeGrantCategories
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @ApplicationCategories NVARCHAR(MAX) = NULL,
    @ApplicantCategory NVARCHAR(20) = NULL
AS
BEGIN
    WITH GrantStats AS (
        SELECT 
            a.GrantCategory AS Category,
            SUM(g.GrantPrice) AS TotalGrantAmount
        FROM Applications a
        INNER JOIN Grants g ON a.GrantCategory = g.GrantCategory
        WHERE 
            (a.ApplicationDate >= @StartDate OR @StartDate IS NULL)
            AND (a.ApplicationDate <= @EndDate OR @EndDate IS NULL)
            AND (CHARINDEX(a.GrantCategory, @ApplicationCategories) > 0 OR @ApplicationCategories IS NULL)
            AND (a.UserType = @ApplicantCategory OR @ApplicantCategory IS NULL)
        GROUP BY a.GrantCategory
    )
    SELECT 
        Category,
        TotalGrantAmount,
        CASE 
            WHEN TotalGrantAmount = (SELECT MAX(TotalGrantAmount) FROM GrantStats) THEN 'Highest'
            WHEN TotalGrantAmount = (SELECT MIN(TotalGrantAmount) FROM GrantStats) THEN 'Lowest'
        END AS GrantLevel
    FROM GrantStats
    WHERE TotalGrantAmount = (SELECT MAX(TotalGrantAmount) FROM GrantStats)
       OR TotalGrantAmount = (SELECT MIN(TotalGrantAmount) FROM GrantStats);
END;

CREATE PROCEDURE sp_LegalEntitiesByCategory
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @ApplicationCategories NVARCHAR(MAX) = NULL
AS
BEGIN
    -- Legal entities that applied and had at least one successful application
    SELECT 
        le.CompanyName AS LegalEntity, -- CompanyName from LegalEntities
        a.GrantCategory AS ApplicationCategory,
        COUNT(*) AS SuccessfulApplications
    FROM Applications a
    INNER JOIN LegalEntities le ON a.UserID = le.UserID -- Linking Applications to LegalEntities
    INNER JOIN Grants g ON a.GrantCategory = g.GrantCategory -- Linking Applications to Grants
    WHERE 
        a.UserType = 'legal_entity'
        AND (a.ApplicationDate >= @StartDate OR @StartDate IS NULL)
        AND (a.ApplicationDate <= @EndDate OR @EndDate IS NULL)
        AND (CHARINDEX(a.GrantCategory, @ApplicationCategories) > 0 OR @ApplicationCategories IS NULL)
    GROUP BY le.CompanyName, a.GrantCategory

    UNION

    -- Legal entities that applied but had no successful applications
    SELECT 
        le.CompanyName AS LegalEntity,
        a.GrantCategory AS ApplicationCategory,
        0 AS SuccessfulApplications
    FROM Applications a
    INNER JOIN LegalEntities le ON a.UserID = le.UserID
    WHERE 
        a.UserType = 'legal_entity'
        AND (a.ApplicationDate >= @StartDate OR @StartDate IS NULL)
        AND (a.ApplicationDate <= @EndDate OR @EndDate IS NULL)
        AND (CHARINDEX(a.GrantCategory, @ApplicationCategories) > 0 OR @ApplicationCategories IS NULL)
        AND NOT EXISTS (
            SELECT 1 
            FROM Grants g
            WHERE g.GrantCategory = a.GrantCategory
        )
    GROUP BY le.CompanyName, a.GrantCategory;
END;

EXEC sp_LegalEntitiesByCategory ;
CREATE PROCEDURE sp_CategoriesWithMonthlyApplications
AS
BEGIN
    -- Define the current date and start date for the last four months
    DECLARE @CurrentDate DATE = GETDATE();
    DECLARE @StartDate DATE = DATEADD(MONTH, -4, @CurrentDate);

    -- Select categories with applications in all four months
    SELECT 
        a.GrantCategory AS ApplicationCategory,
        COUNT(DISTINCT MONTH(a.ApplicationDate)) AS MonthsWithApplications
    FROM Applications a
    WHERE 
        a.ApplicationDate BETWEEN @StartDate AND @CurrentDate
    GROUP BY a.GrantCategory
    HAVING COUNT(DISTINCT MONTH(a.ApplicationDate)) = 4; -- Ensure all 4 months have applications
END;

EXEC sp_CategoriesWithMonthlyApplications;
CREATE PROCEDURE sp_CategoriesWithAtLeastXApplications
    @Year INT,               -- Year for filtering applications
    @MinApplications INT     -- Minimum number of applications
AS
BEGIN
    -- Select categories with at least X applications in the given year
    SELECT 
        a.GrantCategory AS ApplicationCategory, -- Use GrantCategory as the correct column
        COUNT(*) AS ApplicationsCount
    FROM Applications a
    WHERE 
        YEAR(a.ApplicationDate) = @Year       -- Filter by the given year
    GROUP BY a.GrantCategory                  -- Group by category
    HAVING COUNT(*) >= @MinApplications;      -- Ensure at least X applications
END;
EXEC sp_CategoriesWithAtLeastXApplications @Year = 2023, @MinApplications = 10;
