CREATE PROCEDURE AddVehicle
    @Maker NVARCHAR(25),
    @Model NVARCHAR(25),
    @CO2 FLOAT,
    @Price INT,
    @Success INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Attempt to insert the vehicle into the Vehicles table
        INSERT INTO Vehicles (Maker, Model, CO2grPerKm, Price)
        VALUES (@Maker, @Model, @CO2, @Price);

        -- If the INSERT succeeds, set the success flag to 1
        SET @Success = 1;
    END TRY
    BEGIN CATCH
        -- If an error occurs, capture it and set the success flag to 0
        SET @Success = 0;

        -- Optionally, re-throw the error to display the actual error message
        THROW;
    END CATCH
END;


CREATE PROCEDURE ViewVehicle
AS
BEGIN
    SELECT *
	FROM Vehicles
END;

EXEC ViewVehicle;

DROP PROCEDURE AddVehicle;