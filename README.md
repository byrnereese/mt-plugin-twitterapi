# Setup & Installation

This .htaccess recipe is essential to this API working.

    RewriteEngine On
    RewriteCond %{HTTP:Authorization}  ^(.*)
    RewriteRule ^/(.*)$ /var/www/cgi-bin/mt/twitter.cgi/$1 [e=HTTP_AUTHORIZATION:%1,t=application/x-httpd-cgi,l]
    RewriteRule ^/(.*)$ http://localhost/cgi-bin/mt/twitter.cgi/$1 [L,P,QSA]

# Usage

# TODO

Below is a listing of all Twitter API methods and whether they have been
fully implemented or not.

## Search API Methods - 0%

* search
* trends
* trends/current
* trends/daily
* trends/weekly 
 
## Timeline Methods - 50%

* statuses/public_timeline - 100%
* statuses/home_timeline - 100%
* statuses/friends_timeline - 100%
* statuses/user_timeline - 100%

* statuses/mentions - 0%
* statuses/retweeted_by_me - 0%
* statuses/retweeted_to_me - 0%
* statuses/retweets_of_me - 0%
 
## Status Methods - 70%

* statuses/show - 100%
* statuses/update - 100%
* statuses/destroy - 100%
* statuses/friends - 90%
* statuses/followers - 90%
* statuses/retweet - 0%
* statuses/retweets - 0%
 
## User Methods - 50%

* users/show - 100%
* users/search
 
## List Methods - 0%

* POST lists      (create)
* POST lists id  (update)
* GET lists        (index)
* GET list id      (show)
* DELETE list id (destroy)
* GET list statuses
* GET list memberships
* GET list subscriptions
 
## List Members Methods - 0%

* GET list members
* POST list members
* DELETE list members
* GET list members id
 
## List Subscribers Methods - 0%

* GET list subscribers
* POST list subscribers
* DELETE list subscribers
* GET list subscribers id
 
## Direct Message Methods - 0%

* direct_messages
* direct_messages/sent
* direct_messages/new
* direct_messages/destroy 
 
## Friendship Methods - 100%

* friendships/create - 100%
* friendships/destroy - 100%
* friendships/exists - 100%
* friendships/show - 100%
 
## Social Graph Methods - 0%

* friends/ids   
* followers/ids 
 
## Account Methods - 10%

* account/verify_credentials - 100%
* account/rate_limit_status
* account/end_session
* account/update_delivery_device 
* account/update_profile_colors 
* account/update_profile_image 
* account/update_profile_background_image
* account/update_profile 
 
## Favorite Methods - 100%

* favorites - 100%
* favorites/create - 100%  
* favorites/destroy - 100%
 
## Notification Methods - 0%

* notifications/follow 
* notifications/leave 
 
## Block Methods - 0%

* blocks/create  
* blocks/destroy
* blocks/exists
* blocks/blocking
* blocks/blocking/ids
 
## Spam Reporting Methods - 0%

* report_spam
 
## Saved Searches Methods - 0%

* saved_searches
* saved_searches/show
* saved_searches/create
* saved_searches/destroy
 
## OAuth Methods - 0%

* oauth/request_token
* oauth/authorize
* oauth/authenticate
* oauth/access_token
  
## Help Methods - 100%

* help/test
 