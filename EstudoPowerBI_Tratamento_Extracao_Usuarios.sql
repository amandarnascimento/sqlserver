-----Extração Usuários
DROP TABLE IF EXISTS DM.powerbi.DimUsers;

SELECT
    identity(int, 1, 1)                               AS Sk_Users,
    AD.*,
    IIF(EXISTS(SELECT TOP 1 1 FROM [powerbi].[DimUsers_Pro] P WHERE TRIM(LOWER([Nome UPN])) = AD.Email), 'Pro',
    IIF(EXISTS(
            SELECT TOP 1 1
            FROM (SELECT DISTINCT TRIM(REPLACE(U.Linha, 'UserPrincipalName :', '')) AS UserPrincipalName
                  FROM powerbi.PowerBI_Workspace U
                  WHERE U.Linha LIKE '%UserPrincipalName :%'
            ) AS TB
            WHERE TB.UserPrincipalName = AD.Email), 'Gratuita', 'Sem Licença')) AS LicencaPowerBI
INTO DM.powerbi.DimUsers
FROM (
SELECT
    [Nome], [Sobrenome], [Nome para exibição] AS NomeCompleto, [Bloquear credencial] AS BloquearCredencial, [Departamento],
    TRIM(LOWER([Nome UPN])) AS Email, [Título] AS Cargo, [Licenças] AS [Licencas]
FROM powerbi.Users_E3
UNION
SELECT
    [Nome], [Sobrenome], [Nome para exibição] AS NomeCompleto, [Bloquear credencial] AS BloquearCredencial, [Departamento],
    TRIM(LOWER([Nome UPN])) AS Email, [Título] AS Cargo, [Licenças] AS [Licencas]
FROM powerbi.Users_E5
UNION
SELECT
    [Nome], [Sobrenome], [Nome para exibição] AS NomeCompleto, [Bloquear credencial] AS BloquearCredencial, [Departamento],
    TRIM(LOWER([Nome UPN])) AS Email, [Título] AS Cargo, [Licenças] AS [Licencas]
FROM powerbi.Users_F3
--2631
UNION
SELECT
    [Nome], [Sobrenome], [Nome para exibição] AS NomeCompleto, [Bloquear credencial] AS BloquearCredencial, [Departamento],
    TRIM(LOWER([Nome UPN])) AS Email, [Título] AS Cargo, [Licenças] AS [Licencas]
FROM powerbi.[DimUsers_Pro]
) AS AD;
GO

SELECT * FROM DM.powerbi.DimUsers WHERE LicencaPowerBI = 'Pro' AND BloquearCredencial = 'False';

ALTER TABLE DM.powerbi.DimUsers ADD CONSTRAINT [PK_DimUsers] PRIMARY KEY CLUSTERED 
(
	Sk_Users ASC
);
GO


SELECT *
FROM (SELECT DISTINCT TRIM(REPLACE(U.Linha, 'UserPrincipalName :', '')) AS UserPrincipalName
        FROM powerbi.PowerBI_Workspace U
        WHERE U.Linha LIKE '%UserPrincipalName :%'
) AS TB
WHERE NOT EXISTS(SELECT 1 FROM DM.powerbi.DimUsers U WHERE U.Email = TB.UserPrincipalName);

/*
SELECT
    identity(int, 1, 1)                               AS Sk_WorkspaceUser,
    UserPrincipalName
INTO powerbi.DimUsers
FROM(
    SELECT DISTINCT
        TRIM(REPLACE(U.Linha, 'UserPrincipalName :', '')) AS UserPrincipalName
    FROM powerbi.PowerBI_Workspace U
    WHERE U.Linha LIKE '%UserPrincipalName :%'
) AS TB;
*/

-----Extração AccessRight
DROP TABLE IF EXISTS DM.powerbi.DimAccessRight;

SELECT
    identity(int, 1, 1)                               AS Sk_AccessRight,
    AccessRight
INTO DM.powerbi.DimAccessRight
FROM(
    SELECT DISTINCT
        TRIM(REPLACE(U.Linha, 'AccessRight       :', '')) AS AccessRight
    FROM powerbi.PowerBI_Workspace U
    WHERE U.Linha LIKE '%AccessRight       :%'
) AS TB;

ALTER TABLE DM.powerbi.DimAccessRight ADD CONSTRAINT [PK_DimAccessRight] PRIMARY KEY CLUSTERED 
(
	Sk_AccessRight ASC
);
GO

-----Criação Fato Usuários
DROP TABLE IF EXISTS DM.powerbi.FatoWorkspaces;

