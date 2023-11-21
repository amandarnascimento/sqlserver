SET LANGUAGE Portuguese;

CREATE TABLE D_CALENDARIO (
    [ID] INT IDENTITY(1, 1) PRIMARY KEY,
    [DATA] DATE,
    [DATA_BR] AS (CONVERT(varchar(10), [DATA], 103)),
    [DIA] AS (DATEPART(DAY, [DATA])),
    [TRI_NUM] AS (DATEPART(QUARTER, [DATA])),
    [TRIMESTRE] AS CASE
                        WHEN (DATEPART(QUARTER, [DATA])) = 1 THEN '1º Trimestre'
                        WHEN (DATEPART(QUARTER, [DATA])) = 2 THEN '2º Trimestre'
                        WHEN (DATEPART(QUARTER, [DATA])) = 3 THEN '3º Trimestre'
                        WHEN (DATEPART(QUARTER, [DATA])) = 4 THEN '4º Trimestre' END,
    [QUINZENA] AS CASE
                       WHEN DATEPART(DAY, [DATA]) > 15 THEN '2ª Quinzena'
                       ELSE '1ª Quinzena' END,
    [SEMESTRE] AS CASE
                       WHEN DATEPART(QUARTER, [DATA]) <= 2 THEN '1º Semestre'
                       ELSE '2º Semestre' END,
    [SEM_NUM] AS CASE
                      WHEN DATEPART(QUARTER, [DATA]) <= 2 THEN 1
                      ELSE 2 END,
    [DIA_SEMANA] AS (DATENAME(WEEKDAY, [DATA])),
    [ANO] AS (DATEPART(YEAR, [DATA])),
    [MES_NUM] AS (DATEPART(MONTH, [DATA])),
    [MES_EXTENSO] AS CASE
                          WHEN (DATEPART(MONTH, [DATA])) = 1 THEN 'Janeiro'
                          WHEN (DATEPART(MONTH, [DATA])) = 2 THEN 'Fevereiro'
                          WHEN (DATEPART(MONTH, [DATA])) = 3 THEN 'Março'
                          WHEN (DATEPART(MONTH, [DATA])) = 4 THEN 'Abril'
                          WHEN (DATEPART(MONTH, [DATA])) = 5 THEN 'Maio'
                          WHEN (DATEPART(MONTH, [DATA])) = 6 THEN 'Junho'
                          WHEN (DATEPART(MONTH, [DATA])) = 7 THEN 'Julho'
                          WHEN (DATEPART(MONTH, [DATA])) = 8 THEN 'Agosto'
                          WHEN (DATEPART(MONTH, [DATA])) = 9 THEN 'Setembro'
                          WHEN (DATEPART(MONTH, [DATA])) = 10 THEN 'Outubro'
                          WHEN (DATEPART(MONTH, [DATA])) = 11 THEN 'Novembro'
                          WHEN (DATEPART(MONTH, [DATA])) = 12 THEN 'Dezembro' END,
    [MES_ANO_FN] AS CASE
                         WHEN (DATEPART(MONTH, [DATA])) = 1 THEN 'Jan.' + CAST(DATEPART(YEAR, [DATA]) AS VARCHAR)
                         WHEN (DATEPART(MONTH, [DATA])) = 2 THEN 'Fev.' + CAST(DATEPART(YEAR, [DATA]) AS VARCHAR)
                         WHEN (DATEPART(MONTH, [DATA])) = 3 THEN 'Mar.' + CAST(DATEPART(YEAR, [DATA]) AS VARCHAR)
                         WHEN (DATEPART(MONTH, [DATA])) = 4 THEN 'Abr.' + CAST(DATEPART(YEAR, [DATA]) AS VARCHAR)
                         WHEN (DATEPART(MONTH, [DATA])) = 5 THEN 'Mai.' + CAST(DATEPART(YEAR, [DATA]) AS VARCHAR)
                         WHEN (DATEPART(MONTH, [DATA])) = 6 THEN 'Jun.' + CAST(DATEPART(YEAR, [DATA]) AS VARCHAR)
                         WHEN (DATEPART(MONTH, [DATA])) = 7 THEN 'Jul.' + CAST(DATEPART(YEAR, [DATA]) AS VARCHAR)
                         WHEN (DATEPART(MONTH, [DATA])) = 8 THEN 'Ago.' + CAST(DATEPART(YEAR, [DATA]) AS VARCHAR)
                         WHEN (DATEPART(MONTH, [DATA])) = 9 THEN 'Set.' + CAST(DATEPART(YEAR, [DATA]) AS VARCHAR)
                         WHEN (DATEPART(MONTH, [DATA])) = 10 THEN 'Out.' + CAST(DATEPART(YEAR, [DATA]) AS VARCHAR)
                         WHEN (DATEPART(MONTH, [DATA])) = 11 THEN 'Nov.' + CAST(DATEPART(YEAR, [DATA]) AS VARCHAR)
                         WHEN (DATEPART(MONTH, [DATA])) = 12 THEN 'Dez.' + CAST(DATEPART(YEAR, [DATA]) AS VARCHAR)END,
    [MES_ANO] AS FORMAT([DATA], 'MM.yyyy'));

DECLARE @DataInicio DATETIME,
        @DataFim    DATETIME;

SET @DataInicio = '31/12/2020';
SET @DataFim = '31/12/2026';

TRUNCATE TABLE D_CALENDARIO;

WHILE @DataInicio <= @DataFim
BEGIN
    SET @DataInicio = DATEADD(DAY, 1, @DataInicio);
    INSERT INTO D_CALENDARIO ([DATA])
    VALUES (@DataInicio);
END


SELECT *
  FROM D_CALENDARIO;
