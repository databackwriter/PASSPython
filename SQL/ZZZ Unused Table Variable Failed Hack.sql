DROP PROCEDURE IF EXISTS dbo.usp_Sample;
GO
DROP TYPE IF EXISTS udtt_Sample;
GO
CREATE TYPE udtt_Sample AS TABLE
(
    LocalID INT
  , LocalValue NVARCHAR(255)
  ,
  PRIMARY KEY (LocalID)
);
GO
CREATE PROCEDURE dbo.usp_Sample @q udtt_Sample READONLY
AS
SELECT x.LocalID
     , x.LocalValue
FROM @q x;
GO
DECLARE @p udtt_Sample;

INSERT INTO @p
(
    LocalID
  , LocalValue
)
VALUES
(1, 'Leeds')
, (2, 'Manchester')
, (3, 'Birmingham');

EXEC dbo.usp_Sample @q = @p -- udtt_Sample
;
--GO

--CREATE PROCEDURE dbo.usp_Sample_Broken @q udtt_Sample READONLY OUTPUT
--AS
--SELECT x.LocalID
--     , x.LocalValue
--FROM @q x;



--what about with Python?
EXEC sys.sp_execute_external_script @language = N'Python', 
@script = N'OutputDataSet=InputDataSet',
@input_data_1 = @p	   --fails