SELECT
    Sk_Users = (SELECT TOP 1 U.Sk_Users FROM DM.powerbi.DimUsers U WHERE U.Email = F.UserPrincipalName),
    Sk_AccessRight = (SELECT TOP 1 U.Sk_AccessRight FROM DM.powerbi.DimAccessRight U WHERE U.AccessRight = F.AccessRight),
    *
INTO DM.powerbi.FatoWorkspaces
FROM (
    SELECT
        TRIM(REPLACE(U.Linha, 'UserPrincipalName :', '')) AS UserPrincipalName,
        TRIM(REPLACE(A.Linha, 'AccessRight       :', '')) AS AccessRight,
        W.Sk_Workspace,
        W.WorkspaceName
    FROM powerbi.PowerBI_Workspace U
    INNER JOIN powerbi.PowerBI_Workspace A ON U.IdAux = A.IdAux+1 AND A.Linha LIKE '%AccessRight       :%'
    INNER JOIN DM.powerbi.DimWorkspaces W ON ( U.IdAux BETWEEN W.IdAux AND W.IdAuxPrev ) OR ( U.IdAux > W.IdAux AND W.IdAuxPrev IS NULL )
) AS F;

SELECT DISTINCT UserPrincipalName, AccessRight, Sk_Workspace--SELECT *--SELECT DISTINCT Sk_Workspace--SELECT DISTINCT Sk_Workspace
FROM DM.powerbi.FatoWorkspaces
ORDER BY Sk_Workspace;

ALTER TABLE DM.powerbi.FatoWorkspaces ADD CONSTRAINT FK_FatoWorkspaces_Sk_Users FOREIGN KEY (Sk_Users) REFERENCES DM.powerbi.DimUsers (Sk_Users);
GO

ALTER TABLE DM.powerbi.FatoWorkspaces ADD CONSTRAINT FK_FatoWorkspaces_Sk_Workspace FOREIGN KEY (Sk_Workspace) REFERENCES DM.powerbi.DimWorkspaces (Sk_Workspace);
GO

ALTER TABLE DM.powerbi.FatoWorkspaces ADD CONSTRAINT FK_FatoWorkspaces_Sk_AccessRight FOREIGN KEY (Sk_AccessRight) REFERENCES DM.powerbi.DimAccessRight (Sk_AccessRight);
GO

-----Criação Fato Relatórios
DROP TABLE IF EXISTS DM.powerbi.FatoReports;

SELECT
    Sk_Report,
    Sk_Workspace = (
        SELECT TOP 1 W.Sk_Workspace FROM DM.powerbi.DimWorkspaces W
        WHERE W.WorkspaceId = (SELECT TOP 1 D.WorkspaceId FROM DM.powerbi.DimDatasets D WHERE D.DatasetId = F.DatasetId)
    ),
    Sk_Dataset = (SELECT TOP 1 D.Sk_Dataset FROM DM.powerbi.DimDatasets D WHERE D.DatasetId = F.DatasetId),
    Sk_Users = (
        SELECT TOP 1 U.Sk_Users FROM DM.powerbi.DimUsers U
        WHERE U.Email = (SELECT TOP 1 TRIM(D.ConfiguredBy) FROM DM.powerbi.DimDatasets D WHERE D.DatasetId = F.DatasetId)
    ),
    ReportName
INTO DM.powerbi.FatoReports--SELECT *
FROM DM.powerbi.DimReports F

SELECT * FROM DM.powerbi.FatoReports;

ALTER TABLE DM.powerbi.FatoReports ADD CONSTRAINT FK_FatoReports_Sk_Users FOREIGN KEY (Sk_Users) REFERENCES DM.powerbi.DimUsers (Sk_Users);
GO

ALTER TABLE DM.powerbi.FatoReports ADD CONSTRAINT FK_FatoReports_Sk_Workspace FOREIGN KEY (Sk_Workspace) REFERENCES DM.powerbi.DimWorkspaces (Sk_Workspace);
GO

ALTER TABLE DM.powerbi.FatoReports ADD CONSTRAINT FK_FatoReports_Sk_Dataset FOREIGN KEY (Sk_Dataset) REFERENCES DM.powerbi.DimDatasets (Sk_Dataset);
GO

ALTER TABLE DM.powerbi.FatoReports ADD CONSTRAINT FK_FatoReports_Sk_Report FOREIGN KEY (Sk_Report) REFERENCES DM.powerbi.DimReports (Sk_Report);
GO