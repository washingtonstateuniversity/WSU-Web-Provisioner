<?php
/*
 * Plugin Name: Debug Bar Network and Site
 * Plugin URI: http://web.wsu.edu
 * Description: Displays current network and site information in the debug bar. Requires the Debug Bar plugin.
 * Author: jeremyfelt, washingtonstateuniversity
 * Author URI: http://web.wsu.edu
 * Version: 0.1
 */

if ( ! defined( 'WPINC' ) ) {
	die;
}

add_filter( 'debug_bar_panels', 'debug_bar_network_site_panel' );
function debug_bar_network_site_panel( $panels ) {
	require_once 'class-debug-bar-network-site.php';
	$panels[] = new Debug_Bar_Network_Site();
	return $panels;
}
