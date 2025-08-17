
--###### Criando D_Calendario no DM
-- INCLUSO: Páscoa, carnaval, datas comemorativas
-- Versão 03 Amanda N.


USE [NOMEDOBANCO].[DM]
GO
SET LANGUAGE Portuguese;
GO

-- Garante o schema DM
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'DM')
    EXEC('CREATE SCHEMA DM');
GO

IF OBJECT_ID('DM.D_CALENDARIO', 'U') IS NOT NULL
    DROP TABLE DM.D_CALENDARIO;
GO

CREATE TABLE DM.D_CALENDARIO (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Data DATE NOT NULL,

    Iddata            AS CONVERT(BIGINT, CONVERT(CHAR(8), Data, 112)),
    Data_br           AS CONVERT(VARCHAR(10), Data, 103),
    Data_iso          AS FORMAT(Data, 'yyMMdd'),
    Dia               AS DATEPART(DAY, Data),
    Dia_semana        AS DATENAME(WEEKDAY, Data),
    Diasemanacurto    AS LEFT(DATENAME(WEEKDAY, Data), 3),
    Dia_semana_num    AS DATEPART(WEEKDAY, Data),
    Semana_ano        AS DATEPART(WEEK, Data),
    Mes_num           AS DATEPART(MONTH, Data),
    Mes_extenso       AS DATENAME(MONTH, Data),
    Mes_curto         AS LOWER(LEFT(DATENAME(MONTH, Data), 3)),
    Ano               AS DATEPART(YEAR, Data),
    Quinzena          AS CASE WHEN DATEPART(DAY, Data) > 15 THEN '2ª Quinzena' ELSE '1ª Quinzena' END,
    Trimestre_num     AS DATEPART(QUARTER, Data),
    Trimestre_desc    AS CASE DATEPART(QUARTER, Data)
                           WHEN 1 THEN '1º Trimestre'
                           WHEN 2 THEN '2º Trimestre'
                           WHEN 3 THEN '3º Trimestre'
                           WHEN 4 THEN '4º Trimestre'
                         END,

    Semestre_num      AS CASE WHEN DATEPART(QUARTER, Data) <= 2 THEN 1 ELSE 2 END,
    Semestre_desc     AS CASE WHEN DATEPART(QUARTER, Data) <= 2 THEN '1º Semestre' ELSE '2º Semestre' END,
    Mes_ano_fn        AS FORMAT(Data, 'MMM.yyyy'),
    Mes_ano           AS FORMAT(Data, 'MM.yyyy'),

    Fim_de_semana     AS CASE WHEN DATENAME(WEEKDAY, Data) IN (N'sábado',N'domingo') THEN 1 ELSE 0 END,

    -- Feriados e flags
    Feriado           BIT NOT NULL DEFAULT 0,
    Nome_feriado      VARCHAR(50) NULL,
    Tipoferiado       VARCHAR(50) NULL,
    Flag_emendaferiado BIT NOT NULL DEFAULT(0),
    Data_comemorativa VARCHAR(100) NULL,

    -- Derivações (sem referenciar colunas calculadas)
    Dia_util          AS CASE 
                           WHEN DATENAME(WEEKDAY, Data) IN (N'sábado',N'domingo') OR Feriado = 1 THEN 0 
                           ELSE 1 
                         END,
    Descricaodia      AS CASE
                           WHEN Feriado = 1 THEN 'Feriado'
                           WHEN DATENAME(WEEKDAY, Data) IN (N'sábado',N'domingo') THEN 'Fim de semana'
                           ELSE 'Dia Útil'
                         END,

    Inicio_mes        AS CASE WHEN DAY(Data) = 1 THEN 1 ELSE 0 END,
    Fim_mes           AS CASE WHEN EOMONTH(Data) = Data THEN 1 ELSE 0 END
);
GO

-- Carga de datas
DECLARE @DataInicio DATE = '2023-12-31';
DECLARE @DataFim    DATE = '2033-12-31';

WHILE @DataInicio < @DataFim
BEGIN
    SET @DataInicio = DATEADD(DAY, 1, @DataInicio);
    INSERT INTO DM.D_CALENDARIO (Data) VALUES (@DataInicio);
END;
GO

/* =========================
   FERIADOS FIXOS
   ========================= */
UPDATE C
   SET Feriado = 1,
       Nome_feriado = CASE FORMAT(Data,'MM-dd')
                         WHEN '01-01' THEN 'Ano Novo'
                         WHEN '04-21' THEN 'Tiradentes'
                         WHEN '05-01' THEN 'Dia do Trabalhador'
                         WHEN '08-15' THEN 'Nossa Senhora'
                         WHEN '09-07' THEN 'Independência do Brasil'
                         WHEN '10-12' THEN 'Nossa Senhora Aparecida'
                         WHEN '11-02' THEN 'Finados'
                         WHEN '11-15' THEN 'Proclamação da República'
                         WHEN '11-20' THEN 'Consciência Negra'
                         WHEN '12-08' THEN 'Imaculada'
                         WHEN '12-25' THEN 'Natal'
                         ELSE NULL
                      END,
       Tipoferiado = 'Fixo'
