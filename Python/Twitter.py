#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Oct 17 12:31:04 2018

@author: petermoore
"""
message = "This is a tweet!"
con_sec = "rem"
acc_tok = "rem"
acc_sec = "rem"
import tweepy
from tweepy import OAuthHandler
consumer_key = "iQkbcIUGmkhLqLBQb5tonpXjd"
consumer_secret = con_sec
access_token = acc_tok
access_secret = acc_sec
auth = OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_secret)
api = tweepy.API(auth)


api.update_status(message)


##
#