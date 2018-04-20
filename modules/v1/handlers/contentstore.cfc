/**
* Our main handler
*/
component extends="api.handlers.BaseHandler"{

	property name="cb"	inject="id:cbHelper@cb";
	property name="contentStoreService"	inject="id:contentStoreService@cb";

	/**
	* Search ContentStore Items
	*/
	function search( event, rc, prc ){
		param name="rc.sortOrder" default="publishedDate";
		param name="rc.max" default="0";
		param name="rc.location" default="all";
		param name="rc.isPublished" default="1";
		param name="rc.onlyVisible" default="true";
		param name="rc.date" default="#now()#";
		param name="rc.slugPrefix" default="";
		param name="rc.memento" default="false";

		prc.parent = cb.contentStoreObject( slug="#rc.slugPrefix#" );
		prc.list = contentStoreService.search(
			parent=prc.parent.getContentID(),
			sortOrder=rc.sortOrder,
			isPublished=rc.isPublished
		);
		prc.returnArray = [];
		for( item in prc.list.content ){
			if( arrayLen( prc.returnArray ) lte rc.max || rc.max == 0 ){
				if( !rc.onlyVisible || rc.date gte item.getPublishedDate() && rc.date lte item.getExpireDate() ){
					if( rc.memento == true ){
						var itemStruct = item.getMemento();
					} else {
						var itemStruct = {
							"title": item.getTitle(),
							"startDate": item.getPublishedDate(),
							"endDate": item.getExpireDate()
						};
						structAppend( itemStruct, item.getCustomFieldsAsStruct() );
					}

					arrayAppend( prc.returnArray, itemStruct );
				}
			}
		}

		prc.response.setData( prc.returnArray );
	}

	/**
	* get ContentStore item by SLUG
	*/
	function get( event, rc, prc ){
		param name="rc.slug" default="";
		param name="rc.memento" default="false";

		var item = cb.contentStoreObject( slug="#rc.slug#" );

		if( isNull( item ) || !item.isLoaded() ){
			prc.response.setError( true );
			prc.response.addMessage( 'ContentStore item not found' );
		} else {
			if( rc.memento == true ){
				var itemStruct = item.getMemento();
			} else {
				var itemStruct = {
					"title": item.getTitle(),
					"startDate": item.getPublishedDate(),
					"endDate": item.getExpireDate()
				};
				structAppend( itemStruct, item.getCustomFieldsAsStruct() );
			}

			prc.response.setData( itemStruct );
		}


	}

}