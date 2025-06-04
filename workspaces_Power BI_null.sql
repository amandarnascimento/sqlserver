/*
Esta consulta está analisando usuários do Power BI que estão em workspaces mas não têm status 
definido na tabela de usuários.
Esta consulta identifica:
Usuários que estão associados a workspaces no Power BI
Mas que não têm registro na tabela de usuários (DimUsuarios) OU têm registro mas com status não definido

Isso é útil para:
Identificar contas que podem precisar de regularização
Encontrar usuários ativos no Power BI mas não cadastrados corretamente no sistema
Detectar possíveis problemas de sincronização entre as tabelas

A conversão para LOWER() no JOIN sugere que pode haver inconsistências no caso das letras (maiúsculas/minúsculas) 
nos emails entre as tabelas.
*/


SELECT DISTINCT UserPrincipalName --Seleciona nomes principais de usuário (UserPrincipalName) e seus status
	  , U.Status
  FROM powerbi.FatoUsers F
 INNER JOIN powerbi.DimWorkspaces W ON F.Sk_Workspace = W.Sk_Workspace 
 AND WorkspaceType = 'Workspace'
 --Relaciona a tabela de fatos de usuários (FatoUsers) com a dimensão de workspaces
--Filtra apenas workspaces do tipo 'Workspace' (excluindo possíveis tipos como "Personal Workspace")

 LEFT JOIN [powerbi].[DimUsuarios] U ON LOWER(F.UserPrincipalName) = LOWER( U.Email)
 -- Relaciona com a tabela de usuários pelo email (convertido para minúsculas para garantir correspondência)
--LEFT JOIN mantém todos os usuários da primeira tabela, mesmo que não existam na DimUsuarios

 WHERE Status IS NULL