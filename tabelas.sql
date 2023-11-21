

--- CRIAR COLUNA COM ID EM ORDEM CRESCENTE

/*************************************
--- 1º CRIAR COLUNA 
*************************************/

ALTER TABLE D_CALENDARIO
ADD ID_COLUNA INT;

/*************************************
--- 2º  INSERIR DADOS NA COLUNA
*************************************/

;WITH CTE_ColunaSequencial AS (
    SELECT 
        [DATA],
        ROW_NUMBER() OVER (ORDER BY [DATA]) AS NumeroSequencial
    FROM D_CALENDARIO
)
UPDATE D_CALENDARIO
SET ID_COLUNA = CTE_ColunaSequencial.NumeroSequencial
FROM D_CALENDARIO
INNER JOIN CTE_ColunaSequencial ON D_CALENDARIO.[DATA] = CTE_ColunaSequencial.[DATA];

------------------------------------------------------------------------------------------

/*************************************
---   UPDATE EM UMA TABELA - exemplos
*************************************/

-- Exemplo 1

UPDATE nometabela
SET nomecoluna = 'AV REI PELE'
WHERE colunaqualquer LIKE '0.039%'
AND colunaqualquer2 = '0'

-- Exemplo 2

UPDATE TCARGOS
SET datacriacao = NULL
WHERE cargos = 5;


/*************************************
---   ALTERAR NOME DA TABELA - exemplos
*************************************/

--De FUNC para TCARGOS

EXEC sp_rename 'FUNC', 'TCARGOS';
SELECT * FROM TCARGOS

/*************************************
---   ALTERAR NOME DA COLUNA - exemplos
*************************************/

EXEC sp_rename 'TCARGOS.codigo_cargo', 'CARGOS', 'COLUMN';

/*************************************
---   ALTERAR TIPO DE DADO -  exemplos
*************************************/

alter table funcionarios
alter column telefone varchar(10)


/*************************************
---   EXIBIR COLUNAS DE UMA TABELA -  exemplos
*************************************/

SELECT column_name
from INFORMATION_SCHEMA.COLUMNS
where table_name = 'tabela1'


/*************************************
---   EXIBIR RESTRIÇÕES DE UMA TABELA -  exemplos
*************************************/


SELECT TABLE_NAME, constraint_name, constraint_type
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
where table_name = 'tabela1'



/*************************************
---  CRIAR TABELA -  exemplos
*************************************/

--Criar tabela com coluna de RECCREATEDBY e RECMODIFIEDBY
--1º executamos o código abaixo para criar uma tabela
-- Criar tabela "funcionarios"

CREATE TABLE funcionarios (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(50),
    idade INT,
    RECCREATEDBY VARCHAR(50),
    RECMODIFIEDBY VARCHAR(50),
    RECCREATEDDATE DATETIME DEFAULT GETDATE(),
    RECMODIFIEDDATE DATETIME
);

--2º executamos o código abaixo para criar as regras e inserir dados
-- Criar gatilho para atualizar o campo RECMODIFIEDBY e RECMODIFIEDDATE

CREATE TRIGGER tr_funcionarios_update
ON funcionarios
AFTER UPDATE
AS
BEGIN
    IF UPDATE(RECMODIFIEDBY)
    BEGIN
        UPDATE funcionarios
        SET RECMODIFIEDDATE = GETDATE()
        FROM funcionarios
        INNER JOIN inserted ON funcionarios.ID = inserted.ID;
    END;
END;
GO

-- Inserir dados na tabela "funcionarios"
INSERT INTO funcionarios (nome, idade, RECCREATEDBY, RECMODIFIEDBY)
VALUES ('amanda', 26, SUSER_SNAME(), NULL),
       ('pedro', 14, SUSER_SNAME(), NULL),
       ('vitor', 13, SUSER_SNAME(), NULL);




---*************************************-----------
-- 3º Alterar dado na tabela e salvar o registro

	   UPDATE funcionarios
SET idade = 24,
    RECMODIFIEDBY = SUSER_SNAME(),
    RECMODIFIEDDATE = GETDATE()
WHERE nome = 'pedro';




