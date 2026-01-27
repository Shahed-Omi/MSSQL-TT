USE tempdb;
GO

DECLARE @Name varchar(max)

SELECT @Name = Name FROM sys.database_files;

DBCC SHRINKFILE (@Name, 8192);