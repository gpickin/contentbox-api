/**
* An API module for Avoya Membership
*/
component {

	// Module Properties
	this.title 				= "cms-api-v1";
	this.author 			= "Ortus Solutions";
	this.webURL 			= "www.ortussolutions.com";
	this.description 		= "API module v1 for CMS";
	this.version			= "1.0.0";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	// Module Entry Point
	this.entryPoint			= "/api/v1";
	// Model Namespace
	this.modelNamespace		= "api-v1";
	// CF Mapping
	this.cfmapping			= "api-v1";
	// Auto-map models
	this.autoMapModels		= true;
	// Module Dependencies
	this.dependencies 		= [];

	/**
	* Configure function for the Module
	*/
	function configure( ){

		// module settings - stored in modules.name.settings
		settings = {};

		// Layout Settings
		layoutSettings = {
			defaultLayout = ""
		};

		// SES Routes
		routes = [
			// Module Entry Point
			{
				pattern = "/echo",
				handler = "Main",
				action 	= { GET = "echo", POST = "echo" }
			},

			// ContentStore
			{
				pattern = "/contentstore/search",
				handler = "contentstore",
				action 	= { GET = "search", POST = "search" }
			},
			{
				pattern = "/contentstore/:slug",
				handler = "contentstore",
				action 	= { GET = "get" }
			},


			// flushTemplateCache Placements
			{
				pattern = "/flushTemplateCache",
				handler = "Main",
				action 	= { GET = "flushTemplateCache", POST = "flushTemplateCache" }
			},



			//******************* ERRORS *************************//
			{
				pattern = "/:anything",
				handler = "Main",
				action 	= "onInvalidEvent"
			},

			// Convention Route
			{
				pattern = "/:handler/:action?"
			}
		];

		// Custom Declared Points
		interceptorSettings = {
			customInterceptionPoints = ""
		};

		// Custom Declared Interceptors
		interceptors = [];

	}

}