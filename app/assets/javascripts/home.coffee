form = $ "#new_beta_signup"
msg_confirm = $("#beta_signup_confirmation").html()
msg_fail = $("#beta_signup_failure").html()

init = ->
    form.live 'submit', submit

submit = (e) ->

    e.preventDefault();
    data = {}
    
    #workaround for jQuery serialize not liking the square bracket in the field name
    $.each( form.find('input'), (k,field) ->
        data[ $(field).attr('name') ] = $(field).attr('value')
    )
    data = $.extend( data, { "beta_signup[email]": $('#beta_signup_email').val() } )
    
    $.post( form.attr('action') + '.json', data, (result) ->
        renderResponse( result.result )
    )
    
    false


renderResponse =  (response) ->
    
    el = $ "#signup-form"
    
    if ( response )
        msg = msg_confirm
    else
        msg = msg_fail
    
    el.fadeOut( 'slow', ->
        el.html msg
        el.fadeIn()
        el.focus() #508
    )

$(document).ready ->
    init()