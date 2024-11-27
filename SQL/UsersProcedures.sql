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
