--the canon
DROP TABLE IF EXISTS iris_data;
GO
CREATE TABLE iris_data
(
    id INT NOT NULL IDENTITY PRIMARY KEY
  , "Sepal.Length" FLOAT NOT NULL
  , "Sepal.Width" FLOAT NOT NULL
  , "Petal.Length" FLOAT NOT NULL
  , "Petal.Width" FLOAT NOT NULL
  , "Species" VARCHAR(100) NOT NULL
  , "SpeciesId" INT NOT NULL
);

DROP TABLE IF EXISTS iris_models;
GO

CREATE TABLE iris_models
(
    model_name VARCHAR(50) NOT NULL
        DEFAULT ('default model') PRIMARY KEY
  , model VARBINARY(MAX) NOT NULL
);
GO
DROP PROCEDURE IF EXISTS get_iris_dataset;
GO
CREATE PROCEDURE get_iris_dataset
AS
BEGIN
    EXEC sp_execute_external_script @language = N'Python'
                                  , @script = N'
from sklearn import datasets
iris = datasets.load_iris()
iris_data = pandas.DataFrame(iris.data)
iris_data["Species"] = pandas.Categorical.from_codes(iris.target, iris.target_names)
iris_data["SpeciesId"] = iris.target
'
                                  , @input_data_1 = N''
                                  , @output_data_1_name = N'iris_data'
    WITH RESULT SETS
    (
        (
            "Sepal.Length" FLOAT NOT NULL
          , "Sepal.Width" FLOAT NOT NULL
          , "Petal.Length" FLOAT NOT NULL
          , "Petal.Width" FLOAT NOT NULL
          , "Species" VARCHAR(100) NOT NULL
          , "SpeciesId" INT NOT NULL
        )
    );
END;
GO
--populate data
INSERT INTO iris_data
(
    "Sepal.Length"
  , "Sepal.Width"
  , "Petal.Length"
  , "Petal.Width"
  , "Species"
  , "SpeciesId"
)
EXEC dbo.get_iris_dataset;
GO
DROP PROCEDURE IF EXISTS generate_iris_model;
GO
CREATE PROCEDURE generate_iris_model
(@trained_model VARBINARY(MAX) OUTPUT)
AS
BEGIN
    EXEC sp_execute_external_script @language = N'Python'
                                  , @script = N'
import pickle
from sklearn.naive_bayes import GaussianNB
GNB = GaussianNB()
trained_model = pickle.dumps(GNB.fit(iris_data[[0,1,2,3]], iris_data[[4]]))
'
                                  , @input_data_1 = N'select "Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width", "SpeciesId" from iris_data'
                                  , @input_data_1_name = N'iris_data'
                                  , @params = N'@trained_model varbinary(max) OUTPUT'
                                  , @trained_model = @trained_model OUTPUT;
END;
GO

DECLARE @model VARBINARY(MAX);
DECLARE @new_model_name VARCHAR(50);
SET @new_model_name = 'Naive Bayes ' + CAST(GETDATE() AS VARCHAR);
--SELECT @new_model_name;
EXEC generate_iris_model @model OUTPUT;
INSERT INTO iris_models
(
    model_name
  , model
)
VALUES
(@new_model_name, @model);


--SELECT *
--FROM iris_models;
GO
DROP PROCEDURE IF EXISTS predict_species;
GO
CREATE PROCEDURE predict_species
(@model VARCHAR(100))
AS
BEGIN
    DECLARE @nb_model VARBINARY(MAX) =
            (
                SELECT model FROM iris_models WHERE model_name = @model
            );
    EXEC sp_execute_external_script @language = N'Python'
                                  , @script = N'
import pickle
irismodel = pickle.loads(nb_model)
species_pred = irismodel.predict(iris_data[[1,2,3,4]])
iris_data["PredictedSpecies"] = species_pred
OutputDataSet = iris_data.query( ''PredictedSpecies != SpeciesId'' )[[0, 5, 6]]
print(OutputDataSet)
'
                                  , @input_data_1 = N'select id, "Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width", "SpeciesId" from iris_data'
                                  , @input_data_1_name = N'iris_data'
                                  , @params = N'@nb_model varbinary(max)'
                                  , @nb_model = @nb_model
    WITH RESULT SETS
    (
        (
            "id" INT
          , "SpeciesId" INT
          , "SpeciesId.Predicted" INT
        )
    );
END;
GO

DECLARE @modelname VARCHAR(100) = (SELECT TOP 1 model_name FROM iris_models)
EXEC predict_species @model = @modelname



GO