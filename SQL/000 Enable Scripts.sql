USE master;
GO
EXEC sp_configure 'external scripts enabled', 1;
RECONFIGURE WITH OVERRIDE;
GO
EXEC sp_configure