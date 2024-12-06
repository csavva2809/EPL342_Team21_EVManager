-- Users Table
CREATE NONCLUSTERED INDEX IX_Users_Role ON Users(Role);

-- Applications Table
CREATE NONCLUSTERED INDEX IX_Applications_ApplicationDate ON Applications(ApplicationDate);

-- Grants Table
CREATE NONCLUSTERED INDEX IX_Grants_GrantCategory ON Grants(GrantCategory);

-- LegalEntities Table
CREATE NONCLUSTERED INDEX IX_LegalEntities_UserID ON LegalEntities(UserID);
