

/*************************************
---   REMOVER ESPA�OS -  exemplos
*************************************/

SELECT TRIM('   Ol�   ') AS Resultado;
SELECT LTRIM('   Ol�   ') AS Resultado;

/*************************************
---   SUBSTITUIR PONTO POR V�RGULA -  exemplos
*************************************/

REPLACE(PFUNC.SALARIO, '.', ',') AS 'REMUNERACAO_MENSAL',


/*************************************
---   COMPRIMENTO DE UM TEXTO -  exemplos
*************************************/


SELECT *
FROM psecao
WHERE LEN(codigo) = 33 AND SUBSTRING(codigo, 7, 4) = '0623';
