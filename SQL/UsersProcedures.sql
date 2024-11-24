CREATE PROCEDURE GetUseDetails
	@UserName NVARCHAR(25),
	@PersonID NVARCHAR(20) OUTPUT,
	@Role NVARCHAR(10) OUTPUT
AS
BEGIN
	SELECT
		@PersonID = PersonID,
		@Role = Role
	FROM Users
	WHERE UserName = @UserName;
END;
