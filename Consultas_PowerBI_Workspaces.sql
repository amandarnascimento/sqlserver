SELECT * FROM powerbi.DimUsers;
SELECT * FROM [powerbi].[DimUsers_Pro];

SELECT * FROM powerbi.DimWorkspaces;

SELECT F.*--SELECT DISTINCT AccessRight
FROM powerbi.FatoUsers F
INNER JOIN powerbi.DimWorkspaces W ON F.Sk_Workspace = W.Sk_Workspace AND WorkspaceType = 'Workspace'
WHERE NOT EXISTS(
    SELECT * FROM (
        SELECT DISTINCT UserPrincipalName--SELECT *
        FROM powerbi.FatoUsers U
        INNER JOIN powerbi.DimWorkspaces W ON U.Sk_Workspace = W.Sk_Workspace AND WorkspaceType = 'Workspace'
        WHERE U.AccessRight = 'Admin') AS U WHERE U.UserPrincipalName = F.UserPrincipalName
)
UNION
SELECT F.*--SELECT DISTINCT AccessRight
FROM powerbi.FatoUsers F
INNER JOIN powerbi.DimWorkspaces W ON F.Sk_Workspace = W.Sk_Workspace AND WorkspaceType = 'Workspace'
WHERE F.AccessRight = 'Admin';
