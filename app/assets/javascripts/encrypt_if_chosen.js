// @@TODO: better way of abstracting these functions from the HTML elements passed in

encrypt_if_chosen = function( form ){

    if ( sessionStorage )
    {
	var key_name = form.user_key_storage_name.value ;

	if ( key_name ){
	    var key = sjcl.codec.hex.toBits(sessionStorage[key_name]) ;
	
	    if ( key ){
		
		var blockCipher = new sjcl.cipher.aes(key);
		var iv = sjcl.codec.hex.toBits("8291ff107e798a29");
		var enc_first_name = sjcl.mode.ccm.encrypt(blockCipher, sjcl.codec.utf8String.toBits(form.profile_first_name.value), iv);
		var enc_middle_name = sjcl.mode.ccm.encrypt(blockCipher, sjcl.codec.utf8String.toBits(form.profile_middle_name.value), iv);
		var enc_last_name = sjcl.mode.ccm.encrypt(blockCipher, sjcl.codec.utf8String.toBits(form.profile_last_name.value), iv);
		var enc_address = sjcl.mode.ccm.encrypt(blockCipher, sjcl.codec.utf8String.toBits(form.profile_address.value), iv);
		var enc_address2 = sjcl.mode.ccm.encrypt(blockCipher, sjcl.codec.utf8String.toBits(form.profile_address2.value), iv);
		var enc_city = sjcl.mode.ccm.encrypt(blockCipher, sjcl.codec.utf8String.toBits(form.profile_city.value), iv);
		var enc_state = sjcl.mode.ccm.encrypt(blockCipher, sjcl.codec.utf8String.toBits(form.profile_state.value), iv);
		var enc_zip = sjcl.mode.ccm.encrypt(blockCipher, sjcl.codec.utf8String.toBits(form.profile_zip.value), iv);
		var enc_phone = sjcl.mode.ccm.encrypt(blockCipher, sjcl.codec.utf8String.toBits(form.profile_phone_number.value), iv);
		var enc_mobile_phone = sjcl.mode.ccm.encrypt(blockCipher, sjcl.codec.utf8String.toBits(form.profile_mobile_number.value), iv);

		console.log( sjcl.codec.utf8String.fromBits(sjcl.mode.ccm.decrypt( blockCipher, enc_first_name, iv ))) ;
		console.log( sjcl.codec.utf8String.fromBits(sjcl.mode.ccm.decrypt( blockCipher, enc_last_name, iv ))) ;
		console.log( sjcl.codec.utf8String.fromBits(sjcl.mode.ccm.decrypt( blockCipher, enc_state, iv ))) ;

		if ( form.profile_first_name.value  && form.profile_first_name.value != form.profile_first_name.defaultValue ) 
		    form.profile_first_name.value = sjcl.codec.hex.fromBits(enc_first_name) ;

		if ( form.profile_middle_name.value && form.profile_middle_name.value != form.profile_middle_name.defaultValue )
		    form.profile_middle_name.value = sjcl.codec.hex.fromBits(enc_middle_name) ;

		if ( form.profile_last_name.value && form.profile_last_name.value != form.profile_last_name.defaultValue )
		    form.profile_last_name.value = sjcl.codec.hex.fromBits(enc_last_name) ;

		if ( form.profile_address.value && form.profile_address.value != form.profile_address.defaultValue )
		    form.profile_address.value = sjcl.codec.hex.fromBits(enc_address) ;
		
		if ( form.profile_address2.value && form.profile_address2.value != form.profile_address2.defaultValue )
		    form.profile_address2.value = sjcl.codec.hex.fromBits(enc_address2) ;

		if ( form.profile_city.value && form.profile_city.value != form.profile_city.defaultValue )
		    form.profile_city.value = sjcl.codec.hex.fromBits(enc_city) ;

		if ( form.profile_state.value && form.profile_state.value != form.profile_state.defaultValue )
		    form.profile_state.value = sjcl.codec.hex.fromBits(enc_state) ;

		if ( form.profile_zip.value && form.profile_zip.value != form.profile_zip.defaultValue )
		    form.profile_zip.value = sjcl.codec.hex.fromBits(enc_zip) ;

		if ( form.profile_phone_number.value && form.profile_phone_number.value != form.profile_phone_number.defaultValue ) 
		    form.profile_phone_number.value = sjcl.codec.hex.fromBits(enc_phone) ;

		if ( form.profile_mobile_number.value && form.profile_mobile_number.value != form.profile_mobile_number.defaultValue )
		    form.profile_mobile_number.value = sjcl.codec.hex.fromBits(enc_mobile_phone) ;

		form.is_encrypted.value = "true" ;

		return true ;
	    }
	}
    }
    return false ;
} ;

encrypt_decrypt_item = function( item, key, iv ){
    var blockCipher = new sjcl.cipher.aes(key);
    var iv = sjcl.codec.hex.toBits("8291ff107e798a29");

    return sjcl.codec.utf8String.fromBits(sjcl.mode.ccm.decrypt(blockCipher, sjcl.codec.hex.toBits(item), iv)) ;
} ;

