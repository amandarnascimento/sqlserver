-- =============================================
-- CONSULTA 1: Contagem de usu�rios Pro n�o bloqueados
-- =============================================
-- Objetivo: Contar quantos usu�rios Power BI Pro est�o com credenciais desbloqueadas
-- Motivo: Monitorar quantos usu�rios ativos podem acessar recursos premium
-- Observa��o: A tabela DimUsers_Pro parece ser uma tabela espec�fica do ambiente
SELECT COUNT(*) --SELECT * (op��o para ver detalhes se necess�rio)
FROM [powerbi].[DimUsers_Pro]
WHERE [Bloquear credencial] = 'False'

-- =============================================
-- CONSULTA 2: Listagem de usu�rios Pro n�o bloqueados
-- =============================================
-- Objetivo: Listar todos os usu�rios com licen�a Pro e credenciais desbloqueadas
-- Motivo: Identifica��o completa dos usu�rios premium ativos
-- Diferen�a: Usa a tabela principal DimUsers ao inv�s de DimUsers_Pro
SELECT * FROM DM.powerbi.DimUsers
WHERE LicencaPowerBI = 'Pro' AND [BloquearCredencial] = 'False'

-- =============================================
-- CONSULTA 3: Workspaces com usu�rios n�o mapeados
-- =============================================
-- Objetivo: Encontrar workspaces associados a usu�rios que n�o existem na DimUsers
-- Motivo: Identificar contas orphaned ou problemas de sincroniza��o
-- Processo:
--   1. Extrai UserPrincipalNames do log do PowerBI_Workspace
--   2. Filtra apenas os que n�o existem em DimUsers
--   3. Relaciona com os workspaces correspondentes
SELECT *
FROM DM.powerbi.FatoWorkspaces W
INNER JOIN(
    SELECT * FROM (
        SELECT DISTINCT TRIM(REPLACE(U.Linha, 'UserPrincipalName :', '')) AS UserPrincipalName
        FROM powerbi.PowerBI_Workspace U
        WHERE U.Linha LIKE '%UserPrincipalName :%'
    ) AS TB
    WHERE NOT EXISTS(SELECT 1 FROM DM.powerbi.DimUsers U WHERE U.Email = TB.UserPrincipalName)
) TB ON W.UserPrincipalName = TB.UserPrincipalName;

-- =============================================
-- CONSULTA 4: Workspaces sem usu�rio associado
-- =============================================
-- Objetivo: Identificar workspaces que perderam refer�ncia ao usu�rio
-- Motivo: Dados inconsistentes que precisam ser limpos ou reparados
-- Observa��o: O coment�rio DELETE sugere que esta consulta � usada para limpeza
SELECT * --DELETE W (op��o de limpeza comentada)
FROM DM.powerbi.FatoWorkspaces W
WHERE Sk_Users IS NULL;

-- =============================================
-- CONSULTA 5: Reports sem usu�rio associado
-- =============================================
-- Objetivo: Similar � anterior, mas para reports sem usu�rio
-- Motivo: Garantir integridade referencial dos dados
SELECT * --DELETE W (op��o de limpeza comentada)
FROM DM.powerbi.FatoReports W
WHERE Sk_Users IS NULL;

-- =============================================
-- CONSULTA 6: Listagem de direitos de acesso
-- =============================================
-- Objetivo: Visualizar todos os n�veis de permiss�o configurados
-- Motivo: Auditoria de permiss�es do Power BI
SELECT * FROM DM.powerbi.DimAccessRight;

-- =============================================
-- CONSULTA 7: Rela��o completa workspaces x reports
-- =============================================
-- Objetivo: Cruzamento completo entre workspaces e reports com metadados
-- Motivo: An�lise de como os artefatos est�o distribu�dos
-- Observa��o: O LEFT JOIN mant�m workspaces mesmo sem reports
SELECT W.*, R.Sk_Users AS Sk_UserCreate, R.Sk_Report, R.ReportName, R.Sk_Dataset --DELETE W (op��o de limpeza)
FROM DM.powerbi.FatoWorkspaces W
LEFT JOIN DM.powerbi.FatoReports R ON W.Sk_Workspace = R.Sk_Workspace;

-- =============================================
-- CONSULTA 8: Detalhes de um dataset espec�fico
-- =============================================
-- Objetivo: Investigar um dataset espec�fico (ID 258)
-- Motivo: Troubleshooting ou an�lise detalhada
SELECT * FROM dm.powerbi.DimDatasets WHERE Sk_Dataset = 258

-- =============================================
-- CONSULTA 9: Listagem completa de reports
-- =============================================
-- Objetivo: Visualizar todos os reports cadastrados
-- Motivo: An�lise geral ou prepara��o para manuten��o
SELECT * --DELETE W (op��o de limpeza comentada)
FROM DM.powerbi.FatoReports W