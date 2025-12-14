SELECT 
    t.name AS TableName,
    s.name AS SchemaName,
    c.name AS ColumnName
FROM sys.columns c
JOIN sys.tables t ON c.object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE c.name = 'ColumnName'
ORDER BY s.name, t.name;
