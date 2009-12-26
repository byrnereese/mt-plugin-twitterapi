package Melody::API::Twitter::Search;

=head2 search

URL:
http://search.twitter.com/search.format
 
Formats: 
json, atom 
 
HTTP Method:
GET
 
Requires Authentication (about authentication):
false
 
API rate limited (about rate limiting):
1 call per request
 
Parameters:

callback: Optional. Only available for JSON format. If supplied, the response will use the JSONP format with a callback of the given name.

lang: Optional: Restricts tweets to the given language, given by an ISO 639-1 code.

locale: Optional. Specify the language of the query you are sending (only ja is currently effective). This is intended for language-specific clients and the default should work in the majority of cases.

rpp: Optional. The number of tweets to return per page, up to a max of 100.

page: Optional. The page number (starting at 1) to return, up to a max of roughly 1500 results (based on rpp * page. Note: there are pagination limits.

since_id: Optional. Returns tweets with status ids greater than the given id.

geocode: Optional. Returns tweets by users located within a given radius of the given latitude/longitude.  The location is preferentially taking from the Geotagging API, but will fall back to their Twitter profile. The parameter value is specified by "latitide,longitude,radius", where radius units must be specified as either "mi" (miles) or "km" (kilometers). Note that you cannot use the near operator via the API to geocode arbitrary locations; however you can use this geocode parameter to search near geocodes directly.

show_user: Optional. When true, prepends "<user>:" to the beginning of the tweet. This is useful for readers that do not display Atom's author field. The default is false.

JSON example (truncated):
  {"results":[
     {"text":"@twitterapi  http:\/\/tinyurl.com\/ctrefg",
     "to_user_id":396524,
     "to_user":"TwitterAPI",
     "from_user":"jkoum",
     "id":1478555574,   
     "from_user_id":1833773,
     "iso_language_code":"nl",
     "source":"<a href="http:\/\/twitter.com\/">twitter<\/a>",
     "profile_image_url":"http:\/\/s3.amazonaws.com\/twitter_production\/profile_images\/118412707\/2522215727_a5f07da155_b_normal.jpg",
      "created_at":"Wed, 08 Apr 2009 19:22:10 +0000"},
     ... truncated ...],
     "since_id":0,
     "max_id":1480307926,
     "refresh_url":"?since_id=1480307926&q=%40twitterapi",
     "results_per_page":15,
     "next_page":"?page=2&max_id=1480307926&q=%40twitterapi",
     "completed_in":0.031704,
     "page":1,
     "query":"%40twitterapi"}
  }

=cut

sub search {

}

=head2 trends

Variants: trends/(current|daily|weekly)

=cut

sub trends {

}

1;
__END__
