el = $ "#signup-form"
msg = "<p>Thanks for signing up for MyGov! We'll send you an email when you're account is ready.</p>"

el.fadeOut( 'slow', ->
    el.html msg
    el.fadeIn()
    el.focus() #508
)