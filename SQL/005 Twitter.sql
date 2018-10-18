DECLARE @message NVARCHAR(4000)
      , @con_key NVARCHAR(4000)
      , @con_sec NVARCHAR(4000)
      , @acc_tok NVARCHAR(4000)
      , @acc_sec NVARCHAR(4000);


DECLARE @d INT = DATEDIFF(mi, GETDATE(), '2018-10-18 18:10')
      , @messagein NVARCHAR(4000);



SELECT @messagein
    = CASE
          WHEN @d > 0 THEN
              'Join me and @TheSQLalizer presenting at PASS Manchester Data Platform User Group (@ManSSUG), only '
              + CAST(@d AS VARCHAR) + ' minutes to go. http://bit.ly/24hrDataPeople'
          WHEN @d
               BETWEEN -60 AND 0 THEN
              'Now @ManSSUG is being treated to @TheSQLalizer'
          WHEN @d
               BETWEEN -150 AND -61 THEN
              'I am presenting @ManSSUG RIGHT NOW :-)'
          WHEN @d < -150 THEN
              'Thank you @TheSQLalizer and @ManSSUG, I hope you enjoyed it as much as I did'
          ELSE
              'I am eating pizza'
      END;



SELECT @message = messageout
     , @con_key = con_key
     , @con_sec = con_sec
     , @acc_tok = acc_tok
     , @acc_sec = acc_sec
FROM dbo.GetTweepyAuth(@messagein);


DECLARE @PyScript NVARCHAR(4000)
    = N'
import tweepy
from tweepy import OAuthHandler
mymessage = message
consumer_key = con_key
consumer_secret = con_sec
access_token = acc_tok
access_secret = acc_sec
auth = OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_secret)
api = tweepy.API(auth)

api.update_status(mymessage)';

EXEC sys.sp_execute_external_script @language = N'Python'
                                  , @script = @PyScript
                                  , @params = N'@message NVARCHAR(4000)
      , @con_key NVARCHAR(4000)
      , @con_sec NVARCHAR(4000)
      , @acc_tok NVARCHAR(4000)
      , @acc_sec NVARCHAR(4000)'
                                  , @message = @message
                                  , @con_key = @con_key
                                  , @con_sec = @con_sec
                                  , @acc_tok = @acc_tok
                                  , @acc_sec = @acc_sec;