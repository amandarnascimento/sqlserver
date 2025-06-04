USE DM;
GO

/*********************************************************************************************/
------------------------------------Dimensões de Tempo--------------------------------------------------
/*********************************************************************************************/

CREATE TABLE cadastro.[DimData](
      [IdData] [bigint] NOT NULL,
      [Data] [date] NOT NULL,
      [Ano] [smallint] NOT NULL,
      [DataCurta] [nchar](10) NOT NULL,
      [DiaSemana] [nvarchar](15) NOT NULL,
      [DiaMes] [smallint] NOT NULL,
      [MesNome] [nvarchar](10) NOT NULL,
      [MesNumero] [smallint] NOT NULL,
      [Trimestre] [smallint] NOT NULL,
      [Semestre] [smallint] NOT NULL
    CONSTRAINT pk_DimData PRIMARY KEY CLUSTERED ( [IdData] )
);
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
 
SET @DataIni='01/01/1990'
SET @DataFim='31/12/2024'

 
SET @Data=@DataIni
While @Data<=@DataFim
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

SET NOCOUNT OFF;
GO


--SELECT * FROM cadastro.[DimData];

-------------------------Marcação Feriado-----------------------
USE DM;
GO

ALTER TABLE cadastro.[DimData] ADD [Flag_Feriado]  [bit] NOT NULL DEFAULT(0);
GO

-------------------------Nome Feriado-----------------------
USE DM;
GO

ALTER TABLE cadastro.[DimData] ADD [NmFeriado] [nvarchar]( 50 );
GO

-------------------------Tipo Feriado-----------------------
USE DM;
GO

ALTER TABLE cadastro.[DimData] ADD [TipoFeriado] [nvarchar]( 50 );
GO

-------------------------Marcação Emenda Feriado-----------------------
USE DM;
GO

ALTER TABLE cadastro.[DimData] ADD [Flag_EmendaFeriado]  [bit] NOT NULL DEFAULT(0);
GO

-------------------------Marcação Dia Útel-----------------------
USE DM;
GO

ALTER TABLE cadastro.[DimData] ADD [Flag_DiaUtel]  [bit] NOT NULL DEFAULT(0);
GO

-------------------------Marcação Dia Útel-Com-Emendas------------
USE DM;
GO

ALTER TABLE cadastro.[DimData] ADD [Flag_DiaUtelEx]  [bit] NOT NULL DEFAULT(0);
GO

-------------------------Descrição Dia-----------------------
USE DM;
GO

ALTER TABLE cadastro.[DimData] ADD [DescricaoDia] [nvarchar]( 50 );
GO

UPDATE D SET [Flag_Feriado] = 1, [NmFeriado] = F.Descricao, [TipoFeriado] = F.Tipo
FROM cadastro.[DimData] D
INNER JOIN [DM].[cadastro].[fn_Feriados](1990, 2024) F ON D.[Data] = F.DtFeriado;
GO

-------------------------Descrição Dia-Curto----------------------
----------------------------------------------------------------------------
SET LANGUAGE Brazilian
 
USE DM;
GO

ALTER TABLE cadastro.[DimData] ADD [DiaSemanaCurto]  [nchar](3);
GO

ALTER TABLE cadastro.[DimData] ADD [DiaSemanaNumero]  tinyint;
GO

UPDATE cadastro.DimData SET [DiaSemanaCurto] = LEFT(DiaSemana, 3), [DiaSemanaNumero] = DATEPART(weekday,Data);
GO

SELECT * FROM cadastro.DimData;
