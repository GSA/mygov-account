encrypt_encrypt_form = function( form ){

    console.log( "Encryption before submit: " + form.profile_is_encrypted.defaultChecked ) ;

    if ( form.profile_is_encrypted.checked && !form.profile_is_encrypted.defaultChecked ){

	if ( sessionStorage )
	{
	    var key_name = form.user_key_storage_name.value ;
	    
	    if ( key_name ){
		
		var key = sjcl.codec.hex.toBits(sessionStorage[key_name]) ;
		var blockCipher = new sjcl.cipher.aes( key ) ;
		
		if ( key ){
		    
		    if ( form.profile_first_name.value  && 
			 ( form.profile_first_name.value != form.profile_first_name.defaultValue || !form.profile_is_encrypted.defaultChecked) ){
			var enc_first_name = encrypt_encrypt_string(form.profile_first_name.value, key);
			form.profile_first_name.value = enc_first_name ;
		    }
		    
		    if ( form.profile_middle_name.value && 
			 ( form.profile_middle_name.value != form.profile_middle_name.defaultValue || !form.profile_is_encrypted.defaultChecked)){
			var enc_middle_name = encrypt_encrypt_string(form.profile_middle_name.value, key);
			form.profile_middle_name.value = enc_middle_name ;
		    }
		    
		    if ( form.profile_last_name.value && 
			 ( form.profile_last_name.value != form.profile_last_name.defaultValue || !form.profile_is_encrypted.defaultChecked)){
			var enc_last_name = encrypt_encrypt_string(form.profile_last_name.value, key);
			form.profile_last_name.value = enc_last_name ;
		    }
		    
		    if ( form.profile_address.value && 
			 ( form.profile_address.value != form.profile_address.defaultValue || !form.profile_is_encrypted.defaultChecked)){
			var enc_address = encrypt_encrypt_string(form.profile_address.value, key);
			form.profile_address.value = enc_address ;
		    }		

		    if ( form.profile_address2.value && 
			 ( form.profile_address2.value != form.profile_address2.defaultValue || !form.profile_is_encrypted.defaultChecked)){
			var enc_address2 = encrypt_encrypt_string(form.profile_address2.value, key);
			form.profile_address2.value = enc_address2 ;
		    }
		    
		    if ( form.profile_city.value && 
			 ( form.profile_city.value != form.profile_city.defaultValue || !form.profile_is_encrypted.defaultChecked)){
			var enc_city = encrypt_encrypt_string(form.profile_city.value, key);
			form.profile_city.value = enc_city ;
		    }
		    
		    // @@TODO: fix the check for default value changed

//		    if ( form.profile_state.value && ( form.profile_state.value != form.profile_state.defaultValue || !form.profile_is_encrypted.defaultChecked)){
//			var enc_state = encrypt_encrypt_string(form.profile_state.value, key);
//			form.profile_state.value = enc_state ;
//		    }
		    
		    if ( form.profile_zip.value && ( form.profile_zip.value != form.profile_zip.defaultValue || !form.profile_is_encrypted.defaultChecked)){
			var enc_zip = encrypt_encrypt_string(form.profile_zip.value, key);
			form.profile_zip.value = enc_zip ;
		    }
		    
		    if ( form.profile_phone_number.value && ( form.profile_phone_number.value != form.profile_phone_number.defaultValue || !form.profile_is_encrypted.defaultChecked)) {
			var enc_phone = encrypt_encrypt_string(form.profile_phone_number.value, key);
			form.profile_phone_number.value = enc_phone ;
		    }
		    
		    if ( form.profile_mobile_number.value && ( form.profile_mobile_number.value != form.profile_mobile_number.defaultValue || !form.profile_is_encrypted.defaultChecked)){
			var enc_mobile_phone = encrypt_encrypt_string(form.profile_mobile_number.value, key) ;
			form.profile_mobile_number.value = enc_mobile_phone ;
		    }
		    
		    if ( enc_first_name ){
			console.log( sjcl.codec.utf8String.fromBits(sjcl.mode.ccm.decrypt( blockCipher, sjcl.codec.hex.toBits(encrypt_get_ciphertext(enc_first_name)), sjcl.codec.hex.toBits(encrypt_get_iv( enc_first_name )) ))) ;
		    }
		    
		    //		console.log( sjcl.codec.utf8String.fromBits(sjcl.mode.ccm.decrypt( blockCipher, enc_last_name, iv ))) ;
		    //		console.log( sjcl.codec.utf8String.fromBits(sjcl.mode.ccm.decrypt( blockCipher, enc_state, iv ))) ;

		    //form.is_encrypted.checked = true ;
		    
		    return true ;
		}
	    }
	}
	return false ;
    }
} ;

