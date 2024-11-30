CREATE PROCEDURE GetUserDetails
	@UserName NVARCHAR(25),
	@UserID INT OUTPUT,
	@Role NVARCHAR(10) OUTPUT
AS
BEGIN
	SELECT
		@UserID = UserID,
		@Role = Role
	FROM Users
	WHERE UserName = @UserName;
END;

CREATE PROCEDURE GetLegalEntityDetails
    @Email NVARCHAR(40),
    @UserID INT OUTPUT,
    @CompanyName NVARCHAR(100) OUTPUT
AS
BEGIN
    SELECT
        @UserID = UserID,
        @CompanyName = CompanyName
    FROM LegalEntities
    WHERE Email = @Email;
END;
