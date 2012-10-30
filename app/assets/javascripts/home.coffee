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

$(document).ready ->
    init()