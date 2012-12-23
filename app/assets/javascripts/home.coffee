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