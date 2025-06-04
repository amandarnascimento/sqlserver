
-- =============================================
-- ALTERAÇÃO DA VIEW: powerbi.DimUsuarios
-- =============================================
-- Objetivo: Redefinir a estrutura da view de dimensão de usuários do Power BI
-- Motivo: Padronizar e enriquecer as informações de usuários para reporting
-- Impacto: Todas as consultas que utilizam esta view serão afetadas

ALTER VIEW powerbi.DimUsuarios AS
  SELECT 
      -- Chave de relacionamento com workspaces
      B.Sk_WorkspaceUser AS Sk_WorkSpaceUser,
      
      -- Informações básicas do usuário
      A.[Nome para exibição] AS Nome,          -- Nome completo do usuário
      A.Office AS Filial,                      -- Filial/escritório do usuário
      A.Título AS Cargo,                       -- Cargo/função do usuário
      
      -- Departamento com tratamento para valores nulos/vazios
      CASE 
        WHEN A.Departamento IS NULL THEN 'Não Informado'
        WHEN A.Departamento = '' THEN 'Não Informado'
        ELSE A.Departamento
      END AS Departamento,                     -- Departamento normalizado
      
      -- Informações de conta
      A.[Nome UPN] AS Email,                   -- Email/UPN (User Principal Name)
      CAST(A.[Data hora de criação] AS DATE) AS Criacao, -- Data de criação (sem hora)
      
      -- Status da conta (Ativo/Inativo)
      CASE
        WHEN A.[Bloquear credencial] = 'False' THEN 'Ativo'
        ELSE 'Inativo'
      END AS Status                            -- Status simplificado
      
    -- Tabela fonte principal (usuários Pro)
    FROM [powerbi].[DimUsers_Pro] A
    
    -- Relacionamento com tabela de usuários para obter a chave de workspace
    LEFT JOIN powerbi.DimUsers B 
      ON A.[Nome UPN] = B.UserPrincipalName    -- Junção pelo UPN/email