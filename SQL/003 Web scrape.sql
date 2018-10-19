--pre-requisites
--BeautifulSoup
--requests
--urllib3
--visit wf.msc ... outbound rules ... 	 see https://docs.microsoft.com/en-us/sql/advanced-analytics/security/firewall-configuration?view=sql-server-2017

DROP TABLE IF EXISTS PremierLeague;
GO

CREATE TABLE dbo.PremierLeague
(
    Position INT PRIMARY KEY NOT NULL
  , Team VARCHAR(255) NULL
  , Played INT NULL
  , Won INT NULL
  , Drawn INT NULL
  , Lost INT NULL
  , GoalsFor INT NULL
  , GoalsAgainst INT NULL
  , GoalDifference INT NULL
  , Points INT NULL
  , RecentForm NVARCHAR(MAX)
);
GO
DROP PROCEDURE  IF EXISTS dbo.GetPremierLeague
GO
CREATE PROCEDURE dbo.GetPremierLeague
AS
DECLARE @PyScript NVARCHAR(4000)
    = N'
import pandas as pd
import numpy as np
from bs4 import BeautifulSoup
import requests

url="https://www.theguardian.com/football/premierleague/table"
response = requests.get(url)
html = response.text
soup = BeautifulSoup(html, "html.parser")

localclass="table table--football table--league-table table--responsive-font table--striped"
tablestats = soup.find("table", attrs={"class":localclass})

df = pd.DataFrame(np.nan, index=range(0,20), columns = ["P","Team","GP","W","D","L","F","A","GD","Pts","Form"],dtype=np.str)
rows = tablestats.find_all("tr")
row_marker = 0
for row in rows:
    column_marker = 0
    columns = row.find_all("td")
    if (len(columns)) >0: # ie not the header row
        for column in columns:
            columnentrant = column.get_text().replace("\n", "")
            df.iat[row_marker,column_marker] = columnentrant
            column_marker += 1
        row_marker +=1

';
EXEC sys.sp_execute_external_script @language = N'Python'
                                  , @script = @PyScript
                                  , @output_data_1_name = N'df'
WITH RESULT SETS
(
    (
        Position INT
      , Team VARCHAR(255)
      , Played INT
      , Won INT
      , Drawn INT
      , Lost INT
      , GoalsFor INT
      , GoalsAgainst INT
      , GoalDifference INT
      , Points INT
      , RecentForm NVARCHAR(MAX)
    )
);

GO

INSERT INTO dbo.PremierLeague
(
    Position
  , Team
  , Played
  , Won
  , Drawn
  , Lost
  , GoalsFor
  , GoalsAgainst
  , GoalDifference
  , Points
  , RecentForm
)
EXEC dbo.GetPremierLeague;