FROM DM.D_CALENDARIO C
WHERE FORMAT(Data, 'MM-dd') IN
('01-01','04-21','05-01','09-07','08-15','10-12','11-02','11-15','11-20','12-08','12-25');
GO

/* =============================================
   FERIADOS MÓVEIS: Carnaval, Páscoa, Corpus Christi
   ============================================= */
DECLARE @Ano INT = 2024;
DECLARE @Pascoa DATE, @Carnaval DATE, @CorpusChristi DATE;

WHILE @Ano <= 2033
BEGIN
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
    DECLARE @MesPascoa INT = (@h + @L - 7 * @m + 114) / 31;
    DECLARE @DiaPascoa INT = ((@h + @L - 7 * @m + 114) % 31) + 1;

    SET @Pascoa = DATEFROMPARTS(@Ano, @MesPascoa, @DiaPascoa);
    SET @Carnaval = DATEADD(DAY, -47, @Pascoa);
    SET @CorpusChristi = DATEADD(DAY, 60, @Pascoa);

    UPDATE DM.D_CALENDARIO
       SET Feriado = 1, Nome_feriado = 'Carnaval', Tipoferiado = 'Móvel'
     WHERE Data IN (@Carnaval, DATEADD(DAY, 1, @Carnaval));

    UPDATE DM.D_CALENDARIO
       SET Feriado = 1, Nome_feriado = 'Páscoa', Tipoferiado = 'Móvel'
     WHERE Data = @Pascoa;

    UPDATE DM.D_CALENDARIO
       SET Feriado = 1, Nome_feriado = 'Corpus Christi', Tipoferiado = 'Móvel'
     WHERE Data = @CorpusChristi;

    SET @Ano = @Ano + 1;
END;
GO

/* =============================
   DATAS COMEMORATIVAS
   ============================= */
UPDATE DM.D_CALENDARIO SET Data_comemorativa = 'Ano Novo'                    WHERE FORMAT(Data, 'MM-dd') = '01-01';
UPDATE DM.D_CALENDARIO SET Data_comemorativa = 'Natal'                       WHERE FORMAT(Data, 'MM-dd') = '12-25';
UPDATE DM.D_CALENDARIO SET Data_comemorativa = 'Dia Internacional da Mulher' WHERE FORMAT(Data, 'MM-dd') = '03-08';
UPDATE DM.D_CALENDARIO SET Data_comemorativa = 'Dia das Crianças'            WHERE FORMAT(Data, 'MM-dd') = '10-12';
GO

-- Dia das Mães / Dia dos Pais (2º domingo de maio/agosto)
DECLARE @data DATE = '2024-01-01';
WHILE @data <= '2033-12-31'
BEGIN
    IF DATENAME(WEEKDAY, @data) = N'domingo' AND DATEPART(DAY, @data) BETWEEN 8 AND 14
    BEGIN
        IF DATEPART(MONTH, @data) = 5
            UPDATE DM.D_CALENDARIO SET Data_comemorativa = 'Dia das Mães' WHERE Data = @data;
        ELSE IF DATEPART(MONTH, @data) = 8
            UPDATE DM.D_CALENDARIO SET Data_comemorativa = 'Dia dos Pais' WHERE Data = @data;
    END
    SET @data = DATEADD(DAY, 1, @data);
END;
GO

-- Black Friday (4ª sexta-feira de novembro)
DECLARE @anoBF INT = 2024;
WHILE @anoBF <= 2033
BEGIN
    DECLARE @primeiroDiaNov DATE = DATEFROMPARTS(@anoBF, 11, 1);
    DECLARE @offset INT = (6 + (7 - DATEPART(WEEKDAY, @primeiroDiaNov))) % 7; -- para sexta
    DECLARE @blackFriday DATE = DATEADD(DAY, @offset + 21, @primeiroDiaNov);  -- 4ª sexta

    UPDATE DM.D_CALENDARIO
       SET Data_comemorativa = 'Black Friday'
     WHERE Data = @blackFriday;

    SET @anoBF = @anoBF + 1;
END;
GO

/* =============================
   Lógica para Flag_emendaferiado
   ============================= */
-- Se feriado cair numa quinta, sexta seguinte = emenda
UPDATE cal
SET Flag_emendaferiado = 1
FROM DM.D_CALENDARIO cal
JOIN DM.D_CALENDARIO fer ON fer.Data = DATEADD(DAY, -1, cal.Data)
WHERE DATENAME(WEEKDAY, fer.Data) = N'quinta-feira'
  AND fer.Feriado = 1
  AND DATENAME(WEEKDAY, cal.Data) = N'sexta-feira';

-- Se feriado cair numa terça, segunda anterior = emenda
UPDATE cal
SET Flag_emendaferiado = 1
FROM DM.D_CALENDARIO cal
JOIN DM.D_CALENDARIO fer ON fer.Data = DATEADD(DAY, 1, cal.Data)
WHERE DATENAME(WEEKDAY, fer.Data) = N'terça-feira'
  AND fer.Feriado = 1
  AND DATENAME(WEEKDAY, cal.Data) = N'segunda-feira';
GO

SELECT * FROM DM.D_CALENDARIO ORDER BY Data;
