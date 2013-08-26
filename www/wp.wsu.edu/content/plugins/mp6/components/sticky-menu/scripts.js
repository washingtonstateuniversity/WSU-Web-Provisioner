;var stickymenu = ( function( $, window, document, undefined ) {

	'use strict';

	$(document).ready( function() {
		stickymenu.init();
	});

	return {

		active : false,

		init : function() {

			this.adminMenuWrap = $('#adminmenuwrap');
			this.collapseMenu = $('#collapse-menu');
			this.bodyMinWidth = parseInt( $(document.body).css('min-width') );

			this.enable();

		},

		enable : function() {

			if ( !this.active ) {

				$(window).on( 'resize.stickymenu scroll.stickymenu', $.proxy( this.update, this ) );
				this.collapseMenu.on( 'click.stickymenu', $.proxy( this.update, this ) );

				this.update();
				this.active = true;

			}

		},

		disable : function() {

			if ( this.active ) {

				$(window).off( 'resize.stickymenu scroll.stickymenu' );
				this.collapseMenu.off( 'click.stickymenu' );

				$(document.body).removeClass( 'sticky-menu' );

				this.active = false;

			}

		},

		update : function() {

			// float the admin menu sticky if:
			// 1) the viewport is taller than the admin menu
			// 2) the viewport is wider than the min-width of the <body>
			// to float it only if it's collapsed add: $(document.body).hasClass('folded')
			if ( $(window).height() > this.adminMenuWrap.height() + 32 && $(window).width() > this.bodyMinWidth ) {
				if ( !$(document.body).hasClass( 'sticky-menu' ) )
					$(document.body).addClass( 'sticky-menu' );
			} else {
				if ( $(document.body).hasClass( 'sticky-menu' ) )
					$(document.body).removeClass( 'sticky-menu' );
			}

		}

	};

})( jQuery, window, document );
