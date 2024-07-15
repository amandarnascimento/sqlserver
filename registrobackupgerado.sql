-- retorna os ultimos backups gerados nos 10 ultimos dias

Use msdb 
GO
SET NOCOUNT ON
GO
 
DECLARE @Dias Int
 
Set @Dias = 10
 
SELECT
     S.Database_Name
    ,M.Physical_Device_Name
    ,Convert(Decimal(12,2), S.Backup_Size / 1024 / 1024) As Size
    ,S.Backup_Start_Date
    ,S.Backup_Finish_Date
    ,Cast(DateDiff(Second, S.Backup_Start_Date , S.Backup_Finish_Date) As Varchar(4)) As Seconds_Duration
    ,Case S.Type
        When 'D' Then 'Full'
        When 'I' Then 'Differential'
        When 'L' Then 'Transaction Log'
    End As BackupType
    ,S.Server_Name
FROM
    msdb.dbo.BackupSet S
JOIN
    msdb.dbo.BackupMediaFamily M
ON
    S.Media_Set_ID = M.Media_Set_ID
WHERE
    S.Database_Name In (SELECT Name FROM Sys.Databases)
AND S.Backup_Start_Date > Convert(Char(10), (DateAdd(Day, - @Dias, GetDate())), 121)
-- Para listar todos os databases sem o parametro de dias,
-- comente a linha as duas linhas acima (S.Database... e S.Back...) e troque pelas linhas abaixo.
/*
    S.Database_Name = 'MyDataBase'
*/
ORDER BY
    S.Backup_Start_Date DESC, S.Backup_Finish_Date