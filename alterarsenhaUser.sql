USE [master]
GO

-- Para usu�rio com autentica��o SQL (n�o funciona para usu�rios Windows)
ALTER LOGIN [nomeusuario] WITH PASSWORD = 'NovaSenha123';
GO

-- Se voc� quer remover a necessidade de senha (n�o recomendado para produ��o)
ALTER LOGIN [nomeusuario] WITH PASSWORD = 'NovaSenha123', CHECK_POLICY = OFF;
GO