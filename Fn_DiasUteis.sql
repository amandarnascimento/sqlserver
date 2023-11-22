CREATE FUNCTION fn_contagem_dias_uteis
(
    @datainicial DATE,
    @datafinal DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @dias_uteis INT = 0;

    WHILE @datainicial <= @datafinal
    BEGIN
        -- Verifica se o dia da semana é sábado (6) ou domingo (0)
        IF DATEPART(WEEKDAY, @datainicial) NOT IN (1, 7)
        BEGIN
            -- Verifica se é um dia não útil de acordo com a tabela de feriados
            IF NOT EXISTS(SELECT 1 FROM feriados WHERE FeriadoData = @datainicial)
            BEGIN
                SET @dias_uteis += 1;
            END
        END;

        SET @datainicial = DATEADD(DAY, 1, @datainicial);
    END;

    RETURN @dias_uteis;
END;