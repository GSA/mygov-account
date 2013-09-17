var sign_out_link = document.getElementById("sign_out_link") ;

if ( sign_out_link ){
    
    sign_out_link.addEventListener( "click", 
				    function (event) {
					window.sessionStorage.clear() ;
				    }, 
				    false) ;
}
