--- maneira de ter uma no��o do quanto de mem�ria total o SQL Server est� consumindo


-- virtual_address_space_committed_kb - physical_memory_in_use_kb = MemToLeave? ReservedMemory?... NonBufferPoolMem
SELECT physical_memory_in_use_kb / 1024. AS Actual_Usage_mb,
       virtual_address_space_committed_kb / 1024. AS VAS_Committed,
       virtual_address_space_reserved_kb / 1024. AS VAS_Reserved,
       total_virtual_address_space_kb / 1024. AS VAS_Total,
       (large_page_allocations_kb + locked_page_allocations_kb + physical_memory_in_use_kb) / 1024. AS Actual_Physical_Memory_mb,
       (virtual_address_space_committed_kb - physical_memory_in_use_kb) / 1024. AS MemToLeave_MB
FROM sys.dm_os_process_memory
GO

/*
Na coluna Acutal_Usage_mb temos o total consumido pelos processos dentro da buffer pool
Na coluna MemToLeave_MB temos o total consumindo dentro da stack size (2mb) + DLLs

--No SQL Server os espa�os de endere�os s�o dividido em:
MemToLeave: stack size (2mb) + DLLs
Buffer pool: Todo o resto

Para trazer o total que o SQL Server est� utilizando de mem�ria podemos fazer a soma do Acutal_Usage + MemToLeave_MB
*/