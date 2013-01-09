class YourGovernment
  
  feeds: $('div.twelve').find('div.twitter-feed')
  
  constructor: ->
    @renderFeed feed for feed in @feeds 
  
  renderFeed: (feed) ->
    $(feed).tweet
      username: feed.id
      avatar_size: 32
      count: 4
      loading_text: "loading tweets..."

new YourGovernment()