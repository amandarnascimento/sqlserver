---script utilizado para identificar quais databases estão com o nivel de isolamento alterado para snapshot. Pode ser util para ----identificar quais bases podem estar sobrecarregando o tempdb com o versionamento de linhas.


SELECT DB_NAME(database_id), 
    is_read_committed_snapshot_on,
    snapshot_isolation_state_desc 
FROM sys.databases

-- Show space usage in tempdb
SELECT DB_NAME(vsu.database_id) AS DatabaseName,
    vsu.reserved_page_count, 
    vsu.reserved_space_kb, 
    tu.total_page_count as tempdb_pages, 
    vsu.reserved_page_count * 100. / tu.total_page_count AS [Snapshot %],
    tu.allocated_extent_page_count * 100. / tu.total_page_count AS [tempdb % used]
FROM sys.dm_tran_version_store_space_usage vsu
    CROSS JOIN tempdb.sys.dm_db_file_space_usage tu
WHERE vsu.database_id = DB_ID(DB_NAME());