--dynamic SQL
DECLARE @S NVARCHAR(128) = 'SELECT  1 * 6';
EXEC sys.sp_executeSQL @stmt = @S;
GO





--dynamic SQL with variable
DECLARE @P INT = 2;
DECLARE @S1 NVARCHAR(128) = 'SELECT  @P * 6';
EXEC sys.sp_executeSQL @stmt = @S1, @params = N'@P INT', @P = @P;
GO





--dynamic SQL with output variable
DECLARE @P1 INT = 3;
DECLARE @S2 NVARCHAR(128) = 'SELECT @Q = @P1 * 6';
DECLARE @Q INT;
EXEC sys.sp_executeSQL @stmt = @S2
                     , @params = N'@P1 INT, @Q INT OUTPUT'
                     , @P1 = @P1
                     , @Q = @Q OUTPUT;
SELECT @Q;
GO





--dynamic SQL with results sets
DECLARE @S3 NVARCHAR(128) = 'SELECT  4 * 6';
EXEC sys.sp_executeSQL @stmt = @S3 WITH RESULT SETS ((S3out INT));












--Do something in Python with future use  (NB there is a bit of assumption here)
DECLARE @S INT = 3
      , @myvar INT;
EXEC sys.sp_execute_external_script @language = N'Python'
                                  , @script = N'myvar = S+4;'
                                  , @params = N'@S INT, @myvar INT OUTPUT'
                                  , @S = @S
                                  , @myvar = @myvar OUTPUT;

PRINT @myvar;


--get some data out
EXECUTE sp_execute_external_script @language = N'Python'
                                 , @script = N'
MyOutput = MyInput
'
                                 , @input_data_1_name = N'MyInput'
                                 , @input_data_1 = N'SELECT 1 as Col1'
                                 , @output_data_1_name = N'MyOutput'
WITH RESULT SETS
(
    (
        ResultValue INT
    )
);