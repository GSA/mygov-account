//var sign_in_link = document.getElementById("login_form_submit") ;

// if ( sign_in_link ){
    
//     sign_in_link.addEventListener( "click", 
// 				    function (event) {
// 					encrypt_decrypt_key( password.value ) ;
// 				    }, 
// 				    false) ;
// }

$('#new_user').submit(function() {  

    var valuesToSubmit = $(this).serialize();
    var password = document.getElementById("user_password").value ;

    $.ajax({
        url: $(this).attr('action'), 
        data: valuesToSubmit,
	type: "POST",
        dataType: "JSON" 
    }).success(function(json){
	// decrypt key with password

	if ( json.user_key_storage_name && localStorage[json.user_key_storage_name] ){
	    sessionStorage[json.user_key_storage_name] = encrypt_decrypt_key( json.user_key_storage_name, password ) ;
	}

	window.location.replace(json.after_signin_path) ;
    });
    return false; // prevents normal behaviour
});
