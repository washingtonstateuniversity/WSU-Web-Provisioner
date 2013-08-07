(function(window,$){

	var document = window.document;

	var UI = {};

	var storageKey = {
		'level0' : 'wsu_top_level'
	};

	var init = function() {
		cacheElements();
		setupClicks();
		displayLevel0();
	};

	var cacheElements = function() {
		UI.level0submit    = $( document.getElementById('level0-submit') );
		UI.level0input     = $( document.getElementById('level0-input') );
		UI.level0container = $( document.getElementById('level0-categories') );
	};

	var getStoredItem = function( key ) {
		var item = JSON.parse( localStorage.getItem( key ) );
		if ( undefined === typeof item || '' === item || null === item ) {
			item = {};
		}
		return item;
	};

	var setStoredItem = function( key, item ) {
		localStorage.setItem( key, JSON.stringify( item ) );
	};

	var submitTopLevel = function() {
		var item = getStoredItem( storageKey.level0 );
		if ( '' !== UI.level0input.val() ) {
			delete item[UI.level0input.val()];
			item[UI.level0input.val()] = '';
		}
		setStoredItem( storageKey.level0, item );
		displayLevel0();
	};

	var setupClicks = function() {
		UI.level0submit.on('click', submitTopLevel );
	};

	var displayLevel0 = function() {
		var item = getStoredItem( storageKey.level0 ),
			level_html = '';

		for ( k in item ) {
			console.log( k );
			level_html += '<div data-item="' + k + '" class="level0-category">' + k + '</div>';
		}
		UI.level0container.html( level_html );
	}

	init();
})(window,jQuery);