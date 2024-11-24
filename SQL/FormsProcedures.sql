CREATE PROCEDURE GetForms
AS
BEGIN
    -- Select all forms from the Forms table
    SELECT FormID, FormName, Description, Path
    FROM Forms;
END;