encrypt_decrypt = function( form ){

    //alert( window.onload ) ;
    if ( sessionStorage )
    {
	var key_name = form.user_key_storage_name.value ;

	if ( key_name ){

	    var key = sjcl.codec.hex.toBits(sessionStorage[key_name]) ;
	
	    if ( key ){
		
		var blockCipher = new sjcl.cipher.aes(key);
		var iv = sjcl.codec.hex.toBits("8291ff107e798a29");

		var first_name = form.profile_first_name.value ? sjcl.codec.utf8String.fromBits(sjcl.mode.ccm.decrypt(blockCipher, sjcl.codec.hex.toBits(form.profile_first_name.value), iv)) : "" ;
		var middle_name = form.profile_middle_name.value ? sjcl.codec.utf8String.fromBits(sjcl.mode.ccm.decrypt(blockCipher, sjcl.codec.hex.toBits(form.profile_middle_name.value), iv)) : "" ;
		var last_name = form.profile_last_name.value ? sjcl.codec.utf8String.fromBits(sjcl.mode.ccm.decrypt(blockCipher, sjcl.codec.hex.toBits(form.profile_last_name.value), iv)) : "" ;
		var address = form.profile_address.value ? sjcl.codec.utf8String.fromBits(sjcl.mode.ccm.decrypt(blockCipher, sjcl.codec.hex.toBits(form.profile_address.value), iv)) : "" ;
		var address2 = form.profile_address2.value ? sjcl.codec.utf8String.fromBits(sjcl.mode.ccm.decrypt(blockCipher, sjcl.codec.hex.toBits(form.profile_address2.value), iv)) : "" ;
		var city = form.profile_city.value ? sjcl.codec.utf8String.fromBits(sjcl.mode.ccm.decrypt(blockCipher, sjcl.codec.hex.toBits(form.profile_city.value), iv)) : "" ;
		var state = form.profile_state.value ? sjcl.codec.utf8String.fromBits(sjcl.mode.ccm.decrypt(blockCipher, sjcl.codec.hex.toBits(form.profile_state.value), iv)) : "" ;
		var zip = form.profile_zip.value ? sjcl.codec.utf8String.fromBits(sjcl.mode.ccm.decrypt(blockCipher, sjcl.codec.hex.toBits(form.profile_zip.value), iv)) : "" ;
		var phone = form.profile_phone_number.value ? sjcl.codec.utf8String.fromBits(sjcl.mode.ccm.decrypt(blockCipher, sjcl.codec.hex.toBits(form.profile_phone_number.value), iv)) : "" ;
		var mobile_phone = form.profile_mobile_number.value ? sjcl.codec.utf8String.fromBits(sjcl.mode.ccm.decrypt(blockCipher, sjcl.codec.hex.toBits(form.profile_mobile_number.value), iv)) : "" ;

		console.log( first_name ) ;
		console.log( last_name ) ;
		console.log( state, iv ) ;

		form.profile_first_name.value = first_name ;
		form.profile_middle_name.value = middle_name ;
		form.profile_last_name.value = last_name ;
		form.profile_address.value = address ;
		form.profile_address2.value = address2 ;
		form.profile_city.value = city ;
		form.profile_state.value = state ;
		form.profile_zip.value = zip ;
		form.profile_phone_number.value = phone ;
		form.profile_mobile_number.value = mobile_phone ;

		return true ;
	    }
	}
    }
    return false ;
} ;

encrypt_set_key = function( form ){
    if ( form.passphrase.value == form.confirm_passphrase.value )
    {
	// @@TODO salt should be random generated

	var salt = sjcl.codec.hex.toBits(
	    "5f9bcef98873d06a" // Random generated with sjcl.random.randomWords(2, 0);
	);                     // Hex encoded with sjcl.codec.hex.toBits(randomSalt);

	var iterations = 1000;
	var keySize = 128;
	var encryptionKey = sjcl.misc.pbkdf2(form.passphrase.value, salt, iterations, keySize);

	console.log( sjcl.codec.hex.fromBits(encryptionKey) ) ;

	var blockCipher = new sjcl.cipher.aes(encryptionKey);
	var plainText = sjcl.codec.utf8String.toBits("secret");

	// @@TODO iv should be random generated and stored with key

	var iv = sjcl.codec.hex.toBits("8291ff107e798a29");
	var cipherText = sjcl.mode.ccm.encrypt(blockCipher, plainText, iv);

	console.log( sjcl.codec.hex.fromBits(cipherText) ) ;

	console.log( sjcl.codec.utf8String.fromBits(sjcl.mode.ccm.decrypt( blockCipher, cipherText, iv ))) ;

	if ( sessionStorage )
	{
	    var key_name = sjcl.codec.hex.fromBits(sjcl.random.randomWords(2));
	    console.log( key_name ) ;
	    form.key_name.value = key_name ;
	    sessionStorage[key_name] = sjcl.codec.hex.fromBits(encryptionKey) ;
	}
	return true ;
    }
    else
    {
	alert("no encryption") ;
	return false ;
    }
} ;