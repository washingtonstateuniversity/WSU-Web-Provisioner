<?php

function mp6_stickymenu_enqueue_scripts() {

	// disable floating on mobile devices, except iPads
	$ua = empty( $_SERVER[ 'HTTP_USER_AGENT' ] ) ? '' : $_SERVER[ 'HTTP_USER_AGENT' ];
	if ( wp_is_mobile() && strpos( $ua, 'iPad' ) === false )
		return;

	wp_enqueue_script( 'mp6-stickymenu', plugins_url( 'scripts.js', __FILE__ ), array( 'jquery' ) );
	wp_enqueue_style( 'mp6-stickymenu', plugins_url( 'styles.css', __FILE__ ) );

}

add_action( 'admin_enqueue_scripts', 'mp6_stickymenu_enqueue_scripts' );
