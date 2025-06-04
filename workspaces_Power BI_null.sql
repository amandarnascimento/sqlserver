/*
Esta consulta est� analisando usu�rios do Power BI que est�o em workspaces mas n�o t�m status 
definido na tabela de usu�rios.
Esta consulta identifica:
Usu�rios que est�o associados a workspaces no Power BI
Mas que n�o t�m registro na tabela de usu�rios (DimUsuarios) OU t�m registro mas com status n�o definido

Isso � �til para:
Identificar contas que podem precisar de regulariza��o
Encontrar usu�rios ativos no Power BI mas n�o cadastrados corretamente no sistema
Detectar poss�veis problemas de sincroniza��o entre as tabelas

A convers�o para LOWER() no JOIN sugere que pode haver inconsist�ncias no caso das letras (mai�sculas/min�sculas) 
nos emails entre as tabelas.
*/


SELECT DISTINCT UserPrincipalName --Seleciona nomes principais de usu�rio (UserPrincipalName) e seus status
	  , U.Status
  FROM powerbi.FatoUsers F
 INNER JOIN powerbi.DimWorkspaces W ON F.Sk_Workspace = W.Sk_Workspace 
 AND WorkspaceType = 'Workspace'
 --Relaciona a tabela de fatos de usu�rios (FatoUsers) com a dimens�o de workspaces
--Filtra apenas workspaces do tipo 'Workspace' (excluindo poss�veis tipos como "Personal Workspace")

 LEFT JOIN [powerbi].[DimUsuarios] U ON LOWER(F.UserPrincipalName) = LOWER( U.Email)
 -- Relaciona com a tabela de usu�rios pelo email (convertido para min�sculas para garantir correspond�ncia)
--LEFT JOIN mant�m todos os usu�rios da primeira tabela, mesmo que n�o existam na DimUsuarios

 WHERE Status IS NULL