-- ======================================================================
-- SCRIPT DE CARGA E TRANSFORMA��O DE DADOS DO POWER BI
-- Objetivo: Extrair, limpar e estruturar dados de workspaces, datasets e reports
--           do Power BI para um modelo dimensional anal�tico
-- ======================================================================

-- ======================================================================
-- SE��O 1: PREPARA��O DAS TABELAS DE STAGING
-- Objetivo: Criar estruturas para armazenar dados brutos extra�dos do Power BI
-- ======================================================================

-- Remove e recria tabela de staging para dados de workspaces
DROP TABLE IF EXISTS powerbi.PowerBI_Workspace;
CREATE TABLE powerbi.PowerBI_Workspace(
    IdAux int identity(1, 1) NOT NULL,  -- Chave auto-incremental para controle de linhas
    Linha nvarchar(max)                 -- Armazena linhas brutas do log/exporta��o do Power BI
);
GO

-- Remove e recria tabela de staging para dados de datasets
DROP TABLE IF EXISTS powerbi.PowerBI_Datasets;
CREATE TABLE powerbi.PowerBI_Datasets(
    IdAux int identity(1, 1) NOT NULL,  -- Chave auto-incremental
    Linha nvarchar(max)                 -- Dados brutos de datasets
);
GO

-- Remove e recria tabela de staging para dados de reports
DROP TABLE IF EXISTS powerbi.PowerBI_Reports;
CREATE TABLE powerbi.PowerBI_Reports(
    IdAux int identity(1, 1) NOT NULL,  -- Chave auto-incremental
    Linha nvarchar(max)                 -- Dados brutos de reports
);
GO

-- ======================================================================
-- SE��O 2: LIMPEZA DOS DADOS BRUTOS
-- Objetivo: Identificar e remover registros inv�lidos ou vazios
-- ======================================================================

-- Identifica linhas vazias na tabela de workspaces (para posterior remo��o)
-- Observa��o: O DELETE est� comentado para permitir an�lise pr�via
SELECT * --DELETE
FROM powerbi.PowerBI_Workspace
WHERE TRIM(Linha) = ''  -- Filtra linhas com apenas espa�os em branco
ORDER BY IdAux;

-- Identifica linhas vazias na tabela de datasets
SELECT * --DELETE
FROM powerbi.PowerBI_Datasets
WHERE TRIM(Linha) = ''
ORDER BY IdAux;

-- Identifica linhas vazias na tabela de reports
SELECT * --DELETE
FROM powerbi.PowerBI_Reports
WHERE TRIM(Linha) = ''
ORDER BY IdAux;
GO

-- ======================================================================
-- SE��O 3: CRIA��O DA DIMENS�O DE WORKSPACES
-- Objetivo: Estruturar os dados de workspaces em formato dimensional
-- ======================================================================

-- Remove a tabela de dimens�o se j� existir
DROP TABLE IF EXISTS DM.powerbi.DimWorkspaces;

-- Cria a tabela de dimens�o de workspaces com extra��o dos campos relevantes
SELECT
    W.IdAux,                                  -- Mant�m refer�ncia ao dado original
    CAST(NULL AS int) AS IdAuxPrev,           -- Marcador para pr�xima linha (usado posteriormente)
    identity(int, 1, 1) AS Sk_Workspace,      -- Cria chave substituta auto-incremental
    TRIM(REPLACE(W.Linha, 'Id                    :', '')) AS WorkspaceId,  -- Extrai ID limpo
    TRIM(REPLACE(N.Linha, 'Name                  : ', '')) AS WorkspaceName,  -- Extrai nome
    -- Subconsulta para extrair o tipo do workspace das linhas subsequentes
    (SELECT TOP 1 TRIM(REPLACE(T.Linha, 'Type                  :', ''))
     FROM powerbi.PowerBI_Workspace T
     WHERE T.IdAux > W.IdAux AND T.Linha LIKE '%Type                  :%'
     ORDER BY T.IdAux
    ) AS WorkspaceType,
    CAST(NULL AS nvarchar(150)) AS WorkspaceAdmin  -- Ser� populado posteriormente
INTO DM.powerbi.DimWorkspaces
FROM powerbi.PowerBI_Workspace W
INNER JOIN powerbi.PowerBI_Workspace N ON W.IdAux+1 = N.IdAux  -- Junta linha atual com pr�xima
WHERE W.Linha LIKE '%Id                    :%'  -- Filtra apenas linhas que cont�m IDs
ORDER BY W.IdAux;
GO

-- ======================================================================
-- SE��O 4: ATUALIZA��O DE ADMINISTRADORES DE WORKSPACE
-- Objetivo: Identificar e associar os administradores de cada workspace
-- ======================================================================

-- Primeiro passo: Atualiza o campo IdAuxPrev para marcar o intervalo de linhas
-- que pertencem a cada workspace (facilita consultas subsequentes)
UPDATE W SET
    IdAuxPrev = (SELECT TOP 1 P.IdAux FROM DM.powerbi.DimWorkspaces P 
                WHERE P.IdAux > W.IdAux ORDER BY P.IdAux)
FROM DM.powerbi.DimWorkspaces W;

