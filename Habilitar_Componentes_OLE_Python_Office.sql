/*
Este script SQL tem como objetivo configurar um servidor Microsoft SQL Server 
para habilitar três funcionalidades importantes.
Estas configurações geralmente requerem privilégios de administrador no servidor
Algumas dessas configurações podem exigir reinicialização do serviço SQL Server para 
ter efeito completo
Este script é típico em ambientes onde se precisa integrar o SQL Server com outras tecnologias 
como Python para análise de dados ou automação com aplicativos Windows via OLE.
*/


--##### 1º Habilitação de Procedimentos OLE Automation
/*
Primeiro, o script ativa a visualização de opções avançadas com 'show advanced options', 1
Em seguida, habilita os procedimentos OLE Automation com 'Ole Automation Procedures', 1
OLE Automation permite que o SQL Server interaja com objetos COM (Component Object Model), 
como aplicativos do Office (Excel, Word) ou outros componentes do Windows
*/

USE master
GO

sp_configure 'show advanced options', 1
go
reconfigure
go
sp_configure 'Ole Automation Procedures', 1
go
reconfigure
go

--##### 2º Habilitação de Scripts Externos (Python)
/*
Esta parte habilita a execução de scripts externos, especificamente para integração com Python
Isso é necessário para usar o Machine Learning Services do SQL Server com Python
*/

sp_configure  'external scripts enabled', 1
RECONFIGURE WITH OVERRIDE
go


--##### 3º Finalização
/*
Por fim, o script desativa a visualização de opções avançadas novamente, como uma boa prática 
de segurança
*/
sp_configure 'show advanced options', 0
go
reconfigure
go
