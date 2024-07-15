--- script que mostra exatamente quantos porcentos uma session_id está consumo em uma CPU


SELECT 
    session_id, 
    start_time, 
    GETDATE() AS date_atual, 
    DATEDIFF(ms, start_time, GETDATE()) AS tmp_total_exec,
    cpu_time, 
    cpu_time / CAST(DATEDIFF(ms, start_time, GETDATE()) AS DECIMAL(18,2)) AS perc_utilzd  
FROM 
    sys.dm_exec_requests
WHERE 
    session_id = 57;