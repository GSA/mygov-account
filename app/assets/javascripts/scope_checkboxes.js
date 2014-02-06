// Checks parent scope if needed
set_parent_check = function(parent_value, child_id) {
  var i, max;
  if (document.getElementById(child_id).checked === true) {
    return document.querySelector("[parent_value=" + parent_value + "]").checked = true;
  } else {
    i = 0;
    max = $("input[parent_scope]").length;
    while (i < max) {
      if ($("input[parent_scope]")[i].checked) {
        document.querySelector("[parent_value=" + parent_value + "]").checked = true;
        return;
      } else {
        document.querySelector("[parent_value=" + parent_value + "]").checked = false;
      }
      i++;
    }
  }
};

// Checks or unchecks child boxes, triggered by parent scope change
set_checked = function(parent_id, sub_id) {
  return document.getElementById(sub_id).checked = document.getElementById(sub_id).checked;
};

$(document).ready(function() {
  // In case of edit page, on page ready prepare, see if parent needs to be checked.
  // This has to be done since we are not saving parent scopes
  $("input[parent_value]").each(function(i) {
    parent = $(this)
    $("input[parent_scope=" + $(this).attr("parent_value") + "]").each(function(i) {
      if ($(this).is(":checked")){
        document.getElementById(parent.attr('id')).checked = true;
      }
    });
  });
  
  
  // On page ready prepare each child's on change action.
  $("input[parent_scope]").change(function(e) {
    return set_parent_check(e.target.getAttribute("parent_scope"), e.target.id);
  });

  // For each parent, when changed, change children accordingly    
  $("input[parent_value]").each(function(i) {
    parent_id = $(this).attr("id");
    $(this).change(function() {
      $("input[parent_scope=" + $(this).attr("parent_value") + "]").each(function(i) {
        document.getElementById($(this).attr("id")).checked = $("app_app_oauth_scopes_attributes_" + parent_id  + "_oauth_scope_id").is(":checked");
      });
    });
  });
});
