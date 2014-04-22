/***
* TOOLTIPS
***/

$('label[for="user_password"]').css('float','left');

$("#tip-password").attr("aria-hidden","true");

$("input#user_password").mouseover(function(){
  $("#tip-password").attr("aria-hidden","false").addClass("hidden");
});

$("input#user_password").mouseleave(function(){
  $("#tip-password").attr("aria-hidden","true").removeClass("hidden");
});

// Keyboard: Focus
$("input#user_password").focus(function(){
  $("#tip-password").attr("aria-hidden","false");
});

$("input#user_password").blur(function(){
  $("#tip-password").attr("aria-hidden","true");
});

// Keyboard: Esc
$("input#user_password").keydown(function(e){
  if (e.which == 27) {
    $("#tip-password").attr("aria-hidden","true");
    e.preventDefault();
    return false;
  }
});


$('label[for="user_zip"]').css('float','left');

$("#tip-zip").attr("aria-hidden","true");

$("input#user_zip").mouseover(function(){
  $("#tip-zip").attr("aria-hidden","false").addClass("hidden");
});

$("input#user_zip").mouseleave(function(){
  $("#tip-zip").attr("aria-hidden","true").removeClass("hidden");
});

// Keyboard: Focus
$("input#user_zip").focus(function(){
  $("#tip-zip").attr("aria-hidden","false");
});

$("input#user_zip").blur(function(){
  $("#tip-zip").attr("aria-hidden","true");
});

// Keyboard: Esc
$("input#user_zip").keydown(function(e){
  if (e.which == 27) {
    $("#tip-zip").attr("aria-hidden","true");
    e.preventDefault();
    return false;
  }
});
