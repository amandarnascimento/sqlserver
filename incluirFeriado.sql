---incluir uma data fixa de feriado em todos os anos da tabela feriado

-- Declaração das variáveis para armazenar os anos e os feriados
DECLARE @start_year INT = 2020;
DECLARE @end_year INT = 2028;
DECLARE @feriado_nome NVARCHAR(50) = 'Feriado SP';

-- Loop para inserir os feriados em cada ano
WHILE @start_year <= @end_year
BEGIN
    -- Inserir feriado 25 de janeiro
    INSERT INTO feriados (FeriadoData, FeriadoNome)
    VALUES (CAST(@start_year AS NVARCHAR(4)) + '-01-25', @feriado_nome);

    -- Inserir feriado 9 de julho
    INSERT INTO feriados (FeriadoData, FeriadoNome)
    VALUES (CAST(@start_year AS NVARCHAR(4)) + '-07-09', @feriado_nome);

    -- Incrementa o ano
    SET @start_year = @start_year + 1;
END;
