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
    [MES_ANO_FN] AS FORMAT([DATA], 'MMM.yyyy'),
    [MES_ANO] AS FORMAT([DATA], 'MM.yyyy'),
    [FERIADO] INT DEFAULT 0 -- Mantendo a informação de feriado
);

DECLARE @DataInicio DATE = '2020-12-31';
DECLARE @DataFim DATE = '2030-12-31';

TRUNCATE TABLE D_CALENDARIO;

-- Preenchendo a tabela com as datas de 2021 até 2030
WHILE @DataInicio < @DataFim
BEGIN
    SET @DataInicio = DATEADD(DAY, 1, @DataInicio);
    INSERT INTO D_CALENDARIO ([DATA])
    VALUES (@DataInicio);
END;

-- Atualizando os feriados fixos
UPDATE D_CALENDARIO
SET FERIADO = 1
WHERE FORMAT(DATA, 'MM-dd') IN ('01-01', '04-21', '05-01', '09-07', '10-12', '11-02', '11-20', '12-25');

-- Adicionando o Carnaval para cada ano baseado na data da Páscoa
DECLARE @Ano INT = 2021;
DECLARE @Pascoa DATE, @Carnaval DATE;

WHILE @Ano <= 2030
BEGIN
    -- Cálculo da Páscoa baseado no algoritmo de Gauss
    DECLARE @a INT = @Ano % 19;
    DECLARE @b INT = @Ano / 100;
    DECLARE @c INT = @Ano % 100;
    DECLARE @d INT = @b / 4;
    DECLARE @e INT = @b % 4;
    DECLARE @f INT = (@b + 8) / 25;
    DECLARE @g INT = (@b - @f + 1) / 3;
    DECLARE @h INT = (19 * @a + @b - @d - @g + 15) % 30;
    DECLARE @i INT = @c / 4;
    DECLARE @k INT = @c % 4;
    DECLARE @L INT = (32 + 2 * @e + 2 * @i - @h - @k) % 7;
    DECLARE @m INT = (@a + 11 * @h + 22 * @L) / 451;
    DECLARE @Mes INT = (@h + @L - 7 * @m + 114) / 31;
    DECLARE @Dia INT = ((@h + @L - 7 * @m + 114) % 31) + 1;

    SET @Pascoa = DATEFROMPARTS(@Ano, @Mes, @Dia);
    SET @Carnaval = DATEADD(DAY, -47, @Pascoa); -- Carnaval ocorre 47 dias antes da Páscoa

    -- Atualizando os dias de Carnaval
    UPDATE D_CALENDARIO
    SET FERIADO = 1
    WHERE DATA IN (@Carnaval, DATEADD(DAY, 1, @Carnaval)); -- Segunda e terça-feira de Carnaval

    SET @Ano = @Ano + 1;
END;

SELECT * FROM D_CALENDARIO WHERE FERIADO = 1 ORDER BY DATA;
