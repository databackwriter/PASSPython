#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 18 12:42:20 2018

@author: petermoore
"""

#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 18 10:27:31 2018

@author: petermoore

This is a model called Machine vs Overfitting

# THE BIG CHALLENGE IS GENERALISATION NOT FITTING

Adapted from jupyter notebook at https://github.com/fchollet/deep-learning-with-python-notebooks/blob/master/4.4-overfitting-and-underfitting.ipynb

See also: François Chollet. Deep Learning with Python. Manning Publications.
"""

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

mysize=16
myepochs=5
history = CreateModel(x_train, x_test, y_train, y_test, size_layer1_2 = mysize,epochs = myepochs)

df_history = pd.DataFrame.from_dict(history.history)

print(df_history)


# Occam"s razor!
