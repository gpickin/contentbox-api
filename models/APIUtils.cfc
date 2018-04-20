/**
* Utils for the API Module
*/
component accessors="true" singleton {

	/**
    * Get Real IP, by looking at clustered, proxy headers, request scope and locally.
    */
    function getRealIP(){
        var headers = getHttpRequestData().headers;

        // Very balanced headers
        if( structKeyExists( headers, 'x-cluster-client-ip' ) ){
            return headers[ 'x-cluster-client-ip' ];
        }
        if( structKeyExists( headers, 'X-Forwarded-For' ) ){
            return headers[ 'X-Forwarded-For' ];
        }
		if( structKeyExists( request, 'realRemoteAddr' ) ){
			return request.realRemoteAddr;
		}

        return len( cgi.remote_addr ) ? cgi.remote_addr : '127.0.0.1';
    }

    /**
	* getBrowserLanguage Gets the browser language from the CGI.HTTP_ACCEPT_LANGUAGE header if it exists
    * @return The browser language or empty string
    */
    string function getBrowserLanguage(){
    	if ( ArrayLen( REMatch( "[a-z]{1,8}-[a-z]{1,8}", LCase( cgi.http_accept_language ) ) ) ) {
			return ListFirst( REMatch( "[a-z]{1,8}-[a-z]{1,8}", LCase( cgi.http_accept_language ) )[ 1 ], "-" );
		}
		return "";
    }

    /**
	* getBrowserLocale Gets the browser locale from the CGI.HTTP_ACCEPT_LANGUAGE header if it exists
    * @return The browser locale or empty string
    */
    function getBrowserLocale(){
		if ( ArrayLen( REMatch( "[a-z]{1,8}-[a-z]{1,8}", LCase( cgi.http_accept_language ) ) ) ) {
			return UCase( ListLast( REMatch( "[a-z]{1,8}-[a-z]{1,8}", LCase( cgi.http_accept_language ) )[ 1 ], "-" ) );
		}

		return "";
    }

}