$(document).ready ->
  /mobi/i.test(navigator.userAgent) && !location.hash && setTimeout ->
    if !pageYOffset 
      window.scrollTo 0, 1
  , 1000