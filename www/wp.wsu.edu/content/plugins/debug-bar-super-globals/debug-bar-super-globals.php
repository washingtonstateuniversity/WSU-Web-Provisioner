<?php  if ( ! defined( 'ABSPATH' ) ) exit;
/*
Plugin Name: Debug Bar Super Globals
Plugin URI: http://www.kakunin-pl.us
Description: Displays Super Global valiables for the current request.Like $_POST, $_GET, and $_COOKIE. Requires the debug bar plugin.
Author: horike takahiro
Version: 0.1
*/

add_filter( 'debug_bar_panels', 'debug_bar_super_globals_panel' );
if ( ! function_exists( 'debug_bar_super_globals_panel' ) ) {
    function debug_bar_super_globals_panel( $panels ) {
        require_once 'class-debug-bar-super-globals.php';
        $panels[] = new Debug_Bar_Super_Globals();
        return $panels;
    }
}


add_action('debug_bar_enqueue_scripts', 'debug_bar_super_globals_scripts');
function debug_bar_super_globals_scripts() {
	wp_enqueue_style( 'debug-bar-super_globals', plugins_url( "css/debug-bar-super-globals.css", __FILE__ ) );
}
