
-- =============================================
-- ALTERA��O DA VIEW: powerbi.DimUsuarios
-- =============================================
-- Objetivo: Redefinir a estrutura da view de dimens�o de usu�rios do Power BI
-- Motivo: Padronizar e enriquecer as informa��es de usu�rios para reporting
-- Impacto: Todas as consultas que utilizam esta view ser�o afetadas

ALTER VIEW powerbi.DimUsuarios AS
  SELECT 
      -- Chave de relacionamento com workspaces
      B.Sk_WorkspaceUser AS Sk_WorkSpaceUser,
      
      -- Informa��es b�sicas do usu�rio
      A.[Nome para exibi��o] AS Nome,          -- Nome completo do usu�rio
      A.Office AS Filial,                      -- Filial/escrit�rio do usu�rio
      A.T�tulo AS Cargo,                       -- Cargo/fun��o do usu�rio
      
      -- Departamento com tratamento para valores nulos/vazios
      CASE 
        WHEN A.Departamento IS NULL THEN 'N�o Informado'
        WHEN A.Departamento = '' THEN 'N�o Informado'
        ELSE A.Departamento
      END AS Departamento,                     -- Departamento normalizado
      
      -- Informa��es de conta
      A.[Nome UPN] AS Email,                   -- Email/UPN (User Principal Name)
      CAST(A.[Data hora de cria��o] AS DATE) AS Criacao, -- Data de cria��o (sem hora)
      
      -- Status da conta (Ativo/Inativo)
      CASE
        WHEN A.[Bloquear credencial] = 'False' THEN 'Ativo'
        ELSE 'Inativo'
      END AS Status                            -- Status simplificado
      
    -- Tabela fonte principal (usu�rios Pro)
    FROM [powerbi].[DimUsers_Pro] A
    
    -- Relacionamento com tabela de usu�rios para obter a chave de workspace
    LEFT JOIN powerbi.DimUsers B 
      ON A.[Nome UPN] = B.UserPrincipalName    -- Jun��o pelo UPN/email