(function( window, $ ){

	var document = window.document;

	var SELF = this;

	var UI = {};

	var storageKey = 'wsu_taxonomies';

	var taxonomies;

	var init = function() {
		cacheElements();
		setupTaxonomies();
		displayTaxonomies();
	};

	var cacheElements = function() {
		UI.level0 = document.getElementById('level0');
		UI.level1 = document.getElementById('level1');
		UI.level2 = document.getElementById('level2');
	};

	var setupTaxonomies = function() {
		taxonomies = JSON.parse(localStorage.getItem(storageKey));
		if ( 'object' !== typeof taxonomies || null === taxonomies ) { taxonomies = {}; }
	};

	var saveTaxonomies = function() {
		localStorage.setItem(storageKey, JSON.stringify(taxonomies));
	};

	var displayTaxonomies = function() {
		setupTaxonomies();
		for( k in taxonomies ) {
			if ( '' === k ) { continue; }
			console.log( k );
			for ( a in taxonomies[k] ) {
				if ( '' === a ) { continue; }
				console.log( '   ' + a );
				for ( b in taxonomies[k][a] ) {
					if ( '' === b ) { continue; }
					console.log( '        ' + b );
				}
			}
		}
	};

	var handleClick = function() {
		if ( 'undefined' === typeof taxonomies[UI.level0.value] ) {
			taxonomies[UI.level0.value] = {};
		}

		if ( 'undefined' === typeof taxonomies[UI.level0.value][UI.level1.value] ) {
			taxonomies[UI.level0.value][UI.level1.value] = {};
		}

		if ( 'undefined' === typeof taxonomies[UI.level0.value][UI.level1.value][UI.level2.value] ) {
			taxonomies[UI.level0.value][UI.level1.value][UI.level2.value] = '';
		}

		saveTaxonomies();
		displayTaxonomies();
	};

	init();
	$( document.getElementById( 'add_tax' )).on( 'click', handleClick );
}( window, jQuery ));