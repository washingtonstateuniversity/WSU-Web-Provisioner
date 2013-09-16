<?php
/*
Plugin Name: Plugin Activation Status
Description: This plugin scans an entire WordPress multisite or multi-network installation and identifies which plugins are active (and where they're active) and which plugins are not activated anywhere in the install
Version: 0.2
Author: Curtiss Grymala
Author URI: http://www.umw.edu/
License: GPL2
Network: true
*/

if ( ! class_exists( 'Plugin_Activation_Status' ) ) {
	if ( file_exists( plugin_dir_path( __FILE__ ) . 'class-plugin-activation-status.php' ) )
		require_once( plugin_dir_path( __FILE__ ) . 'class-plugin-activation-status.php' );
	elseif ( file_exists( plugin_dir_path( __FILE__ ) . 'plugin-activation-status/class-plugin-activation-status.php' ) )
		require_once( plugin_dir_path( __FILE__ ) . 'plugin-activation-status/class-plugin-activation-status.php' );
}

add_action( 'plugins_loaded', 'inst_plugin_activation_status' );
function inst_plugin_activation_status() {
	if ( ! class_exists( 'Plugin_Activation_Status' ) )
		return;
	
	global $plugin_activation_status_obj;
	$plugin_activation_status_obj = new Plugin_Activation_Status;
}