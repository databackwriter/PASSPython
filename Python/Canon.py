# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
import pandas
from sklearn import datasets
iris = datasets.load_iris()
iris_data = pandas.DataFrame(iris.data)
iris_data["Species"] = pandas.Categorical.from_codes(iris.target, iris.target_names)
iris_data["SpeciesId"] = iris.target



import pickle
from sklearn.naive_bayes import GaussianNB
GNB = GaussianNB()
trained_model = pickle.dumps(GNB.fit(iris_data[[0,1,2,3]], iris_data[["Species"]]))



irismodel = pickle.loads(trained_model)
species_pred = irismodel.predict(iris_data[[0,1,2,3]])
iris_data["PredictedSpecies"] = species_pred
OutputDataSet = iris_data.query("PredictedSpecies != Species")[[0, "Species", "PredictedSpecies"]]

print(OutputDataSet)


OutputDataSet = iris_data.groupby(["Species"])[[0]].median()