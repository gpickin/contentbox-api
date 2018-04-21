/**
* An API module for CMS API
*/
component {

	// Module Properties
	this.title 				= "cms-api";
	this.author 			= "Ortus Solutions";
	this.webURL 			= "www.ortussolutions.com";
	this.description 		= "API module for CMS";
	this.version			= "1.0.0";
	// If true, looks for views in the parent first, if not found, then in the module. Else vice-versa
	this.viewParentLookup 	= true;
	// If true, looks for layouts in the parent first, if not found, then in module. Else vice-versa
	this.layoutParentLookup = true;
	// Module Entry Point
	this.entryPoint			= "api";
	// Model Namespace
	this.modelNamespace		= "api";
	// CF Mapping
	this.cfmapping			= "api";
	// Auto-map models
	this.autoMapModels		= true;
	// Module Dependencies
	this.dependencies 		= [];

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
			// Convention Route
			{ 
				pattern="/:handler/:action?" 
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
