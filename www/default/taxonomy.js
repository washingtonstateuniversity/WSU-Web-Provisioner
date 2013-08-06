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

	var buildTaxonomyHTML = function() {
		var parent_html = '<ul>';
		var child_html = '';
		var sub_html = '';

		for( a in taxonomies ) {
			if ( '' === a ) { continue; }
			for ( b in taxonomies[a] ) {
				if ( '' === b ) { continue; }
				for ( c in taxonomies[a][b] ) {
					if ( '' === c ) { continue; }
					sub_html += '<li>' + c + '</li>';
				}
				if ( '' !== sub_html ) { sub_html = '<ul>' + sub_html + '</ul>'; }
				child_html += '<li>' + b + sub_html + '</li>';
				sub_html = '';
			}
			if ( '' !== child_html ) { child_html = '<ul>' + child_html + '</ul>'; }
			parent_html += '<li>' + a + child_html + '</li>';
			child_html = '';
		}
		parent_html += '</ul>';
		return parent_html;
	};

	var displayTaxonomies = function() {
		setupTaxonomies();

		var taxonomy_html = buildTaxonomyHTML();

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