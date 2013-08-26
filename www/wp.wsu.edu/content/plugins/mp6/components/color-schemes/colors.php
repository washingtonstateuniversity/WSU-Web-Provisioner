<?php

/***********************************************************************************

  This component is in an experimental stage and it's behavior
  might change in the future!

************************************************************************************/

// register additonal MP6 color schemes
add_action( 'admin_init' , 'mp6_colors_register_schemes', 7 );
function mp6_colors_register_schemes() {

	global $_wp_admin_css_colors;

	// Blue
	wp_admin_css_color(
		'blue',
		'Blue',
		plugins_url( 'schemes/blue/colors.css', __FILE__ ),
		array( '#096484', '#4796b3', '#52accc', '#e5f8ff' )
	);

	$_wp_admin_css_colors[ 'blue' ]->icon_colors = array(
		'base' => '#e5f8ff',
		'focus' => '#fff',
		'current' => '#fff'
	);

	// Malibu Dreamhouse
	wp_admin_css_color(
		'malibu-dreamhouse',
		'Malibu Dreamhouse',
		plugins_url( 'schemes/malibu-dreamhouse/colors.css', __FILE__ ),
		array( '#b476aa', '#c18db8', '#e5cfe1', '#70c0aa' )
	);

	$_wp_admin_css_colors[ 'malibu-dreamhouse' ]->icon_colors = array(
		'base' => '#e5cfe1',
		'focus' => '#fff',
		'current' => '#fff'
	);

}

// make sure `colors-mp6.css` gets enqueued
add_action( 'admin_init', 'mp6_colors_load_mp6_default_css', 20 );
function mp6_colors_load_mp6_default_css() {

	global $wp_styles, $_wp_admin_css_colors;

	$color_scheme = get_user_option( 'admin_color' );

	if ( $color_scheme == 'mp6' )
		return;

	// add `colors-mp6.css` and make it a dependency of the current color scheme
	$modtime = filemtime( realpath( dirname( __DIR__ ) . '/../css/' . basename( $_wp_admin_css_colors[ 'mp6' ]->url ) ) );
	$wp_styles->add( 'colors-mp6', $_wp_admin_css_colors[ 'mp6' ]->url, false, $modtime );
	$wp_styles->registered[ 'colors' ]->deps[] = 'colors-mp6';

	// remove incorrect modification time
	$wp_styles->registered[ 'colors' ]->ver = false;

}

// turn `$color_scheme->scheme` into `mp6_color_scheme` javascript variable
add_action( 'admin_head', 'mp6_colors_set_script_colors' );
function mp6_colors_set_script_colors() {

	global $_wp_admin_css_colors;

	$color_scheme = get_user_option( 'admin_color' );

	if ( $color_scheme == 'mp6' )
		return;

	if ( isset( $_wp_admin_css_colors[ $color_scheme ]->icon_colors ) ) {
		echo '<script type="text/javascript">var mp6_color_scheme = ' . json_encode( array( 'icons' => $_wp_admin_css_colors[ $color_scheme ]->icon_colors ) ) . ";</script>\n";
	}

}
