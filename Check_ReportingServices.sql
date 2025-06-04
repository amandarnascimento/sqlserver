-- =============================================
-- CONSULTA 1: Verificar Integra��o com SharePoint
-- =============================================
-- Objetivo: Verificar se o Reporting Services est� configurado para integra��o com SharePoint
-- Motivo: A integra��o com SharePoint afeta como os relat�rios s�o publicados e acessados
-- O que esperamos: 
--   - Se retornar Value=1, significa que est� integrado
--   - Se retornar vazio, n�o h� integra��o
-- Import�ncia: Crucial para entender o ambiente de publica��o de relat�rios
SELECT TOP (1000) [ConfigInfoID], [Name], [Value]
FROM [ReportServer].[dbo].[ConfigurationInfo]
WHERE Name = 'SharePointIntegrated'

-- =============================================
-- CONSULTA 2: Assinaturas de Relat�rios Espec�ficos
-- =============================================
-- Objetivo: Listar todas as assinaturas dos relat�rios cr�ticos de volume e faturamento
-- Motivo: Monitorar assinaturas autom�ticas desses relat�rios importantes
-- O que esperamos: 
--   - Configura��es de entrega (email, arquivo, etc.)
--   - Frequ�ncia de execu��o
--   - �ltimo status de execu��o
-- Import�ncia: Garantir que os relat�rios financeiros est�o sendo distribu�dos corretamente
SELECT S.*
FROM [ReportServer].[dbo].[Subscriptions] S 
INNER JOIN [ReportServer].[dbo].[Catalog] CAT ON S.[Report_OID] = CAT.[ItemID]
WHERE CAT.Name LIKE 'Volume Transacionado' OR CAT.Name LIKE 'Monitoramento Faturamento'

-- =============================================
-- CONSULTA 3: Identificar Bancos do Reporting Services
-- =============================================
-- Objetivo: Listar todos os bancos de dados relacionados ao Reporting Services no servidor
-- Motivo: Em ambientes complexos, pode haver m�ltiplas inst�ncias ou vers�es
-- O que esperamos:
--   - Nomes como 'ReportServer', 'ReportServer$INSTANCE', 'ReportServerTempDB'
-- Import�ncia: Fundamental para garantir que estamos consultando o banco correto
SELECT name FROM sys.databases WHERE name LIKE '%Report%'

-- =============================================
-- CONSULTA 4: Explorar Estrutura do Banco ReportServer
-- =============================================
-- Objetivo: Listar todas as tabelas dispon�veis no banco do Reporting Services
-- Motivo: Entender a estrutura completa do banco para consultas avan�adas
-- O que esperamos:
--   - Tabelas principais: Catalog, Subscriptions, ExecutionLog, Users, etc.
-- Import�ncia: Essencial para desenvolvimento de consultas personalizadas e troubleshooting
USE ReportServer
GO
SELECT * FROM sys.tables