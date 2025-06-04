-- =============================================
-- CONSULTA 1: Contagem de usuários Pro não bloqueados
-- =============================================
-- Objetivo: Contar quantos usuários Power BI Pro estão com credenciais desbloqueadas
-- Motivo: Monitorar quantos usuários ativos podem acessar recursos premium
-- Observação: A tabela DimUsers_Pro parece ser uma tabela específica do ambiente
SELECT COUNT(*) --SELECT * (opção para ver detalhes se necessário)
FROM [powerbi].[DimUsers_Pro]
WHERE [Bloquear credencial] = 'False'

-- =============================================
-- CONSULTA 2: Listagem de usuários Pro não bloqueados
-- =============================================
-- Objetivo: Listar todos os usuários com licença Pro e credenciais desbloqueadas
-- Motivo: Identificação completa dos usuários premium ativos
-- Diferença: Usa a tabela principal DimUsers ao invés de DimUsers_Pro
SELECT * FROM DM.powerbi.DimUsers
WHERE LicencaPowerBI = 'Pro' AND [BloquearCredencial] = 'False'

-- =============================================
-- CONSULTA 3: Workspaces com usuários não mapeados
-- =============================================
-- Objetivo: Encontrar workspaces associados a usuários que não existem na DimUsers
-- Motivo: Identificar contas orphaned ou problemas de sincronização
-- Processo:
--   1. Extrai UserPrincipalNames do log do PowerBI_Workspace
--   2. Filtra apenas os que não existem em DimUsers
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
-- CONSULTA 4: Workspaces sem usuário associado
-- =============================================
-- Objetivo: Identificar workspaces que perderam referência ao usuário
-- Motivo: Dados inconsistentes que precisam ser limpos ou reparados
-- Observação: O comentário DELETE sugere que esta consulta é usada para limpeza
SELECT * --DELETE W (opção de limpeza comentada)
FROM DM.powerbi.FatoWorkspaces W
WHERE Sk_Users IS NULL;

-- =============================================
-- CONSULTA 5: Reports sem usuário associado
-- =============================================
-- Objetivo: Similar à anterior, mas para reports sem usuário
-- Motivo: Garantir integridade referencial dos dados
SELECT * --DELETE W (opção de limpeza comentada)
FROM DM.powerbi.FatoReports W
WHERE Sk_Users IS NULL;

-- =============================================
-- CONSULTA 6: Listagem de direitos de acesso
-- =============================================
-- Objetivo: Visualizar todos os níveis de permissão configurados
-- Motivo: Auditoria de permissões do Power BI
SELECT * FROM DM.powerbi.DimAccessRight;

-- =============================================
-- CONSULTA 7: Relação completa workspaces x reports
-- =============================================
-- Objetivo: Cruzamento completo entre workspaces e reports com metadados
-- Motivo: Análise de como os artefatos estão distribuídos
-- Observação: O LEFT JOIN mantém workspaces mesmo sem reports
SELECT W.*, R.Sk_Users AS Sk_UserCreate, R.Sk_Report, R.ReportName, R.Sk_Dataset --DELETE W (opção de limpeza)
FROM DM.powerbi.FatoWorkspaces W
LEFT JOIN DM.powerbi.FatoReports R ON W.Sk_Workspace = R.Sk_Workspace;

-- =============================================
-- CONSULTA 8: Detalhes de um dataset específico
-- =============================================
-- Objetivo: Investigar um dataset específico (ID 258)
-- Motivo: Troubleshooting ou análise detalhada
SELECT * FROM dm.powerbi.DimDatasets WHERE Sk_Dataset = 258

-- =============================================
-- CONSULTA 9: Listagem completa de reports
-- =============================================
-- Objetivo: Visualizar todos os reports cadastrados
-- Motivo: Análise geral ou preparação para manutenção
SELECT * --DELETE W (opção de limpeza comentada)
FROM DM.powerbi.FatoReports W