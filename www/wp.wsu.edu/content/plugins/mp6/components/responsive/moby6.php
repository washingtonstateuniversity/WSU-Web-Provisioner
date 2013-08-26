<?php

add_action( 'init', 'moby6_init' );
function moby6_init() {
	// add viewport meta tag to to admin
	add_action( 'admin_head', 'moby6_viewport_meta' );

	// load admin styles/scripts
	add_action( 'admin_print_styles', 'moby6_enqueue_styles' );
	add_action( 'admin_print_scripts', 'moby6_enqueue_scripts' );

	// load admin-bar styles
	add_action( 'admin_print_styles', 'moby6_enqueue_adminbar_styles' );
	add_action( 'wp_enqueue_scripts', 'moby6_enqueue_adminbar_styles' );
}

function moby6_viewport_meta() {
	echo '<meta name="viewport" content="width=device-width,user-scalable=no,initial-scale=1.0,maximum-scale=1.0">';
}

function moby6_enqueue_styles() {
	$modtime = filemtime( plugin_dir_path( __FILE__ ) . 'css/moby6.css' );
	wp_enqueue_style( 'moby6', plugins_url( 'css/moby6.css', __FILE__ ), false, $modtime );
}

function moby6_enqueue_scripts() {
	$modtime = filemtime( plugin_dir_path( __FILE__ ) . 'js/moby6.js' );
	wp_enqueue_script( 'moby6', plugins_url( 'js/moby6.js', __FILE__ ), array( 'jquery', 'backbone' ), $modtime );
	wp_enqueue_script( 'moby6-jq-mobile', plugins_url( 'js/jquery.mobile.custom.min.js', __FILE__ ), array( 'jquery' ), '1.3.1' );
}

function moby6_enqueue_adminbar_styles() {
	if ( is_admin_bar_showing() ) {
		$modtime = filemtime( plugin_dir_path( __FILE__ ) . 'css/admin-bar.css' );
		wp_enqueue_style( 'moby6-admin-bar', plugins_url( 'css/admin-bar.css', __FILE__ ), false, $modtime );
	}
}