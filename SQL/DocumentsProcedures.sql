CREATE PROCEDURE UploadDocument
    @ApplicationID NVARCHAR(20),
    @FileName NVARCHAR(255),
    @FilePath NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    -- Insert the document details into the Documents table
    INSERT INTO Documents (ApplicationID, FileName, FilePath)
    VALUES (@ApplicationID, @FileName, @FilePath);
END;

DROP PROCEDURE UploadDocument;