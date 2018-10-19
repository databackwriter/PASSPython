--do something in  Python
EXEC sys.sp_execute_external_script @language = N'R', 
@script = N'print(3+4)'
GO

--What version are we running
EXEC sys.sp_execute_external_script @language = N'Python', 
@script = N'import sys
pyversion = sys.version
print(pyversion)'




--Simple import worked here
EXEC sys.sp_execute_external_script @language = N'Python', 
@script = N'import sys'


--But what about  here
EXEC sys.sp_execute_external_script @language = N'Python', 
@script = N'import ant'

