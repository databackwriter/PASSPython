#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Oct 17 12:31:04 2018

@author: petermoore
"""
message = "2/2Updating using OAuth authentication via Tweepy!"
con_sec = "ozbVURIAUTqRkeVE31gzw8vhf3Od3oY2oM45L5aL5EiNqXE3TI"
acc_tok = "54530145-LUHaQY9lWRNJicKg16bOaeQKL51ohNTgXBlHzrAjO"
acc_sec = "yql7bFUheCIoxXn4OaJmtwQcbIrzSukT4KImlEfjfLVGI"
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