// should maybe have an encrypt_item which does the append in the
// correct format?

encrypt_encrypt_string = function( cleartext, key, iv ){
    var blockCipher = new sjcl.cipher.aes(key);

    if (iv)
	iv = sjcl.codec.hex.toBits( iv ) ;
    else
	iv = sjcl.random.randomWords(2) ;

    return "0x" + sjcl.codec.hex.fromBits(sjcl.mode.ccm.encrypt(blockCipher, sjcl.codec.utf8String.toBits(cleartext), iv)) + "&" + sjcl.codec.hex.fromBits( iv ) ;
} ;

encrypt_decrypt_string = function( ciphertext, key, iv ){
    var blockCipher = new sjcl.cipher.aes(sjcl.codec.hex.toBits(key));

    return sjcl.codec.utf8String.fromBits(sjcl.mode.ccm.decrypt(blockCipher, sjcl.codec.hex.toBits(ciphertext), sjcl.codec.hex.toBits(iv))) ;
} ;

// @@TODO - what should these return if there's an error, 
// or should they throw an exception?

encrypt_is_encrypted = function( item ){
    if ( item.substring(0,2) == "0x")
	return true ;
    else
	return false ;
} ;

encrypt_decrypt_item = function( item, key ){

    if ( item && item != "" && encrypt_is_encrypted( item )){
	var ciphertext = encrypt_get_ciphertext( item.substring( 2 ) ) ;
	var iv = encrypt_get_iv( item.substring( 2 ) ) ;

	return encrypt_decrypt_string( ciphertext, key, iv ) ;
    }
    else
	return item ;

} ;

encrypt_decrypt_document_item = function( item ){

    var key_name = document.getElementById("user_key_storage_name").value ;
    var key = sessionStorage[key_name] ;
    return encrypt_decrypt_item( item, key ) ;
} ;

encrypt_get_ciphertext = function( item ){

    var both = item.split("&") ;

    return both[0] ;
} ;

encrypt_get_iv = function( item ){

    var both = item.split("&") ;

    return both[1] ;
} ;

encrypt_get_salt = function( item ){

    var all = item.split("&") ;

    return all[2] ;
} ;

encrypt_decrypt_form = function( form ){

    if ( form.profile_is_encrypted.checked ){
	
	if ( sessionStorage )
	{
	    var key_name = form.user_key_storage_name.value ;
	    
	    if ( key_name ){
		
		var key = sjcl.codec.hex.toBits(sessionStorage[key_name]) ;
		
		if ( key ){
		    
		    var first_name = encrypt_decrypt_document_item(form.profile_first_name.value) ;
		    var middle_name = encrypt_decrypt_document_item(form.profile_middle_name.value) ;
		    var last_name = encrypt_decrypt_document_item(form.profile_last_name.value) ;
		    var address = encrypt_decrypt_document_item(form.profile_address.value) ;
		    var address2 = encrypt_decrypt_document_item(form.profile_address2.value) ;
		    
		    var city = encrypt_decrypt_document_item(form.profile_city.value) ;
		    //var state = form.profile_state.value ? encrypt_decrypt_item(form.profile_state.value, key) : "" ;
		    var zip = encrypt_decrypt_document_item(form.profile_zip.value) ;
		    var phone = encrypt_decrypt_document_item(form.profile_phone_number.value) ;
		    var mobile_phone = encrypt_decrypt_document_item(form.profile_mobile_number.value) ;
		    
		    console.log( first_name ) ;
		    console.log( last_name ) ;
		    
		    form.profile_first_name.value = first_name ;
		    form.profile_middle_name.value = middle_name ;
		    form.profile_last_name.value = last_name ;
		    form.profile_address.value = address ;
		    form.profile_address2.value = address2 ;
		    form.profile_city.value = city ;
		    //form.profile_state.value = state ;
		    form.profile_zip.value = zip ;
		    form.profile_phone_number.value = phone ;
		    form.profile_mobile_number.value = mobile_phone ;
		    
		    return true ;
		}
	    }
	}
    }
    return false ;
} ;

