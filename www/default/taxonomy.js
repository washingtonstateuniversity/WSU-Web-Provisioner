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
		UI.level0    = document.getElementById('level0');
		UI.level1    = document.getElementById('level1');
		UI.level2    = document.getElementById('level2');
		UI.container = document.getElementById('taxonomy_container');
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
		taxonomy_html = '<ul>';
		for( a in taxonomies ) {
			if ( '' === a ) { continue; }
			taxonomy_html += '<li>' + a + '<ul>';
			for ( b in taxonomies[a] ) {
				if ( '' === b ) { continue; }
				taxonomy_html += '<li>' + b + '<ul>';
				for ( c in taxonomies[a][b] ) {
					if ( '' === c ) { continue; }
					taxonomy_html += '<li>' + c + '</li>';
				}
				taxonomy_html += '</ul></li>';
			}
			taxonomy_html += '</ul></li>';
		}
		taxonomy_html += '</ul>';
		$(UI.container).html(taxonomy_html);
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