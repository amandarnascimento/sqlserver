WITH diasuteis AS (
    SELECT distinct
        CONVERT(varchar, DATEADD(month, DATEDIFF(month, 0, data), 0), 103) AS datainicial,
        CONVERT(varchar, EOMONTH(data), 103) AS datafinal
    FROM 
        d_calendario
)
SELECT 
    datainicial,
    datafinal,
    dbo.fn_contagem_dias_uteis(datainicial, datafinal) AS dias_uteis
FROM 
    diasuteis
