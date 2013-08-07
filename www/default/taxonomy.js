(function( window, $ ){

	var document = window.document;

	var UI = {};

	var storageKeys = {
		'taxonomies' : 'wsu_taxonomies',
		'flag'       : 'wsu_flag',
	}

	var taxonomies;

	var init = function() {
		cacheElements();
		setupTaxonomies();
		displayTaxonomies();
		setupSortable();
		setupClicks();
	};

	var cacheElements = function() {
		UI.level0    = document.getElementById('level0');
		UI.level1    = document.getElementById('level1');
		UI.level2    = document.getElementById('level2');
		UI.container = document.getElementById('taxonomy_container');
	};

	var setupTaxonomies = function() {
		taxonomies = JSON.parse(localStorage.getItem(storageKeys.taxonomies));
		if ( 'object' !== typeof taxonomies || null === taxonomies ) { 
			taxonomies = {};
		}
	};

	var saveTaxonomies = function() {
		localStorage.setItem(storageKeys.taxonomies, JSON.stringify(taxonomies));
	};

	var updateTaxonomies = function( event, ui ) {
		if ( null === $(ui.sender).data('nodeparent') ) { return; }

		UI.item                     = ui.item;
		UI.itemParent               = $(ui.sender);
		UI.itemParentParent         = UI.itemParent.parent().parent().parent();
		UI.itemParentParentNew      = UI.item.parent().parent().parent().parent();
		UI.itemTitle                = UI.item.data('nodetitle');
		UI.itemLevel                = UI.itemParent.data('nodeparent');
		UI.itemLevelNew             = UI.item.parent().data('nodeparent');
		UI.itemParentTitle          = UI.itemParent.parent().data('nodetitle');
		UI.itemParentTitleNew       = UI.item.parent().parent().data('nodetitle');
		UI.itemParentLevelNew       = UI.item.parent().data('nodeparent');
		UI.itemParentParentTitle    = UI.itemParentParent.data('nodetitle');
		UI.itemParentParentTitleNew = UI.itemParentParentNew.data('nodetitle');
		UI.itemData                 = '';

		if ( 'sub' === UI.itemLevel && 'sub' === UI.itemLevelNew ) {
			delete taxonomies[UI.itemParentParentTitle][UI.itemParentTitle][UI.itemTitle];
			addTaxonomy( UI.itemParentParentTitleNew, UI.itemParentTitleNew, UI.itemTitle );
		}

		if ( 'sub' === UI.itemLevel && 'child' === UI.itemLevelNew ) {
			delete taxonomies[UI.itemParentParentTitle][UI.itemParentTitle][UI.itemTitle];
			addTaxonomy( UI.itemParentTitleNew, UI.itemTitle );
		}

		if ( 'child' === UI.itemLevel && 'child' === UI.itemLevelNew ) {
			UI.itemData = taxonomies[UI.itemParentTitle][UI.itemTitle];
			delete taxonomies[UI.itemParentTitle][UI.itemTitle];
			addTaxonomy( UI.itemParentTitleNew, UI.itemTitle );
			taxonomies[UI.itemParentTitleNew][UI.itemTitle] = UI.itemData;
		}

		if ( 'child' === UI.itemLevel && 'sub' === UI.itemLevelNew ) {
			// may want to alert that children will be lost
			delete taxonomies[UI.itemParentTitle][UI.itemTitle];
			addTaxonomy( UI.itemParentParentTitleNew, UI.itemParentTitleNew, UI.itemTitle );
		}

		saveTaxonomies();
	}

	var setupSortable = function() {
		$( "#wsu_taxonomy_list ul" ).sortable({ 
			connectWith : "#wsu_taxonomy_list li",
			cursor      : 'move',
			opacity     : '0.5',
			update      : updateTaxonomies
		});
    	$( "#wsu_taxonomy_list" ).disableSelection();
	}

	var buildTaxonomyHTML = function() {
		var parent_html = '<ul id="wsu_taxonomy_list" data-nodetitle="top" data-nodeparent="parent">';
		var child_html = '';
		var sub_html = '';

		for( a in taxonomies ) {
			if ( '' === a ) { continue; }
			child_html = '';
			for ( b in taxonomies[a] ) {
				if ( '' === b ) { continue; }
				sub_html = '';
				for ( c in taxonomies[a][b] ) {
					if ( '' === c ) { continue; }
					sub_html += '<li data-nodetitle="' + c + '">' + c + '</li>';
				}
				child_html += '<li data-nodetitle="' + b + '">' + b + '<ul data-nodeparent="sub">' + sub_html + '</ul></li>';
			}
			parent_html += '<li data-nodetitle="' + a + '">' + a + '<ul data-nodeparent="child">' + child_html + '</ul></li>';
		}
		parent_html += '</ul>';
		return parent_html;
	};

	var displayTaxonomies = function() {
		setupTaxonomies();

		var taxonomy_html = buildTaxonomyHTML();

		$(UI.container).html(taxonomy_html);
	};

	var addTaxonomy = function( level0, level1, level2 ) {
		console.log( level0, level1, level2 );

		if ( 'undefined' === typeof level0 ) {
			return;
		}

		if ( 'undefined' === typeof taxonomies[level0] ) {
			taxonomies[level0] = {};
		}

		if ( 'undefined' !== typeof level1 && 'undefined' === typeof taxonomies[level0][level1] ) {
			taxonomies[level0][level1] = {};
		}

		if ( 'undefined' !== typeof level1 && 'undefined' !== typeof level2 && 'undefined' === typeof taxonomies[level0][level1][level2] ) {
			taxonomies[level0][level1][level2] = '';
		}
	}

	var handleClick = function() {
		addTaxonomy( UI.level0.value, UI.level1.value, UI.level2.value );
		saveTaxonomies();
		displayTaxonomies();
	};

	var setupClicks = function() {
		$( document.getElementById( 'add_tax' )).on( 'click', handleClick );
	}

	init();
	window.WSUTaxonomies = taxonomies;
}( window, jQuery ));