-- Segundo passo: Atualiza o administrador do workspace com base no UserPrincipalName
-- encontrado dentro do bloco de linhas correspondente ao workspace
UPDATE W SET
    WorkspaceAdmin = (
     SELECT TOP 1 TRIM(REPLACE(U.Linha, 'UserPrincipalName :', ''))
     FROM powerbi.PowerBI_Workspace U
     INNER JOIN powerbi.PowerBI_Workspace A ON U.IdAux = A.IdAux+1 AND A.Linha LIKE '%AccessRight       :%'
     WHERE (U.IdAux BETWEEN W.IdAux AND W.IdAuxPrev) OR 
           (U.IdAux > W.IdAux AND W.IdAuxPrev IS NULL)
     ORDER BY U.IdAux
    )    
FROM DM.powerbi.DimWorkspaces W;

-- Visualiza��o para verifica��o dos resultados
SELECT * FROM DM.powerbi.DimWorkspaces ORDER BY Sk_Workspace;

-- Adiciona chave prim�ria � tabela de workspaces
ALTER TABLE DM.powerbi.DimWorkspaces ADD CONSTRAINT [PK_DimWorkspaces] PRIMARY KEY CLUSTERED 
(
    Sk_Workspace ASC
);
GO

-- ======================================================================
-- SE��O 5: CRIA��O DA DIMENS�O DE DATASETS
-- Objetivo: Estruturar os dados de datasets em formato dimensional
-- ======================================================================

-- Remove a tabela de dimens�o se j� existir
DROP TABLE IF EXISTS DM.powerbi.DimDatasets;

-- Cria a tabela de dimens�o de datasets com extra��o dos campos relevantes
SELECT
    identity(int, 1, 1) AS Sk_Dataset,  -- Chave substituta auto-incremental
    TRIM(REPLACE(W.Linha, 'Id                               :', '')) AS DatasetId,
    TRIM(REPLACE(N.Linha, 'Name                             :', '')) AS DatasetName,
    -- Extrai o usu�rio configurador do dataset
    (SELECT TOP 1 TRIM(REPLACE(T.Linha, 'ConfiguredBy                     :', ''))
     FROM powerbi.PowerBI_Datasets T
     WHERE T.IdAux > W.IdAux AND T.Linha LIKE '%ConfiguredBy                     :%'
     ORDER BY T.IdAux
    ) AS ConfiguredBy,
    -- Extrai o workspace relacionado a partir da URL
    (SELECT TOP 1 TRIM(REPLACE(T.Linha, 'WebUrl                           :', ''))
     FROM powerbi.PowerBI_Datasets T
     WHERE T.IdAux > W.IdAux AND T.Linha LIKE '%WebUrl                           :%'
     ORDER BY T.IdAux
    ) AS WorkspaceId
INTO DM.powerbi.DimDatasets
FROM powerbi.PowerBI_Datasets W
INNER JOIN powerbi.PowerBI_Datasets N ON W.IdAux+1 = N.IdAux
WHERE W.Linha LIKE '%Id                               :%'  -- Filtra linhas de ID
ORDER BY W.IdAux;
GO

-- Atualiza o WorkspaceId para extrair apenas a parte relevante da URL
UPDATE D SET
   WorkspaceId = REPLACE(
       SUBSTRING(
           WorkspaceId, 
           CHARINDEX('groups', WorkspaceId), 
           (CHARINDEX('datasets', WorkspaceId)-CHARINDEX('groups', WorkspaceId))-1
       ), 
       'groups/', '')
FROM DM.powerbi.DimDatasets D;

-- Visualiza��o para verifica��o dos resultados
SELECT * FROM DM.powerbi.DimDatasets;

-- Adiciona chave prim�ria � tabela de datasets
ALTER TABLE DM.powerbi.DimDatasets ADD CONSTRAINT [PK_DimDatasets] PRIMARY KEY CLUSTERED 
(
    Sk_Dataset ASC
);
GO

-- ======================================================================
-- SE��O 6: CRIA��O DA DIMENS�O DE REPORTS
-- Objetivo: Estruturar os dados de reports em formato dimensional
-- ======================================================================

-- Remove a tabela de dimens�o se j� existir
DROP TABLE IF EXISTS DM.powerbi.DimReports;

-- Cria a tabela de dimens�o de reports com extra��o dos campos relevantes
SELECT
    identity(int, 1, 1) AS Sk_Report,  -- Chave substituta auto-incremental
    TRIM(REPLACE(W.Linha, 'Id        :', '')) AS ReportId,
    TRIM(REPLACE(N.Linha, 'Name      :', '')) AS ReportName,
    -- Extrai o DatasetId relacionado ao report
    (SELECT TOP 1 TRIM(REPLACE(T.Linha, 'DatasetId :', ''))
     FROM powerbi.PowerBI_Reports T
     WHERE T.IdAux > W.IdAux AND T.Linha LIKE '%DatasetId :%'
     ORDER BY T.IdAux
    ) AS DatasetId
INTO DM.powerbi.DimReports
FROM powerbi.PowerBI_Reports W
INNER JOIN powerbi.PowerBI_Reports N ON W.IdAux+1 = N.IdAux
WHERE W.Linha LIKE '%Id        :%'  -- Filtra linhas de ID
ORDER BY W.IdAux;
GO

-- Visualiza��o para verifica��o dos resultados
SELECT * FROM DM.powerbi.DimReports;

-- Adiciona chave prim�ria � tabela de reports
ALTER TABLE DM.powerbi.DimReports ADD CONSTRAINT [PK_DimReports] PRIMARY KEY CLUSTERED 
(
    Sk_Report ASC
);
GO

-- ======================================================================
-- FIM DO SCRIPT
-- ======================================================================