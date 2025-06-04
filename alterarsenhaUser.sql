USE [master]
GO

-- Para usuário com autenticação SQL (não funciona para usuários Windows)
ALTER LOGIN [nomeusuario] WITH PASSWORD = 'NovaSenha123';
GO

-- Se você quer remover a necessidade de senha (não recomendado para produção)
ALTER LOGIN [nomeusuario] WITH PASSWORD = 'NovaSenha123', CHECK_POLICY = OFF;
GO