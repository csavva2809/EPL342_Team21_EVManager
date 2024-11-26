CREATE PROCEDURE AddGrant
    @GrantCategory VARCHAR(5),
    @Description NVARCHAR(255),
    @GrantPrice FLOAT,
    @SumPrice FLOAT,
    @AvailableGrants INT,
    @Success BIT OUTPUT,
    @Message NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validate GrantPrice
        IF @GrantPrice <= 0
        BEGIN
            SET @Success = 0;
            SET @Message = 'GrantPrice must be greater than 0.';
            RETURN;
        END;

        -- Validate SumPrice
        IF @SumPrice <= 0 OR @SumPrice < @GrantPrice
        BEGIN
            SET @Success = 0;
            SET @Message = 'SumPrice must be greater than 0 and greater than or equal to GrantPrice.';
            RETURN;
        END;

        -- Validate AvailableGrants
        IF @AvailableGrants < 0
        BEGIN
            SET @Success = 0;
            SET @Message = 'AvailableGrants cannot be negative.';
            RETURN;
        END;

        -- Validate GrantCategory (optional, if not enforced via table constraint)
        IF @GrantCategory NOT IN ('C1', 'C2', 'C3', 'C4', 'C5', 'C6', 'C7', 'C8', 'C9', 'C10', 'C11', 'C12', 'C13', 'C14', 'C15', 'C16')
        BEGIN
            SET @Success = 0;
            SET @Message = 'Invalid GrantCategory.';
            RETURN;
        END;

        -- Insert the record into the Grant table
        INSERT INTO Grants (GrantCategory, Description, GrantPrice, SumPrice, AvailableGrants)
        VALUES (@GrantCategory, @Description, @GrantPrice, @SumPrice, @AvailableGrants);

        -- Set success and message
        SET @Success = 1;
        SET @Message = 'Grant record added successfully.';
    END TRY
    BEGIN CATCH
        -- Handle any unexpected errors
        SET @Success = 0;
        SET @Message = ERROR_MESSAGE();
    END CATCH;
END;

DECLARE @Success BIT;
DECLARE @Message NVARCHAR(255);

-- Row 1: Γ1
EXEC AddGrant
    @GrantCategory = 'C1',
    @Description = N'Απόσυρση και αντικατάσταση με καινούργιο όχημα ιδιωτικής χρήσης χαμηλών εκπομπών CO2 (μέχρι 50 γρ/χλμ)',
    @GrantPrice = 7500,
    @SumPrice = 9210000,
    @AvailableGrants = 1228,
    @Success = @Success OUTPUT,
    @Message = @Message OUTPUT;

PRINT 'Success: ' + CAST(@Success AS NVARCHAR);
PRINT 'Message: ' + @Message;
-- Row 2: Γ2
EXEC AddGrant
    @GrantCategory = 'C2',
    @Description = N'Απόσυρση και αντικατάσταση με καινούργιο όχημα ταξί χαμηλών εκπομπών CO2 (μέχρι 50 γρ/χλμ)',
    @GrantPrice = 12000,
    @SumPrice = 360000,
    @AvailableGrants = 30,
    @Success = @Success OUTPUT,
    @Message = @Message OUTPUT;

PRINT 'Success: ' + CAST(@Success AS NVARCHAR);
PRINT 'Message: ' + @Message;

-- Row 3: Γ3
EXEC AddGrant
    @GrantCategory = 'C3',
    @Description = N'Απόσυρση και αντικατάσταση με καινούργιο όχημα χαμηλών εκπομπών CO2 για δικαιούχο αναπηρικού οχήματος',
    @GrantPrice = 15000,
    @SumPrice = 450000,
    @AvailableGrants = 30,
    @Success = @Success OUTPUT,
    @Message = @Message OUTPUT;

PRINT 'Success: ' + CAST(@Success AS NVARCHAR);
PRINT 'Message: ' + @Message;

-- Row 4: Γ4
EXEC AddGrant
    @GrantCategory = 'C4',
    @Description = N'Απόσυρση και αντικατάσταση με καινούργιο όχημα χαμηλών εκπομπών CO2 πολύτεκνης οικογένειας',
    @GrantPrice = 15000,
    @SumPrice = 450000,
    @AvailableGrants = 30,
    @Success = @Success OUTPUT,
    @Message = @Message OUTPUT;

PRINT 'Success: ' + CAST(@Success AS NVARCHAR);
PRINT 'Message: ' + @Message;

-- Row 5: Γ5
EXEC AddGrant
    @GrantCategory = 'C5',
    @Description = N'Χορηγία για αγορά καινούργιου οχήματος ιδιωτικής χρήσης μηδενικών εκπομπών CO2',
    @GrantPrice = 9000,
    @SumPrice = 16443000,
    @AvailableGrants = 1827,
    @Success = @Success OUTPUT,
    @Message = @Message OUTPUT;

PRINT 'Success: ' + CAST(@Success AS NVARCHAR);
PRINT 'Message: ' + @Message;

-- Row 6: Γ6
EXEC AddGrant
    @GrantCategory = 'C6',
    @Description = N'Χορηγία για αγορά καινούργιου οχήματος ταξί μηδενικών εκπομπών CO2',
    @GrantPrice = 20000,
    @SumPrice = 1200000,
    @AvailableGrants = 60,
    @Success = @Success OUTPUT,
    @Message = @Message OUTPUT;

