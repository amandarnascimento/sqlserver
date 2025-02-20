WITH DateGenerator AS (

    SELECT

        CAST('2023-01-01' AS DATE) AS Data_In

    UNION ALL

    SELECT

        DATEADD(MONTH, 1, Data_In)

    FROM

        DateGenerator

    WHERE

        Data_In < '2025-12-01'

),

FormattedDates AS (

    SELECT

        Data_In,

        FORMAT(Data_In, 'MMMM', 'pt-BR') AS Mes_Ext,

        YEAR(Data_In) AS Ano,

        MONTH(Data_In) AS Mes,

        FORMAT(EOMONTH(Data_In), 'dd/MM/yyyy') AS Data_Fn,

        CONCAT(YEAR(Data_In), RIGHT('0' + CAST(MONTH(Data_In) AS VARCHAR(2)), 2)) AS Competencia,

        FORMAT(Data_In, 'dd/MM/yyyy') AS Data_In_Formatada,

        CONCAT(FORMAT(Data_In, 'MMMM', 'pt-BR'), ' ', YEAR(Data_In)) AS Mes_Ano,

        FORMAT(Data_In, 'yyyy-MM') AS Ano_Mes,

        (

            SELECT COUNT(*)

            FROM (

                SELECT DATEADD(DAY, n, Data_In) AS Dia

                FROM (SELECT TOP (DATEDIFF(DAY, Data_In, EOMONTH(Data_In)) + 1) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n FROM master..spt_values) AS x

                WHERE DATEPART(WEEKDAY, DATEADD(DAY, n, Data_In)) BETWEEN 2 AND 7

            ) AS DiasUteis

        ) AS Dias_Uteis_SegSab,

        (

            SELECT COUNT(*)

            FROM (

                SELECT DATEADD(DAY, n, Data_In) AS Dia

                FROM (SELECT TOP (DATEDIFF(DAY, Data_In, EOMONTH(Data_In)) + 1) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n FROM master..spt_values) AS x

                WHERE DATEPART(WEEKDAY, DATEADD(DAY, n, Data_In)) BETWEEN 2 AND 6

            ) AS DiasUteis

        ) AS Dias_Uteis_SegSex,

        (

            SELECT COUNT(*)

            FROM (

                SELECT DATEADD(DAY, n, Data_In) AS Dia

                FROM (SELECT TOP (DATEDIFF(DAY, Data_In, EOMONTH(Data_In)) + 1) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n FROM master..spt_values) AS x

            ) AS Dias

        ) AS Qnt_Dias

    FROM

        DateGenerator

)

SELECT

    ROW_NUMBER() OVER (ORDER BY Data_In) AS [Index],

    Data_In_Formatada AS Data_In,

    Mes_Ext,

    Ano,

    Mes,

    Data_Fn,

    Competencia,

    Mes_Ano,

    Ano_Mes,

    Dias_Uteis_SegSab,

    Dias_Uteis_SegSex,

    Qnt_Dias

FROM

    FormattedDates

ORDER BY

    CAST(Data_In AS DATE)

OPTION (MAXRECURSION 0);