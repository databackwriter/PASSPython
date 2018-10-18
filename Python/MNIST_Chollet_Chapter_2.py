#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 18 10:27:31 2018

@author: petermoore

Adapted from jupyter notebook at https://github.com/fchollet/deep-learning-with-python-notebooks/blob/master/2.1-a-first-look-at-a-neural-network.ipynb

See also: François Chollet. Deep Learning with Python. Manning Publications.
"""

# get the mnist data set
# these are a set of handwritten digits see: http://yann.lecun.com/exdb/mnist/
from keras.datasets import mnist

# extract training and test numpy tensors (arrays)
(train_images, train_labels), (test_images, test_labels) = mnist.load_data()


# build the network
from keras import models
from keras import layers

# conceptually non-trivial terms are: Sequential, relu and softmax
# conceptually non-trivial numbers are: 512, 28*28 and 10
network = models.Sequential()
network.add(layers.Dense(512, activation='relu', input_shape=(28 * 28,)))
network.add(layers.Dense(10, activation='softmax'))


# conceptually non-trivial terms are: rmsprop, categorical_crossentropy and accuracy
network.compile(optimizer='rmsprop',    # optimizer: this is the mechanism through
                                        # which the network will update itself based
                                        # on the data it sees and its loss function PMEXP
                loss='categorical_crossentropy',    # loss function: the is how the network
                                                    # will be able to measure how good a job
                                                    # it is doing on its training data, and
                                                    # thus how it will be able to steer itself in the
                                                    # right direction. PMEXP
                metrics=['accuracy'])


# now we take the training image and change the shape (NB this is a one-to-one from 28,28:->28*28)
train_images = train_images.reshape((60000, 28 * 28))
# then normalise the pixel rgb
train_images = train_images.astype('float32') / 255
# do same for test set
test_images = test_images.reshape((10000, 28 * 28))
test_images = test_images.astype('float32') / 255

# encode the labels. that is, instead of having 0123456789, move to [1,0,0,...], [0,1,...] (see also: one hot encoding)
from keras.utils import to_categorical
train_labels = to_categorical(train_labels)
test_labels = to_categorical(test_labels)

# believe it or not, we are now, with indecent haste, ready to train our model
# NB this is a minor diversion from chapter 2 of the book because we are retainging the history here
history = network.fit(train_images, train_labels, epochs=3, batch_size=128)

# viewing results gives us an accuracy of 0.9890
# lets veer off piste and make a data frame of our dictionary
import pandas as pd
df_history = pd.DataFrame.from_dict(history.history)



# so that's what training got *against itself* (NB no validation set here)
test_loss, test_acc = network.evaluate(test_images, test_labels)

x = network.evaluate(test_images, test_labels)
df_testdetails = pd.DataFrame(x).transpose