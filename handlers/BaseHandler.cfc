/**
* Base JSON RESTFul handler
* In each request the Response@api object will be dropped into the PRC scope as prc.response.
* The current user requesting the call will be dropped into the PRC scope as prc.oCurrentUser
* 
* <h2>Authentication and Authorizations</h2>
* The Base Handler intercepts all calls to all actions. It will first assume all calls are secured
* unless the action has a 'public' annotation, which denotes that it can be executed publicly.
* If an action needs authentication and the user is not authenticated or their session timed out
* the service will emit a 401 error exception with an appropirate status text.
* <br>
* You can also control the permissions needed for each user in order to execute an action by adding
* a 'secured' annotation with a list of permissions to verify. If the user is not authorized a 403
* will be emitted with the appropriate status text.
*/
component extends="coldbox.system.EventHandler"{

	// DI
	//property name="bugloghq" 		inject="BugLogService@bugloghq";
	// TODO: Activate once ready
	//property name="securityService" inject="securityService@core";
	
	// OPTIONAL HANDLER PROPERTIES
	this.prehandler_only 	= "";
	this.prehandler_except 	= "";
	this.posthandler_only 	= "";
	this.posthandler_except = "";
	this.aroundHandler_only = "";
	this.aroundHandler_except = "";		

	// REST Allowed HTTP Methods Ex: this.allowedMethods = {delete='POST,DELETE',index='GET'}
	this.allowedMethods = {};
	
	//Verb aliases - in case we are dealing with legacy browsers or servers
	METHODS = {
		"GET":"GET",
		"POST":"POST",
		"PATCH":"PATCH",
		"PUT":"PUT",
		"OPTIONS":"OPTIONS",
		"DELETE":"DELETE"
	};
	
	//HTTP STATUS CODES
	STATUS = {
		"CREATED":201,
		"SUCCESS":200,
		"NO_CONTENT":204,
		"BAD_REQUEST":400,
		"NOT_AUTHORIZED":401,
		"NOT_FOUND":404,
		"NOT_ALLOWED":405,
		"NOT_ACCEPTABLE":406,
		"TOO_MANY_REQUESTS":429,
		"EXPECTATION_FAILED":417,
		"INTERNAL_ERROR":500,
		"NOT_IMPLEMENTED":501
	};
	
	/**
	* Around handler for all functions
	*/
	function aroundHandler( event, rc, prc, targetAction, eventArguments ){
		try{
			var stime = getTickCount();
			
			// Get API security token, look in headers first, then RC scope
			prc.APIToken = event.getHTTPHeader( header="x-api-token", defaultValue="" );
			
			// prepare our response object
			prc.response = getModel( "Response@api" );
			prc.response.addHeader( "Access-Control-Allow-Origin", "*" );
			prc.response.addHeader( "Access-Control-Allow-Headers", "X-Requested-With, Content-Type,x-api-token" );
			// prepare argument execution
			var args = { event = arguments.event, rc = arguments.rc, prc = arguments.prc };
			structAppend( args, arguments.eventArguments );
			// Secure the call
			if( isAuthorizedAPIToken( event, rc, prc, targetAction ) ){
				// Execute action
				var simpleResults = arguments.targetAction( argumentCollection=args );
			} else {
				if( prc.isAuthorizedAPITokenResult == "NotAuthorized" ){
					onNotAuthorized( event, rc, prc );	
				} else if( prc.isAuthorizedAPITokenResult == "UserNotFound" ){
					 UserNotFound( event, rc, prc );	
				} else {
					onInvalidAPIToken( event, rc, prc );
				}
			}
		} catch( Any e ){
			// Log Locally
			log.error( "Error calling #event.getCurrentEvent()#: #e.message# #e.detail#", e );
			// Log to BugLogHQ
			//sendToBugLog( e );
			// Setup General Error Response
			prc.response
				.setError( true )
				.setErrorCode( e.errorCode eq 0 ? 500 : len( e.errorCode ) ? e.errorCode : 0 )
				.addMessage( "General application error: #e.message#" )
				.setStatusCode( 500 )
				.setStatusText( "General application error" );
			// Development additions
			if( listFindNoCase( "development,staging", getSetting( "environment" ) ) ){
				prc.response.addMessage( "Detail: #e.detail#" )
					.addMessage( "StackTrace: #e.stacktrace#" );
			}
		}

		// Development/Staging additions
		if( listFindNoCase( "development,staging", getSetting( "environment" ) ) ){
			prc.response.addHeader( "x-current-route", event.getCurrentRoute() )
				.addHeader( "x-current-routed-url", event.getCurrentRoutedURL() )
				.addHeader( "x-current-routed-namespace", event.getCurrentRoutedNamespace() )
				.addHeader( "x-current-event", event.getCurrentEvent() );
		}

		// end timer
		prc.response.setResponseTime( getTickCount() - stime );
		
		// Did the user set a view to be rendered? If not use renderdata, else just delegate to view.
		if( !len( event.getCurrentView() ) ){
			// Simple HTML Handler Results?
			if( !isNull( simpleResults ) ){
				prc.response.setData( simpleResults )
					.setFormat( "html" );
			}
			// Magical Response renderings
			event.renderData( 
				type		= prc.response.getFormat(),
				data 		= prc.response.getDataPacket(),
				contentType = prc.response.getContentType(),
				statusCode 	= prc.response.getStatusCode(),
				statusText 	= prc.response.getStatusText(),
				location 	= prc.response.getLocation(),
				isBinary 	= prc.response.getBinary()
			);
		}
		
		// Global Response Headers
		prc.response.addHeader( "x-response-time", prc.response.getResponseTime() )
				.addHeader( "x-cached-response", prc.response.getCachedResponse() );
		
		// Custom Response Headers
		for( var thisHeader in prc.response.getHeaders() ){
			event.setHTTPHeader( name=thisHeader.name, value=thisHeader.value );
		}
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
	* Prepare error response for an unathorized request
	*/
	function onNotAuthorized( event, rc, prc ){
		prc.response.addMessage( "Unathorized Request! You do not have the right permissions to execute this request" )
			.setError( true )
			.setErrorCode( 403 )
			.setStatusCode( 403 )
			.setStatusText( "Invalid Permissions" );
	}
	
	/**
	* Prepare error response for User not Found
	*/
	function UserNotFound( event, rc, prc ){
		prc.response.addMessage( "Requested User not Found" )
			.setError( true )
			.setErrorCode( 404 )
			.setStatusCode( 404 )
			.setStatusText( "Requested User not Found" );
	}

	/**
	* Prepare error response for an un-authenticated request or session timeout
	*/
	function onNotAuthenticated( event, rc, prc ){
		prc.response.addMessage( "You are not logged in or your session has timed out, please try again." )
			.setError( true )
			.setErrorCode( 401 )
			.setStatusCode( 401 )
			.setStatusText( "Not Authenticated" );
	}

	/**
	* on localized errors
	*/
	function onError( event, rc, prc, faultAction, exception, eventArguments ){
		// Log Locally
		log.error( "Error in base handler (#arguments.faultAction#): #arguments.exception.message# #arguments.exception.detail#", arguments.exception );
		// Log to BugLogHQ
		//sendToBugLog( arguments.exception );
		// Verify response exists, else create one
		if( !structKeyExists( prc, "Response@api" ) ){ prc.response = getModel( "Response@api" ); }
		// Setup General Error Response
		prc.response
			.setError( true )
			.setErrorCode( 501 )
			.addMessage( "Base Handler Application Error: #arguments.exception.message#" )
			.setStatusCode( 500 )
			.setStatusText( "General application error" );
		// Development additions
		if( getSetting( "environment" ) eq "development" || getSetting( "environment" ) eq "staging" ){
			prc.response.addMessage( "Detail: #arguments.exception.detail#" )
				.addMessage( "StackTrace: #arguments.exception.stacktrace#" );
		}
		// Render Error Out
		event.renderData( 
			type		= prc.response.getFormat(),
			data 		= prc.response.getDataPacket(),
			contentType = prc.response.getContentType(),
			statusCode 	= prc.response.getStatusCode(),
			statusText 	= prc.response.getStatusText(),
			location 	= prc.response.getLocation(),
			isBinary 	= prc.response.getBinary()
		);
	}

	/**
	* on invalid http verbs
	*/
	function onInvalidHTTPMethod( event, rc, prc, faultAction, eventArguments ){
		// Log Locally
		log.warn( "InvalidHTTPMethod Execution of (#arguments.faultAction#): #event.getHTTPMethod()#", getHTTPRequestData() );
		// Setup Response
		prc.response = getModel( "Response@api" )
			.setError( true )
			.setErrorCode( 405 )
			.addMessage( "InvalidHTTPMethod Execution of (#arguments.faultAction#): #event.getHTTPMethod()#" )
			.setStatusCode( 405 )
			.setStatusText( "Invalid HTTP Method" );
		// Render Error Out
		event.renderData( 
			type		= prc.response.getFormat(),
			data 		= prc.response.getDataPacket(),
			contentType = prc.response.getContentType(),
			statusCode 	= prc.response.getStatusCode(),
			statusText 	= prc.response.getStatusText(),
			location 	= prc.response.getLocation(),
			isBinary 	= prc.response.getBinary()
		);
	}

	/**
	* Send an exception to bug log hq
	* @exception The CF exception
	*/
	private function sendToBugLog( required exception ){
		// Log to BugLogHQ
		bugloghq.notifyService(
			message 		= arguments.exception.message & "." & arguments.exception.detail,
			exception 		= arguments.exception,
			extraInfo 		= { requestData = getHTTPRequestData() },
			severityCode 	= "error"
		);
		return this;
	}

	/**
	* Secure an API Call by inspecting the targeted action for metadata:
	* secured : boolean, if true the method requires API authentication
	* permissions : list, if exists, it will also look for the required permissions from the user
	*/
	private function isAuthorizedAPIToken( event, rc, prc, targetAction ){
		// Is the action secured?
		var md = getMetadata( arguments.targetAction );
		if( !structKeyExists( md, "secured" ) ){
			return true;
		} else {
			false;
		}
	}
	
	/**
	* Convert a UTC string to local
	* @target The target time to convert
	*/
	private function utc2Local( required target ){
		// Check if numeric
		if( !isNumeric( arguments.target ) ){ return arguments.target; }
		// Convert it
		return createObject( "java", "java.util.Date" ).init( javaCast( "long", arguments.target ) );
	}
}