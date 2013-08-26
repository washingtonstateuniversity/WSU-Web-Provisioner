;( function( $, window, document, undefined ) {

	'use strict';

	window.moby6 = {
		init: function() {
			var _self = this;

			// cached selectors
			this.$html = $( document.documentElement );
			this.$body = $( document.body );
			this.$wpwrap = $( '#wpwrap' );
			this.$wpbody = $( '#wpbody' );
			this.$adminmenu = $( '#adminmenu' );
			this.$overlay = $( '#moby6-overlay' );
			this.$toolbar = $( '#wp-toolbar' );
			this.$toolbarPopups = this.$toolbar.find( 'a[aria-haspopup="true"]' );

			// jQuery Mobile swipe event
			$.event.special.swipe.scrollSupressionThreshold = 100; // Default: 30px; More than this horizontal displacement, and we will suppress scrolling.
			$.event.special.swipe.durationThreshold = 1000; // Default: 1000ms;  More time than this, and it isn't a swipe.
			$.event.special.swipe.horizontalDistanceThreshold = 100; // Default: 30px; Swipe horizontal displacement must be more than this.
			$.event.special.swipe.verticalDistanceThreshold = 75; // Default: 75px; Swipe vertical displacement must be less than this.

			// Modify functionality based on custom activate/deactivate event
			this.$html
				.on( 'activate.moby6', function() { _self.activate(); } )
				.on( 'deactivate.moby6', function() { _self.deactivate(); } );

			// Remove browser chrome
			window.scrollTo( 0, 1 );

			// Trigger custom events based on active media query.
			this.matchMedia();
			$( window ).on( 'resize', $.proxy( this.matchMedia, this ) );
		},

		activate: function() {

			window.stickymenu && stickymenu.disable();

			if ( ! moby6.$body.hasClass( 'auto-fold' ) )
				this.$body.addClass( 'auto-fold' );

			$( document ).on( 'swiperight.moby6', function() {
				this.$wpwrap.addClass( 'moby6-open' );
			}).on( 'swipeleft.moby6', function() {
				this.$wpwrap.removeClass( 'moby6-open' );
			});

			this.modifySidebarEvents();
			this.disableDraggables();
			this.insertHamburgerButton();
			this.movePostSearch();

		},

		deactivate: function() {

			window.stickymenu && stickymenu.enable();

			$( document ).off( 'swiperight.moby6 swipeleft.moby6' );

			this.enableDraggables();
			this.removeHamburgerButton();
			this.restorePostSearch();

		},

		matchMedia: function() {
			clearTimeout( this.resizeTimeout );
			this.resizeTimeout = setTimeout( function() {

				if ( ! window.matchMedia )
					return;

				if ( window.matchMedia( '(max-width: 782px)' ).matches ) {
					if ( moby6.$html.hasClass( 'touch' ) )
						return;
					moby6.$html.addClass( 'touch' ).trigger( 'activate.moby6' );
				} else {
					if ( ! moby6.$html.hasClass( 'touch' ) )
						return;
					moby6.$html.removeClass( 'touch' ).trigger( 'deactivate.moby6' );
				}

				if ( window.matchMedia( '(max-width: 480px)' ).matches ) {
					moby6.enableOverlay();
				} else {
					moby6.disableOverlay();
				}

			}, 150 );
		},

		enableOverlay: function() {
			if ( this.$overlay.length == 0 ) {
				this.$overlay = $( '<div id="moby6-overlay"></div>' )
					.insertAfter( '#wpcontent' )
					.hide()
					.on( 'click.moby6', function() {
						moby6.$toolbar.find( '.menupop.hover' ).removeClass( 'hover' );
						$( this ).hide();
					});
			}
			this.$toolbarPopups.on( 'click.moby6', function() {
				moby6.$overlay.show();
			});
		},

		disableOverlay: function() {
			this.$toolbarPopups.off( 'click.moby6' );
			this.$overlay.hide();
		},



		modifySidebarEvents: function() {
			this.$body.off( '.wp-mobile-hover' );
			this.$adminmenu.find( 'a.wp-has-submenu' ).off( '.wp-mobile-hover' );

			var scrollStart = 0;
			this.$adminmenu.on( 'touchstart.moby6', 'li.wp-has-submenu > a', function() {
				scrollStart = $( window ).scrollTop();
			});

			this.$adminmenu.on( 'touchend.moby6', 'li.wp-has-submenu > a', function( e ) {
				e.preventDefault();

				if ( $( window ).scrollTop() !== scrollStart )
					return false;

				$( this ).find( 'li.wp-has-submenu' ).removeClass( 'selected' );
				$( this ).parent( 'li' ).addClass( 'selected' );
			});
		},

		disableDraggables: function() {
			this.$wpbody
				.find( '.hndle' )
				.removeClass( 'hndle' )
				.addClass( 'hndle-disabled' );
		},

		enableDraggables: function() {
			this.$wpbody
				.find( '.hndle-disabled' )
				.removeClass( 'hndle-disabled' )
				.addClass( 'hndle' );
		},

		insertHamburgerButton: function() {
			this.$wpbody
				.find( '.wrap' )
				.prepend( '<div id="moby6-toggle"></div>' );

			this.hamburgerButtonView = new Moby6HamburgerButton( { el: $( '#moby6-toggle' ) } );
		},

		removeHamburgerButton: function() {
			if ( this.hamburgerButtonView !== undefined )
				this.hamburgerButtonView.destroy();
		},

		movePostSearch: function() {
			this.searchBox = this.$wpbody.find( 'p.search-box' );
			if ( this.searchBox.length ) {
				this.searchBox.hide();
				if ( this.searchBoxClone === undefined ) {
					this.searchBoxClone = this.searchBox.first().clone().insertAfter( 'div.tablenav.bottom' );
				}
				this.searchBoxClone.show();
			}
		},

		restorePostSearch: function() {
			if ( this.searchBox !== undefined ) {
				this.searchBox.show();
				if ( this.searchBoxClone !== undefined )
					this.searchBoxClone.hide();
			}
		}

	}

	$( document ).ready( $.proxy( moby6.init, moby6 ) );

	/* Hamburger button view */
	var Moby6HamburgerButton = Backbone.View.extend({
		events: {
			'click': 'toggleSidebar'
		},

		initialize: function() {
			this.render();
		},

		render: function() {
			// Needs to be in a translatable template.
			this.$el.html( '<a href="#" title="Menu"></a>' );
			return this;
		},

		toggleSidebar: function(e) {
			e.preventDefault();
			moby6.$wpwrap.toggleClass( 'moby6-open' );
		},

		destroy: function() {
			this.undelegateEvents();
			this.$el.removeData().unbind();
			this.remove();
			Backbone.View.prototype.remove.call( this );
		}
	});

})( jQuery, window, document );