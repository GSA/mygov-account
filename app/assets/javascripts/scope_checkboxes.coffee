# Checks parent scope if needed
set_parent_check = (parent_value, child_id) ->
  i = undefined
  max = undefined
  if document.getElementById(child_id).checked is true
    document.querySelector("[parent_value=" + parent_value + "]").checked = true

  else # sub scope has been unchecked
    i = 0
    max = $("input[parent_scope]").length
    while i < max
      if $("input[parent_scope]")[i].checked
        document.querySelector("[parent_value=" + parent_value + "]").checked = true
        return
      else
        document.querySelector("[parent_value=" + parent_value + "]").checked = false
      i++
  # Disappear sub scope checkboxes on uncheck of last checked.
  $('#camo_' + parent_value).css('display', 'none') if $("input[parent_scope]:checked").length == 0


# Checks or unchecks child boxes, triggered by parent scope change
set_checked = (parent_id, sub_id) ->
  document.getElementById(sub_id).checked = document.getElementById(sub_id).checked

$(document).ready ->  
  # In case of edit page, on page ready prepare, see if parent needs to be checked.
  # This has to be done since we are not saving parent scopes
  $("input[parent_value]").each (i) ->
    parent = $(this)
    $("input[parent_scope=" + $(this).attr("parent_value") + "]").each (i) ->
      document.getElementById(parent.attr("id")).checked = true  if $(this).is(":checked")

  # On page ready prepare each child's on change action.
  $("input[parent_scope]").change (e) ->
    set_parent_check e.target.getAttribute("parent_scope"), e.target.id

  # For each parent, when changed, change children accordingly    
  $("input[parent_value]").each (i) ->
    parent_id = $(this).attr("id")
    $(this).change ->
      $('#camo_' + $(this).attr("parent_value")).css('display', (if document.getElementById(parent_id).checked  == true then "inline" else "none")) 
      $("input[parent_scope=" + $(this).attr("parent_value") + "]").each (i) ->
        document.getElementById($(this).attr("id")).checked = document.getElementById(parent_id).checked


  # On load, appear or disappear a scope block depending on whether a sub scope is checked.
  $("input[parent_value]").each (i) ->
    $('#camo_' + $(this).attr("parent_value")).css('display', (if document.getElementById($(this).attr("id")).checked  == true then "inline" else "none")) 