PRINT 'Success: ' + CAST(@Success AS NVARCHAR);
PRINT 'Message: ' + @Message;

-- Row 7: Γ7
EXEC AddGrant
    @GrantCategory = 'C7',
    @Description = N'Χορηγία για αγορά καινούργιου οχήματος μηδενικών εκπομπών CO2 για δικαιούχο αναπηρικού οχήματος',
    @GrantPrice = 20000,
    @SumPrice = 1200000,
    @AvailableGrants = 60,
    @Success = @Success OUTPUT,
    @Message = @Message OUTPUT;

PRINT 'Success: ' + CAST(@Success AS NVARCHAR);
PRINT 'Message: ' + @Message;

-- Row 8: Γ8
EXEC AddGrant
    @GrantCategory = 'C8',
    @Description = N'Χορηγία για αγορά καινούργιου οχήματος μηδενικών εκπομπών CO2 πολύτεκνης οικογένειας',
    @GrantPrice = 20000,
    @SumPrice = 1200000,
    @AvailableGrants = 60,
    @Success = @Success OUTPUT,
    @Message = @Message OUTPUT;

PRINT 'Success: ' + CAST(@Success AS NVARCHAR);
PRINT 'Message: ' + @Message;
-- Row 1: Γ10
EXEC AddGrant
    @GrantCategory = 'C10',
    @Description = N'Χορηγία για αγορά καινούργιου ηλεκτρικού οχήματος κατηγορίας Ν1 (εμπορικό μικτού βάρους μέχρι 3.500 κιλά) μηδενικών εκπομπών CO2',
    @GrantPrice = 15000,
    @SumPrice = 2775000,
    @AvailableGrants = 185,
    @Success = @Success OUTPUT,
    @Message = @Message OUTPUT;

PRINT 'Success: ' + CAST(@Success AS NVARCHAR);
PRINT 'Message: ' + @Message;

-- Row 2: Γ11
EXEC AddGrant
    @GrantCategory = 'C11',
    @Description = N'Χορηγία για αγορά καινούργιου ηλεκτρικού οχήματος κατηγορίας Ν2 (εμπορικό μικτού βάρους που υπερβαίνει τα 3.500 κιλά αλλά δεν υπερβαίνει τα 12.000 κιλά) μηδενικών εκπομπών CO2',
    @GrantPrice = 25000,
    @SumPrice = 100000,
    @AvailableGrants = 4,
    @Success = @Success OUTPUT,
    @Message = @Message OUTPUT;

PRINT 'Success: ' + CAST(@Success AS NVARCHAR);
PRINT 'Message: ' + @Message;

-- Row 3: Γ12
EXEC AddGrant
    @GrantCategory = 'C12',
    @Description = N'Χορηγία για αγορά καινούργιου οχήματος κατηγορίας M2 μηδενικών εκπομπών CO2 (μικρό λεωφορείο το οποίο περιλαμβάνει περισσότερες από οκτώ θέσεις καθημένων πέραν του καθίσματος του οδηγού και έχει μέγιστη μάζα το πολύ 5 τόνους)',
    @GrantPrice = 40000,
    @SumPrice = 80000,
    @AvailableGrants = 2,
    @Success = @Success OUTPUT,
    @Message = @Message OUTPUT;

PRINT 'Success: ' + CAST(@Success AS NVARCHAR);
PRINT 'Message: ' + @Message;

-- Row 4: Γ13
EXEC AddGrant
    @GrantCategory = 'C13',
    @Description = N'Χορηγία για αγορά καινούργιου οχήματος μηδενικών εκπομπών CO2 κατηγορίας L6e (υποκατηγορία «Β») και L7e (υποκατηγορία «C»)(1), (2)',
    @GrantPrice = 4000,
    @SumPrice = 260000,
    @AvailableGrants = 65,
    @Success = @Success OUTPUT,
    @Message = @Message OUTPUT;

PRINT 'Success: ' + CAST(@Success AS NVARCHAR);
PRINT 'Message: ' + @Message;

-- Row 5: Γ14
EXEC AddGrant
    @GrantCategory = 'C14',
    @Description = N'Χορηγία για αγορά καινούργιου οχήματος μηδενικών εκπομπών CO2 κατηγορίας L (εξαιρουμένων των οχημάτων κατηγορίας L6e (υποκατηγορία «Β») και L7e (υποκατηγορία «Β και C»))(1), (2)',
    @GrantPrice = 1500,
    @SumPrice = 1339500,
    @AvailableGrants = 893,
    @Success = @Success OUTPUT,
    @Message = @Message OUTPUT;

PRINT 'Success: ' + CAST(@Success AS NVARCHAR);
PRINT 'Message: ' + @Message;


CREATE PROCEDURE DisplayGrant
AS
BEGIN
    SET NOCOUNT ON;

    -- Select all columns from the Grant table
    SELECT 
        GrantID,
        GrantCategory,
        Description,
        GrantPrice,
		AvailableGrants
    FROM Grants;
END;

EXEC DisplayGrant;

DROP PROCEDURE DisplayGrant;
