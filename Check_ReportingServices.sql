-- =============================================
-- CONSULTA 1: Verificar Integração com SharePoint
-- =============================================
-- Objetivo: Verificar se o Reporting Services está configurado para integração com SharePoint
-- Motivo: A integração com SharePoint afeta como os relatórios são publicados e acessados
-- O que esperamos: 
--   - Se retornar Value=1, significa que está integrado
--   - Se retornar vazio, não há integração
-- Importância: Crucial para entender o ambiente de publicação de relatórios
SELECT TOP (1000) [ConfigInfoID], [Name], [Value]
FROM [ReportServer].[dbo].[ConfigurationInfo]
WHERE Name = 'SharePointIntegrated'

-- =============================================
-- CONSULTA 2: Assinaturas de Relatórios Específicos
-- =============================================
-- Objetivo: Listar todas as assinaturas dos relatórios críticos de volume e faturamento
-- Motivo: Monitorar assinaturas automáticas desses relatórios importantes
-- O que esperamos: 
--   - Configurações de entrega (email, arquivo, etc.)
--   - Frequência de execução
--   - Último status de execução
-- Importância: Garantir que os relatórios financeiros estão sendo distribuídos corretamente
SELECT S.*
FROM [ReportServer].[dbo].[Subscriptions] S 
INNER JOIN [ReportServer].[dbo].[Catalog] CAT ON S.[Report_OID] = CAT.[ItemID]
WHERE CAT.Name LIKE 'Volume Transacionado' OR CAT.Name LIKE 'Monitoramento Faturamento'

-- =============================================
-- CONSULTA 3: Identificar Bancos do Reporting Services
-- =============================================
-- Objetivo: Listar todos os bancos de dados relacionados ao Reporting Services no servidor
-- Motivo: Em ambientes complexos, pode haver múltiplas instâncias ou versões
-- O que esperamos:
--   - Nomes como 'ReportServer', 'ReportServer$INSTANCE', 'ReportServerTempDB'
-- Importância: Fundamental para garantir que estamos consultando o banco correto
SELECT name FROM sys.databases WHERE name LIKE '%Report%'

-- =============================================
-- CONSULTA 4: Explorar Estrutura do Banco ReportServer
-- =============================================
-- Objetivo: Listar todas as tabelas disponíveis no banco do Reporting Services
-- Motivo: Entender a estrutura completa do banco para consultas avançadas
-- O que esperamos:
--   - Tabelas principais: Catalog, Subscriptions, ExecutionLog, Users, etc.
-- Importância: Essencial para desenvolvimento de consultas personalizadas e troubleshooting
USE ReportServer
GO
SELECT * FROM sys.tables