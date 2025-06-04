/* Este script tem como objetivo popular uma tabela de dimensão de datas (DimData) no banco de dados DM, incluindo feriados e informações adicionais sobre 
cada data.
 O script pressupõe a existência de uma função fn_Feriados que retorna os feriados brasileiros para um determinado intervalo de anos.

Define o banco de dados DM como contexto
Configura o idioma para português brasileiro (afeta nomes de meses/dias da semana)
SET NOCOUNT ON desativa mensagens de "linhas afetadas" para melhorar performance

Define:
@DataIni: dia seguinte à última data existente na tabela DimData
@DataFim: 1 ano após a última data existente
Para cada dia no intervalo calculado:
Calcula um ID numérico no formato AAAAMMDD
Extrai dia da semana, dia do mês, nome do mês, trimestre, semestre etc.
Insere uma nova linha na tabela DimData

*/





USE DM;
GO

----------------------------------------------------------------------------
SET LANGUAGE Brazilian
 
SET NOCOUNT ON;

DECLARE @IdData bigint
DECLARE @Ano smallint
DECLARE @Data date
DECLARE @DataIni date
DECLARE @DataFim date
DECLARE @DataCurta char(10)
DECLARE @DiaSemana varchar(15)
DECLARE @DiaMes smallint
DECLARE @MesNome varchar(10)
DECLARE @MesNumero smallint
DECLARE @Trimestre smallint
DECLARE @Semestre smallint

SELECT @DataIni = DATEADD(day , 1, MAX(Data)),
       @DataFim = DATEADD(year, 1, MAX(Data))
FROM cadastro.DimData;
 
SET @Data=@DataIni
While @Data<=@DataFim ---Loop para Popular a Tabela
Begin
     Set @IdData = cast(convert(char(10), @Data, 112) as bigint)--SELECT cast(convert(char(10), GETDATE(), 112) as bigint)
     Set @DataCurta = convert(char(10), @Data, 103)
     Set @DiaSemana = datename(weekday,@Data)
     Set @DiaMes = day(@Data)
     Set @MesNome = datename(month,@Data)
     Set @MesNumero = month(@Data)
     Set @Trimestre = DATEPART(quarter,@Data)
     Select @Semestre= Case
          when @MesNumero in (1,2,3,4,5,6) then 1
          when @MesNumero in (7,8,9,10,11,12) then 2
     End
     Set @Ano = YEAR(@Data)
     INSERT INTO cadastro.[DimData](
         IdData, [Data], Ano, DataCurta, DiaSemana,
         DiaMes, MesNome, MesNumero,
         Trimestre, Semestre) values(@IdData, @Data, @Ano, @DataCurta, @DiaSemana, @DiaMes, @MesNome, @MesNumero, @Trimestre, @Semestre)
 
     Set @Data=dateadd(day,1,@Data)
End


--SELECT * FROM cadastro.[DimData];

-------------------------Marcação Feriado-----------------------
/*
Usa uma função fn_Feriados para marcar feriados no período
Atualiza os campos de feriado (Flag_Feriado, NmFeriado, TipoFeriado)
*/

UPDATE D SET [Flag_Feriado] = 1, [NmFeriado] = F.Descricao, [TipoFeriado] = F.Tipo
FROM cadastro.[DimData] D
INNER JOIN [DM].[cadastro].[fn_Feriados](YEAR(@DataIni), YEAR(@DataFim)) F ON D.[Data] = F.DtFeriado
WHERE D.[Data] BETWEEN @DataIni AND @DataFim;

-------------------------Descrição Dia-Curto----------------------
----------------------------------------------------------------------------

UPDATE cadastro.DimData SET [DiaSemanaCurto] = LEFT(DiaSemana, 3), [DiaSemanaNumero] = DATEPART(weekday,Data)
WHERE [Data] BETWEEN @DataIni AND @DataFim;
/*
Cria versões curtas dos dias da semana ("Seg" em vez de "Segunda-feira")
Adiciona número do dia da semana (1=Domingo, 2=Segunda...)
*/



SET NOCOUNT OFF; -- Restaura configurações padrão
GO

--SELECT * FROM cadastro.DimData WHERE Ano = 2024;