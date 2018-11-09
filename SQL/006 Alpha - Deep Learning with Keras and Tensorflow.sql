--ALTER RESOURCE GOVERNOR RECONFIGURE;

GO
DROP TABLE IF EXISTS dbo.DimEpoch;
GO

CREATE TABLE dbo.DimEpoch
(
    EpochKey INT PRIMARY KEY IDENTITY(1, 1)
  , Epochs INT
);
GO


DROP TABLE IF EXISTS dbo.DimArraySize;
GO

CREATE TABLE dbo.DimArraySize
(
    ArraySizeKey INT PRIMARY KEY IDENTITY(1, 1)
  , ArraySize INT NOT NULL
);
GO
DROP TABLE IF EXISTS dbo.FactIMDBLearn;
GO
CREATE TABLE dbo.FactIMDBLearn
(
    ArraySizeKey INT NOT NULL
  , EpochKey INT NOT NULL
  , IndividualEpoch INT NOT NULL
  , ValidationLoss FLOAT NOT NULL
  , ValidationAccuracy FLOAT NOT NULL
  , Loss FLOAT NOT NULL
  , Accuracy FLOAT NOT NULL
  ,
  PRIMARY KEY (
                  ArraySizeKey
                , EpochKey
                , IndividualEpoch
              )
);



GO
DROP PROCEDURE IF EXISTS dbo.BuildIMDBModel;
GO
CREATE PROCEDURE dbo.BuildIMDBModel
    @Epochs INT
  , @ArraySize INT
AS
PRINT 'Train model machine with ' + CAST(@Epochs AS VARCHAR) + ' with an array size of ' +  CAST(@ArraySize AS VARCHAR)
DECLARE @PyScript NVARCHAR(4000)
    = N'
# get data from IMDB and train a model to predict whether it is any good
# See Chollet chapters 3 and 4

# from Chollet
def vectorize_sequences(sequences, dimension=10000):
    # Create an all-zero matrix of shape (len(sequences), dimension)
    results = np.zeros((len(sequences), dimension))
    for i, sequence in enumerate(sequences):
        results[i, sequence] = 1.  # set specific indices of results[i] to 1s
    return results

# Pete Moore function for building a mdoel to detect positivity of review
def CreateModel(x_train, x_test, y_train, y_test, size_layer1_2,
                epochs=20,
                batch_size=512,
                activation_layer1_2 = "relu",
                activation_layer3 = "sigmoid",
                optimizer="rmsprop",
                loss="binary_crossentropy",
                metrics=["acc"]
                ):
    from keras import models
    from keras import layers

    # model with 16 units per layer
    original_model = models.Sequential()
    original_model.add(layers.Dense(size_layer1_2, activation=activation_layer1_2, input_shape=(10000,)))
    original_model.add(layers.Dense(size_layer1_2, activation=activation_layer1_2))
    original_model.add(layers.Dense(1, activation=activation_layer3))

    original_model.compile(optimizer="rmsprop",
                           loss="binary_crossentropy",
                           metrics=["acc"])

    #original_hist
    return original_model.fit(x_train, y_train,
                                       epochs=epochs,
                                       batch_size=batch_size,
                                       validation_data=(x_test, y_test))

# get the IMDB data
from keras.datasets import imdb
import numpy as np
import pandas as pd
(train_data, train_labels), (test_data, test_labels) = imdb.load_data(num_words=10000)

# Our vectorized training data
x_train = vectorize_sequences(train_data)
# Our vectorized test data
x_test = vectorize_sequences(test_data)
# Our vectorized labels
y_train = np.asarray(train_labels).astype("float32")
y_test = np.asarray(test_labels).astype("float32")

mysize=ArraySize
myepochs=Epochs
history = CreateModel(x_train, x_test, y_train, y_test, size_layer1_2 = mysize,epochs = myepochs)

df_history = pd.DataFrame.from_dict(history.history)[["val_loss", "val_acc", "loss", "acc"]]
    
    ';
EXEC sys.sp_execute_external_script @language = N'Python'
                                  , @script = @PyScript
                                  , @output_data_1_name = N'df_history'
                                  , @params = N'@Epochs INT, @ArraySize INT'
                                  , @Epochs = @Epochs
                                  , @ArraySize = @ArraySize
WITH RESULT SETS
(
    (
        ValidationLoss FLOAT NOT NULL
      , ValidationAccuracy FLOAT NOT NULL
      , Loss FLOAT NOT NULL
      , Accuracy FLOAT NOT NULL
    )
);


GO
CREATE TABLE dbo.#Results
(
    MyID INT IDENTITY(1, 1) PRIMARY KEY NOT NULL
  , ValidationLoss FLOAT NOT NULL
  , ValidationAccuracy FLOAT NOT NULL
  , Loss FLOAT NOT NULL
  , Accuracy FLOAT NOT NULL
);
DECLARE @Epochs INT = 20
      , @ArraySize INT ;

WHILE @Epochs <= 21	 --change for a deeper experiment
BEGIN
    SELECT @ArraySize = 16;
    WHILE @ArraySize <= 512			 --change for a deeper experiment
    BEGIN
        DBCC FREESYSTEMCACHE('ALL') WITH MARK_IN_USE_FOR_REMOVAL;

        TRUNCATE TABLE dbo.#Results;

        INSERT INTO dbo.#Results
        EXEC dbo.BuildIMDBModel @Epochs = @Epochs, @ArraySize = @ArraySize;

        DECLARE @EpochKey INT = NULL;
		SELECT @EpochKey = de.EpochKey 
		FROM dbo.DimEpoch AS de 
		WHERE de.Epochs = @Epochs;
        IF @EpochKey IS NULL
		BEGIN
            INSERT INTO dbo.DimEpoch
            (
                Epochs
            )
            VALUES
            (@Epochs);
			SET @EpochKey = SCOPE_IDENTITY();
		END
        DECLARE @ArraySizeKey INT = NULL;

        SELECT @ArraySizeKey = de.ArraySizeKey
        FROM dbo.DimArraySize AS de
        WHERE de.ArraySize = @ArraySize;

        IF @ArraySizeKey IS NULL
		BEGIN
            INSERT INTO dbo.DimArraySize
            (
                ArraySize
            )
            VALUES
            (@ArraySize);
			SET @ArraySizeKey = SCOPE_IDENTITY();
		END

        INSERT INTO dbo.FactIMDBLearn
        (
            ArraySizeKey
          , EpochKey
          , IndividualEpoch
          , ValidationLoss
          , ValidationAccuracy
          , Loss
          , Accuracy
        )
        SELECT @EpochKey
             , @ArraySizeKey
             , r.MyID
             , r.ValidationLoss
             , r.ValidationAccuracy
             , r.Loss
             , r.Accuracy
        FROM dbo.#Results AS r;
        PRINT @ArraySize;
        SELECT @ArraySize = (@ArraySize * 2);
    END;

    SELECT @Epochs += 4;
END;

DROP TABLE dbo.#Results;

SELECT *
FROM dbo.FactIMDBLearn;


