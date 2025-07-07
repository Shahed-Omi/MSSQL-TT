SELECT 
    fk.name AS ForeignKeyName,
    tp.name AS ReferencingTable,
    cp.name AS ReferencingColumn
FROM 
    sys.foreign_keys AS fk
INNER JOIN 
    sys.foreign_key_columns AS fkc 
    ON fk.object_id = fkc.constraint_object_id
INNER JOIN 
    sys.tables AS tp 
    ON fk.parent_object_id = tp.object_id
INNER JOIN 
    sys.columns AS cp 
    ON fkc.parent_object_id = cp.object_id 
    AND fkc.parent_column_id = cp.column_id
WHERE 
    fk.referenced_object_id = OBJECT_ID('Users'); -- Replace with your table name
