ALTER VIEW dbo.vPremierLeague
AS
    SELECT Team
         , Position
         , GoalsFor
         , GoalsAgainst
         , CASE Position / 7
               WHEN 0 THEN
                   'Top Third'
               WHEN 1 THEN
                   'Middle Third'
               ELSE
                   'Bottom Third'
           END AS TableSection
    FROM PremierLeague
    GO


SELECT u.TableSection
     , AVG(GoalsAgainst) AS MeanConceded
FROM vPremierLeague	 u
GROUP BY u.TableSection
ORDER BY MeanConceded;


EXEC sys.sp_execute_external_script @language = N'Python'
                              , @script = N'
OutputDataSet= VPL.groupby(VPL["TableSection"])[["GoalsAgainst"]].median()
print(OutputDataSet)
'
, @input_data_1 = N'select * from vPremierLeague'
, @input_data_1_name = N'VPL';



