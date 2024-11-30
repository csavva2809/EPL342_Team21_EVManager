CREATE PROCEDURE UploadDocument
    @ApplicationID NVARCHAR(20),
    @FileName NVARCHAR(255),
    @FilePath NVARCHAR(255),
    @Size INT, -- Add Size parameter
    @Status NVARCHAR(50) OUTPUT -- Add OUTPUT parameter for status
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Insert the document details into the Documents table
        INSERT INTO Documents (ApplicationID, FileName, FilePath, Size)
        VALUES (@ApplicationID, @FileName, @FilePath, @Size);

        SET @Status = 'Success'; -- Indicate success
    END TRY
    BEGIN CATCH
        -- Handle errors and set failure status
        SET @Status = ERROR_MESSAGE();
    END CATCH
END;

DROP PROCEDURE UploadDocument;