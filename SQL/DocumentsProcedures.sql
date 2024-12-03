CREATE PROCEDURE UploadDocument
    @ApplicationID NVARCHAR(20),
    @FileName NVARCHAR(255),
    @FilePath NVARCHAR(255),
    @Size INT,
    @DocType NVARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Insert Document
        INSERT INTO Documents (ApplicationID, FileName, FilePath, Size, DocType)
        VALUES (@ApplicationID, @FileName, @FilePath, @Size, @DocType);
    END TRY
    BEGIN CATCH
        -- Capture the error and re-throw
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;



DROP PROCEDURE UploadDocument;
