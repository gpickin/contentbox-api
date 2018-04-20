/**
* Our main handler
*/
component extends="api.handlers.BaseHandler"{

	/**
	* Echo
	*/
	function echo( event, rc, prc ){
		prc.response.addMessage( "Welcome to the Avoya Travel API version #getModuleConfig( 'v1' ).version#" );
	}

	/**
	* Clears all the events from the event cache.
	*/
	function flushTemplateCache( event, rc, prc ){
		cachebox.getCache( "template" ).clearAllEvents()
		prc.response.addMessage( "Template Cache Flushed Successfully" );
	}

	/**
	* Fires on invalid routed events
	*/
	function onInvalidEvent( event, rc, prc ){
		prc.response.addMessage( "The resource requested: '#event.getCurrentRoutedURL()#' does not exist" )
			.setError( true )
			.setErrorCode( 404 )
			.setStatusCode( 404 )
			.setStatusText( "Page Not Found" );
	}

	/**
	* Fires on invalid API Token calls
	*/
	function onInvalidAPIToken( event, rc, prc ){
		prc.response.addMessage( "The API Token sent is invalid! Cannot continue request." )
			.setError( true )
			.setErrorCode( 403 )
			.setStatusCode( 403 )
			.setStatusText( "Invalid API Token" );
	}

	/**
	* An un-authenticated request or session timeout
	*/
	function onNotAuthenticated( event, rc, prc ){
		prc.response.addMessage( "You are not logged in or your session has timed out, please try again." )
			.setError( true )
			.setErrorCode( 401 )
			.setStatusCode( 401 )
			.setStatusText( "Not Authenticated" );
	}

}