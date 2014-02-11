# Checks parent scope if needed
set_parent_check = (parent_value, child_id) ->
  i = undefined
  max = undefined
  if document.getElementById(child_id).checked is true
    document.querySelector("[parent_value=" + parent_value + "]").checked = true
  else
    i = 0
    max = $("input[parent_scope]").length
    while i < max
      if $("input[parent_scope]")[i].checked
        document.querySelector("[parent_value=" + parent_value + "]").checked = true
        return
      else
        document.querySelector("[parent_value=" + parent_value + "]").checked = false
      i++
  return


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
      return

    return

  
  # On page ready prepare each child's on change action.
  $("input[parent_scope]").change (e) ->
    set_parent_check e.target.getAttribute("parent_scope"), e.target.id

  
  # For each parent, when changed, change children accordingly    
  $("input[parent_value]").each (i) ->
    parent_id = $(this).attr("id")
    $(this).change ->
      $("input[parent_scope=" + $(this).attr("parent_value") + "]").each (i) ->
        document.getElementById($(this).attr("id")).checked = document.getElementById(parent_id).checked 
        return

      return

    return

  return
