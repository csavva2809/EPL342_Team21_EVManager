CREATE PROCEDURE AddOrder
    @ApplicationID NVARCHAR(20),
    @VehicleID INT,
    @ExpectedRegisterDate CHAR(15),
    @FileName NVARCHAR(255),
    @FilePath NVARCHAR(255),
    @Size INT,
    @DocType NVARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DocumentID INT; -- To store the DocumentID after UploadDocument execution

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Step 1: Call the UploadDocument procedure
        EXEC UploadDocument @ApplicationID, @FileName, @FilePath, @Size, @DocType;

        -- Step 2: Retrieve the DocumentID from the Documents table
        SELECT @DocumentID = DocumentID
        FROM Documents
        WHERE ApplicationID = @ApplicationID
          AND FileName = @FileName
          AND FilePath = @FilePath
          AND Size = @Size
          AND DocType = @DocType;

        -- Step 3: Insert all data into the Orders table
        INSERT INTO Orders (ApplicationID, VehicleID, DocumentID, ExpectedRegisterDate)
        VALUES (@ApplicationID, @VehicleID, @DocumentID, @ExpectedRegisterDate);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        -- Re-throw the error for debugging purposes
        THROW;
    END CATCH
END;

DROP PROCEDURE AddOrder;

DROP PROCEDURE GetOrderAndJustificationDocuments;

CREATE PROCEDURE GetGroupedOrderAndSupportiveDocuments
AS
BEGIN
    SELECT 
        d.ApplicationID,
        STRING_AGG(CAST(d.DocumentID AS NVARCHAR(MAX)), ', ') AS DocumentIDs,
        STRING_AGG(d.FileName, ', ') AS FileNames,
        STRING_AGG(d.FilePath, ', ') AS FilePaths,
        STRING_AGG(d.DocType, ', ') AS DocTypes,
        STRING_AGG(CAST(o.OrderID AS NVARCHAR(MAX)), ', ') AS OrderIDs,
        STRING_AGG(CAST(o.VehicleID AS NVARCHAR(MAX)), ', ') AS VehicleIDs,
        STRING_AGG(o.ExpectedRegisterDate, ', ') AS ExpectedRegisterDates
    FROM Documents d
    LEFT JOIN Orders o ON d.DocumentID = o.DocumentID
    GROUP BY d.ApplicationID
    ORDER BY d.ApplicationID;
END;
