#Primary beta signup form logic
class MyGovBetaSignup

    form:        $ "#new_beta_signup"
    el:          "#signup-form"
    el_html:     ''
    msg_confirm: $("#beta_signup_confirmation").html()
    msg_fail:    $("#beta_signup_failure").html()
    msg_invalid_email: $("#beta_signup_invalid_email").html()
    msg_duplicate_email: $("#beta_signup_duplicate_email").html()
    msg_blank_email: $("#beta_signup_blank_email").html()
    
    init: ->
        MyGovBetaSignup.prototype.el_html = $(@el).html()
        @form.live 'submit', @submit
        $('#try_again').live 'click', @reset
    
    submit: (e) =>
        e.preventDefault();
        data = {}
        #workaround for jQuery serialize not liking the square bracket in the field name
        $.each( @form.find('input'), (k,field) ->
            data[ $(field).attr('name') ] = $(field).attr('value')
        )
        data = $.extend( data, { "beta_signup[email]": $('#beta_signup_email').val() } )
        $.post( @form.attr('action') + '.json', data, (result) =>
            @renderResponse( result )
        )
        false
    
    renderResponse: (response) =>    
        if ( response && response.result == "success" )
            msg = @msg_confirm
        else if ( response.result == "invalid email" )
            msg = @msg_invalid_email
        else if ( response.result == "duplicate email" )
            msg = @msg_duplicate_email
        else if ( response.result == "blank email" )
            msg = @msg_blank_email
        else
            msg = response.result
        @transition msg
           
    reset: (e) =>
        
        if (e)
            e.preventDefault()
            
        @transition @el_html
        false
        
    transition: (html) ->
        el = $(@el)
        el.fadeOut( 'slow', ->
            el.html html
            el.fadeIn()
            el.focus() #508
        )    
        
$(document).ready ->
    window.betaSignup = new MyGovBetaSignup
    betaSignup.init()
    
#end signup code... not sure what this stuff is -BB

$.rails.allowAction = (link) ->
  return true unless link.attr('data-confirm')
  $.rails.showConfirmDialog(link) # look bellow for implementations
  false # always stops the action since code runs asynchronously

$.rails.confirmed = (link) ->
  link.removeAttr('data-confirm')
  link.trigger('click.rails')

$.rails.showConfirmDialog = (link) ->
  message = link.attr 'data-confirm'
  html = """
    <div id="confirmationDialog" class="reveal-modal small">
      <h2>Are you sure?</h2>
      <p>#{message}</p>
      <a data-dismiss="modal" class="button positive confirm">OK</a>
      <a class="close-reveal-modal">&#215;</a>
    </div>
  """
  $("body").append(html)
  $("#confirmationDialog").reveal()
  $('#confirmationDialog .confirm').on 'click', -> $.rails.confirmed(link)