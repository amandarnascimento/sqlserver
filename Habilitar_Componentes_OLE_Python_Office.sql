/*
Este script SQL tem como objetivo configurar um servidor Microsoft SQL Server 
para habilitar tr�s funcionalidades importantes.
Estas configura��es geralmente requerem privil�gios de administrador no servidor
Algumas dessas configura��es podem exigir reinicializa��o do servi�o SQL Server para 
ter efeito completo
Este script � t�pico em ambientes onde se precisa integrar o SQL Server com outras tecnologias 
como Python para an�lise de dados ou automa��o com aplicativos Windows via OLE.
*/


--##### 1� Habilita��o de Procedimentos OLE Automation
/*
Primeiro, o script ativa a visualiza��o de op��es avan�adas com 'show advanced options', 1
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

--##### 2� Habilita��o de Scripts Externos (Python)
/*
Esta parte habilita a execu��o de scripts externos, especificamente para integra��o com Python
Isso � necess�rio para usar o Machine Learning Services do SQL Server com Python
*/

sp_configure  'external scripts enabled', 1
RECONFIGURE WITH OVERRIDE
go


--##### 3� Finaliza��o
/*
Por fim, o script desativa a visualiza��o de op��es avan�adas novamente, como uma boa pr�tica 
de seguran�a
*/
sp_configure 'show advanced options', 0
go
reconfigure
go
