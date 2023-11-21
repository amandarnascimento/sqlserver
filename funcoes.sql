

/*************************************
---   REMOVER ESPAÇOS -  exemplos
*************************************/

SELECT TRIM('   Olá   ') AS Resultado;
SELECT LTRIM('   Olá   ') AS Resultado;

/*************************************
---   SUBSTITUIR PONTO POR VÍRGULA -  exemplos
*************************************/

REPLACE(PFUNC.SALARIO, '.', ',') AS 'REMUNERACAO_MENSAL',


/*************************************
---   COMPRIMENTO DE UM TEXTO -  exemplos
*************************************/


SELECT *
FROM psecao
WHERE LEN(codigo) = 33 AND SUBSTRING(codigo, 7, 4) = '0623';
