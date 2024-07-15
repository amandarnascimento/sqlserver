---Buscar por qualquer string em um banco de dados

DECLARE @SearchValue NVARCHAR(100) = 'unimed belo horizonte'
DECLARE @SQL NVARCHAR(MAX) = ''
DECLARE @TableName NVARCHAR(128)
DECLARE @ColumnName NVARCHAR(128)
DECLARE @DataType NVARCHAR(128)

-- Cursor para iterar sobre todas as tabelas do banco de dados
DECLARE table_cursor CURSOR FOR
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'

OPEN table_cursor
FETCH NEXT FROM table_cursor INTO @TableName

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Para cada tabela, iterar sobre todas as colunas
    DECLARE column_cursor CURSOR FOR
    SELECT COLUMN_NAME, DATA_TYPE
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @TableName

    OPEN column_cursor
    FETCH NEXT FROM column_cursor INTO @ColumnName, @DataType

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Verificar se o tipo de dados � compat�vel com a fun��o LIKE
        IF @DataType IN ('varchar', 'nvarchar', 'char', 'nchar', 'text', 'ntext')
        BEGIN
            -- Construir a consulta SQL dinamicamente
            SET @SQL = @SQL + '
            SELECT ''' + @TableName + ''' AS TableName, ''' + @ColumnName + ''' AS ColumnName, [' + @ColumnName + '] AS ColumnValue
            FROM [' + @TableName + ']
            WHERE [' + @ColumnName + '] LIKE ''%' + @SearchValue + '%'' 
            UNION ALL'
        END

        FETCH NEXT FROM column_cursor INTO @ColumnName, @DataType
    END

    CLOSE column_cursor
    DEALLOCATE column_cursor

    FETCH NEXT FROM table_cursor INTO @TableName
END

CLOSE table_cursor
DEALLOCATE table_cursor

-- Remover o �ltimo 'UNION ALL'
IF LEN(@SQL) > 0
BEGIN
    SET @SQL = LEFT(@SQL, LEN(@SQL) - 10)

    -- Executar a consulta din�mica
    EXEC sp_executesql @SQL
END
ELSE
BEGIN
    PRINT 'Nenhum dado encontrado que corresponda ao valor pesquisado.'
END