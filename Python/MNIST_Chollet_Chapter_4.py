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

from keras.datasets import imdb
import numpy as np

(train_data, train_labels), (test_data, test_labels) = imdb.load_data(num_words=10000)

def vectorize_sequences(sequences, dimension=10000):
    # Create an all-zero matrix of shape (len(sequences), dimension)
    results = np.zeros((len(sequences), dimension))
    for i, sequence in enumerate(sequences):
        results[i, sequence] = 1.  # set specific indices of results[i] to 1s
    return results

# Our vectorized training data
x_train = vectorize_sequences(train_data)
# Our vectorized test data
x_test = vectorize_sequences(test_data)
# Our vectorized labels
y_train = np.asarray(train_labels).astype('float32')
y_test = np.asarray(test_labels).astype('float32')

# start building a mdoel to detect positivity of review
from keras import models
from keras import layers

# model with 16 units per layer
original_model = models.Sequential()
original_model.add(layers.Dense(16, activation='relu', input_shape=(10000,)))
original_model.add(layers.Dense(16, activation='relu'))
original_model.add(layers.Dense(1, activation='sigmoid'))

original_model.compile(optimizer='rmsprop',
                       loss='binary_crossentropy',
                       metrics=['acc'])

original_hist = original_model.fit(x_train, y_train,
                                   epochs=10,
                                   batch_size=512,
                                   validation_data=(x_test, y_test))


import pandas as pd
df_history = pd.DataFrame.from_dict(original_hist.history)[["val_loss", "val_acc", "loss", "acc"]]



print(df_history)


## model with 4 units per layer
#smaller_model = models.Sequential()
#smaller_model.add(layers.Dense(4, activation='relu', input_shape=(10000,)))
#smaller_model.add(layers.Dense(4, activation='relu'))
#smaller_model.add(layers.Dense(1, activation='sigmoid'))
#
#smaller_model.compile(optimizer='rmsprop',
#                      loss='binary_crossentropy',
#                      metrics=['acc'])
#
#smaller_model_hist = smaller_model.fit(x_train, y_train,
#                                       epochs=10,
#                                       batch_size=512,
#                                       validation_data=(x_test, y_test))
#
#epochs = range(1, 21)
#original_val_loss = original_hist.history['val_loss']
#smaller_model_val_loss = smaller_model_hist.history['val_loss']
#
#
#import matplotlib.pyplot as plt
#
## b+ is for "blue cross"
#plt.plot(epochs, original_val_loss, 'b+', label='Original model')
## "bo" is for "blue dot"
#plt.plot(epochs, smaller_model_val_loss, 'bo', label='Smaller model')
#plt.xlabel('Epochs')
#plt.ylabel('Validation loss')
#plt.legend()
#
#plt.show()
#
#
#original_train_loss = original_hist.history['loss']
#smaller_model_train_loss = smaller_model_hist.history['loss']
#
#plt.plot(epochs, original_train_loss, 'b+', label='Original model')
#plt.plot(epochs, smaller_model_train_loss, 'bo', label='smaller model')
#plt.xlabel('Epochs')
#plt.ylabel('Training loss')
#plt.legend()
#
#plt.show()



#bigger_model = models.Sequential()
#bigger_model.add(layers.Dense(512, activation='relu', input_shape=(10000,)))
#bigger_model.add(layers.Dense(512, activation='relu'))
#bigger_model.add(layers.Dense(1, activation='sigmoid'))
#
#bigger_model.compile(optimizer='rmsprop',
#                     loss='binary_crossentropy',
#                     metrics=['acc'])
#
#
#bigger_model_hist = bigger_model.fit(x_train, y_train,
#                                     epochs=20,
#                                     batch_size=512,
#                                     validation_data=(x_test, y_test))
#
#
#bigger_model_val_loss = bigger_model_hist.history['val_loss']
#
#plt.plot(epochs, original_val_loss, 'b+', label='Original model')
#plt.plot(epochs, bigger_model_val_loss, 'bo', label='Bigger model')
#plt.xlabel('Epochs')
#plt.ylabel('Validation loss')
#plt.legend()
#
#plt.show()
## Occam's razor!
#
#
#original_train_loss = original_hist.history['loss']
#bigger_model_train_loss = bigger_model_hist.history['loss']
#
#plt.plot(epochs, original_train_loss, 'b+', label='Original model')
#plt.plot(epochs, bigger_model_train_loss, 'bo', label='Bigger model')
#plt.xlabel('Epochs')
#plt.ylabel('Training loss')
#plt.legend()
#
#plt.show()