encrypt_set_key = function( form ){

    // @@ TODO: check if key is already set
    // perhaps have a pending key and an old key when you go to profile
    // page - decrypt with old key, re-encrypt, and then delete the old key?

    if ( form.passphrase.value === form.confirm_passphrase.value ){

	var salt = sjcl.random.randomWords(2) ;

	var secret_key = encrypt_create_key( form.passphrase.value, salt ) ;

	if ( sessionStorage )
	{

	    if ( encrypt_has_key_already() ){
	    }

	    var key_name = sjcl.codec.hex.fromBits(sjcl.random.randomWords(2));
	    console.log( key_name ) ;
	    form.key_name.value = key_name ;
	    sessionStorage[key_name] = secret_key ;

	    var iv = sjcl.random.randomWords(2) ;
	    var psalt = sjcl.random.randomWords(2) ;
	    var key = encrypt_create_key( form.password.value, psalt ) ;
	    var blockCipher = new sjcl.cipher.aes( sjcl.codec.hex.toBits(key) ) ;

	    // @@TODO: add salt & iv to end of the stored value
	    // @@ What happens if user has one cleartext password +
	    // their own encrypted key + salt + iv? - can they more
	    // easily guess the encrypted key for someone else?

	    localStorage[key_name] = sjcl.codec.hex.fromBits(sjcl.mode.ccm.encrypt( blockCipher, sjcl.codec.hex.toBits(secret_key), iv )) + "&" + sjcl.codec.hex.fromBits( iv ) + "&" + sjcl.codec.hex.fromBits( psalt );

	    console.log( "encrypted: " + localStorage[key_name] ) ;

	    console.log( sjcl.codec.hex.fromBits(sjcl.mode.ccm.decrypt( blockCipher, sjcl.codec.hex.toBits(encrypt_get_ciphertext(localStorage[key_name])), sjcl.codec.hex.toBits(encrypt_get_iv(localStorage[key_name])))) ) ;

	    return true ;
	}
    }

    return false ;
}

encrypt_decrypt_key = function( key_name, password ){
    var key = encrypt_get_ciphertext( localStorage[key_name] ) ;
    var iv = encrypt_get_iv( localStorage[key_name] ) ;
    var salt = encrypt_get_salt( localStorage[key_name] ) ;

    // @@TODO: use the password to recreate the key used to encrypt the encryption key

    var passkey = encrypt_create_key( password, sjcl.codec.hex.toBits( salt ) ) ;
    var blockCipher = new sjcl.cipher.aes( sjcl.codec.hex.toBits(passkey) ) ;

    console.log( key ) ;
    console.log( iv ) ;
    console.log( salt ) ;

    var clear_key = sjcl.codec.hex.fromBits(sjcl.mode.ccm.decrypt( blockCipher, sjcl.codec.hex.toBits(key), sjcl.codec.hex.toBits(iv))) ;

    console.log( "KEY IS: " + clear_key ) ;
    return (clear_key) ; 
} ;

encrypt_create_key = function( passphrase, salt ){

    if ( passphrase && salt )
    {
	var iterations = 1000;
	var keySize = 128;
	var encryptionKey = sjcl.misc.pbkdf2(passphrase, salt, iterations, keySize);

	// @@ TEST BLOCK start

	console.log( sjcl.codec.hex.fromBits(encryptionKey) ) ;

	var blockCipher = new sjcl.cipher.aes(encryptionKey);
	var plainText = sjcl.codec.utf8String.toBits("secret");
	var iv = sjcl.codec.hex.toBits("8291ff107e798a29");
	var cipherText = sjcl.mode.ccm.encrypt(blockCipher, plainText, iv);

	console.log( sjcl.codec.hex.fromBits(cipherText) ) ;

	console.log( sjcl.codec.utf8String.fromBits(sjcl.mode.ccm.decrypt( blockCipher, cipherText, iv ))) ;

	// @@ TEST BLOCK end

	return sjcl.codec.hex.fromBits(encryptionKey) ;
    }
    else
    {
	// @@TODO: generate an error
	console.log("no passphrase specified") ;
	return null ;
    }
} ;

// @@TODO: no more use this to guess key_name

encrypt_has_key_already = function(){
    var key_name ;
    var key_value ;

    for (var key in sessionStorage){ 
	if (key.substring(0,6) == "myusa_" ){
	    key_name = key ;
	    key_value = sessionStorage[key] ;
	    console.log( "setting key:" + key_name ) ;
	}
    }

    if ( key_name && key_value )
	return( { key_name: key_value } ) ;
    else
	return null ;
} ;
