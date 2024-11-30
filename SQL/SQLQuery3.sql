CREATE PROCEDURE PopulateCriteria AS
BEGIN
    INSERT INTO Criteria (Description, Category)
    VALUES
        -- General Eligibility Criteria
        ('Applicant must be a natural person or legal entity.', 'General Eligibility'),
        ('The applicant must be the registered owner of the vehicle before the application.', 'General Eligibility'),
        ('The vehicle to be withdrawn must have its registration canceled.', 'General Eligibility'),
        ('Written consent from co-owners must be obtained in case of co-ownership or financing.', 'General Eligibility'),
        ('The vehicle must belong to category M1 (passenger cars) or N1 (goods vehicles).', 'General Eligibility'),

        -- Specific Vehicle Criteria
        ('New vehicles must have a Certificate of Conformity (EC).', 'Specific Vehicle'),
        ('For category N1 vehicles, European Type Approval is required.', 'Specific Vehicle'),
        ('Vehicles with CO2 emissions ≤ 50 g/km are eligible.', 'Specific Vehicle'),
        ('Used vehicles must have a valid license at the time of application.', 'Specific Vehicle'),
        ('Used vehicles must be registered in the country for at least 7 continuous years.', 'Specific Vehicle'),
        ('Used vehicles must not have had their registration canceled at the time of the application.', 'Specific Vehicle'),
        ('Electric bicycles must comply with safety standards (CYS EN 15194).', 'Specific Vehicle'),
        ('Electric bicycles must have been purchased from an authorized seller in the Republic of Cyprus.', 'Specific Vehicle'),

        -- Financial and Procedural Criteria
        ('The purchase price of the new vehicle (including VAT) must not exceed €80,000.', 'Financial/Procedural'),
        ('Proof of ownership must be submitted with the application.', 'Financial/Procedural'),
        ('Purchase invoice or down-payment receipt must be submitted.', 'Financial/Procedural'),
        ('Transfer of ownership is prohibited for 2 years from the date of registration (categories G10–G14).', 'Financial/Procedural'),

		-- Environmental Criteria
		('Vehicles must meet specific noise level requirements.', 'Environmental'),
		('Electric vehicle batteries must have a warranty of at least 8 years or 160,000 km.', 'Environmental'),

		-- Owner Obligations
		('The applicant must agree to use the vehicle exclusively for its intended purpose.', 'Owner Obligations'),

		-- Legal Compliance
		('Vehicles must comply with all local traffic and safety regulations.', 'Legal Compliance');
END;

EXEC PopulateCriteria;

CREATE PROCEDURE LinkCriteriaToGrant
    @GrantID INT, -- The GrantID to link criteria to
    @CriteriaIDs NVARCHAR(MAX) -- A comma-separated list of CriteriaIDs (e.g., '1,3,5')
AS
BEGIN
    DECLARE @CriteriaID INT;
    DECLARE @SQL NVARCHAR(MAX);
    
    -- Split the CriteriaIDs and insert them into the GrantCriteria table
    DECLARE criteria_cursor CURSOR FOR
        SELECT value FROM STRING_SPLIT(@CriteriaIDs, ',');
    
    OPEN criteria_cursor;
    FETCH NEXT FROM criteria_cursor INTO @CriteriaID;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Insert each Criterion into the GrantCriteria table
        INSERT INTO GrantCriteria (GrantID, CriteriaID)
        VALUES (@GrantID, @CriteriaID);

        FETCH NEXT FROM criteria_cursor INTO @CriteriaID;
    END
    
    CLOSE criteria_cursor;
    DEALLOCATE criteria_cursor;
END;

-- Link Criteria to Grant C1 (EV Grant for Private Use)
EXEC LinkCriteriaToGrant @GrantID = 1, @CriteriaIDs = '1, 2, 5, 6, 8, 14';
-- Link Criteria to Grant C2 (EV Grant for Taxi)
EXEC LinkCriteriaToGrant @GrantID = 2, @CriteriaIDs = '1, 2, 5, 6, 8, 14';
-- Link Criteria to Grant C3 (EV Grant for Disabled)
EXEC LinkCriteriaToGrant @GrantID = 3, @CriteriaIDs = '1, 2, 5, 6, 8, 14';
-- Link Criteria to Grant C4 (EV Grant for Large Families)
EXEC LinkCriteriaToGrant @GrantID = 4, @CriteriaIDs = '1, 2, 5, 6, 8, 14';
-- Link Criteria to Grant C5 (Zero Emissions Vehicle Grant for Private Use)
EXEC LinkCriteriaToGrant @GrantID = 5, @CriteriaIDs = '1, 5, 6, 12, 13, 14';
-- Link Criteria to Grant C6 (Zero Emissions Vehicle Grant for Taxi)
EXEC LinkCriteriaToGrant @GrantID = 6, @CriteriaIDs = '1, 5, 6, 12, 13, 14';
-- Link Criteria to Grant C7 (Zero Emissions Vehicle Grant for Disabled)
EXEC LinkCriteriaToGrant @GrantID = 7, @CriteriaIDs = '1, 5, 6, 12, 13, 14';
-- Link Criteria to Grant C8 (Zero Emissions Vehicle Grant for Large Families)
EXEC LinkCriteriaToGrant @GrantID = 8, @CriteriaIDs = '1, 5, 6, 12, 13, 14';
-- Link Criteria to Grant C10 (Zero Emissions Electric Vehicle Grant for Commercial Use N1 Category)
EXEC LinkCriteriaToGrant @GrantID = 10, @CriteriaIDs = '1, 5, 6, 12, 13, 14';
-- Link Criteria to Grant C11 (Electric Vehicle Grant for N2 Commercial Vehicles)
EXEC LinkCriteriaToGrant @GrantID = 11, @CriteriaIDs = '1, 5, 6, 12, 14';
-- Link Criteria to Grant C12 (Electric Vehicle Grant for M2 Category Vehicles)
EXEC LinkCriteriaToGrant @GrantID = 12, @CriteriaIDs = '1, 5, 6, 12, 14';
-- Link Criteria to Grant C13 (Electric Vehicle Grant for L6e and L7e Categories)
EXEC LinkCriteriaToGrant @GrantID = 13, @CriteriaIDs = '1, 5, 6, 12, 14';
-- Link Criteria to Grant C14 (Electric Vehicle Grant for Other Vehicles)
EXEC LinkCriteriaToGrant @GrantID = 14, @CriteriaIDs = '1, 5, 6, 12, 14';


CREATE PROCEDURE GetCriteriaForGrant
    @GrantID INT
AS
BEGIN
    -- Fetch criteria for the given GrantID
    SELECT c.CriteriaID, c.Description, c.Category
    FROM Criteria c
    JOIN GrantCriteria gc ON c.CriteriaID = gc.CriteriaID
    WHERE gc.GrantID = @GrantID;
END;


CREATE PROCEDURE InsertDocument
    @FileName NVARCHAR(255),
    @CriteriaID INT,  -- Ensure this is INT if CriteriaID is INT in the Criteria table
    @FilePath NVARCHAR(255)
AS
BEGIN
    INSERT INTO Documents (FileName, CriteriaID, FilePath)
    VALUES (@FileName, @CriteriaID, @FilePath);
END;

EXEC sp_columns Criteria;
EXEC sp_columns Documents;


