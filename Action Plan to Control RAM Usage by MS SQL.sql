-- Dynamic Management Views (DMV)
-- Resource: https://www.sqlshack.com/monitoring-memory-clerk-and-buffer-pool-allocations-in-sql-server/

-- 1. Check usable memory, Some memory is reserved by the OS or BIOS
SELECT CAST(total_physical_memory_kb AS FLOAT)/(1024 * 1024)  AS [Usable Memory In GB] FROM sys.dm_os_sys_memory

-- 2. Check how much memory is allocated to the SQL server
-- a. The value 2147483647 MB is the default "unlimited" setting.
-- b. SQL Server is not limited in how much memory it can use. 
--    It will try to use as much RAM as it needs (up to whatever is available), which can lead to:
--    i.   OS memory starvation
--    ii.  Performance problems from paging
--    iii. Conflicts with other processes on the server
SELECT name, value_in_use FROM sys.configurations WHERE name LIKE 'max server memory%'

-- 3. Set memory cap to prevent:
-- a. Starving the OS or other applications
-- b. Paging and performance degradation
EXEC sp_configure 'max server memory (MB)', 102400; RECONFIGURE;

-- 4. To see how SQL is using memory internally we can query the sys.dm_os_memory_clerks DMV
;With CTE_OS AS (
	SELECT 
		type, 
		SUM(pages_kb)/(1024) AS MB
	FROM sys.dm_os_memory_clerks
	GROUP BY type, name
)
select * from CTE_OS Order By MB DESC

-- 5. a. To see heavy queries waiting for memory
SELECT session_id, requested_memory_kb / 1024 as RequestedMemMb, 
granted_memory_kb / 1024 as GrantedMemMb, text
FROM sys.dm_exec_query_memory_grants qmg
CROSS APPLY sys.dm_exec_sql_text(sql_handle)

-- 5. b. To see how much memory each session is using now
SELECT 
    s.session_id,
    r.status,
    r.command,
    r.cpu_time,
    s.memory_usage * 8 AS MemoryUsedMB,
    t.text
FROM sys.dm_exec_sessions s
JOIN sys.dm_exec_requests r ON s.session_id = r.session_id
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE s.is_user_process = 1;

-- 6. memory allocation of databases by size of their data pages cached in SQL Server's buffer pool
SELECT DB_NAME(database_id) AS [Database Name],
COUNT(*) * 8/1024.0 AS [Cached Size (MB)]
FROM sys.dm_os_buffer_descriptors WITH (NOLOCK)
GROUP BY DB_NAME(database_id)
ORDER BY [Cached Size (MB)] DESC OPTION (RECOMPILE);

