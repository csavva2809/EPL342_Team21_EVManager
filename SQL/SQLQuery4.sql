SELECT TOP (1000) [ApplicationID]
      ,[UserID]
      ,[UserType]
      ,[GrantCategory]
      ,[VehicleType]
      ,[WithdrawalVehicleID]
      ,[ApplicationDate]
      ,[ExpirationDate]
      ,[Email]
  FROM [ksavva05].[ksavva05].[Applications]
  -- Syntax to drop a unique constraint
ALTER TABLE Applications
DROP CONSTRAINT UQ__Applicat__8AA43E296A44B6DC;
