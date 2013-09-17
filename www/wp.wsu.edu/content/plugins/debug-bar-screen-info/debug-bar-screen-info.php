<?php
/**
 * Debug Bar Screen Info
 *
 * Show screen info of the current admin page in a new tab within the debug bar
 *
 * @package   debug-bar-screen-info
 * @author    Brad Vincent <brad@fooplugins.com>
 * @license   GPL-2.0+
 * @link      https://github.com/fooplugins/debug-bar-screen-info
 * @copyright 2013 FooPlugins LLC
 *
 * @wordpress-plugin
 * Plugin Name: Debug Bar Screen Info
 * Plugin URI:  https://github.com/fooplugins/debug-bar-screen-info
 * Description: Show screen info of the current admin page in a new tab within the debug bar
 * Version:     1.0.0
 * Author:      bradvin
 * Author URI:  http://fooplugins.com
 * Text Domain: foobox
 * License:     GPL-2.0+
 * License URI: http://www.gnu.org/licenses/gpl-2.0.txt
 */

// If this file is called directly, abort.
if ( ! defined( 'WPINC' ) ) {
	die;
}

//include plugin class
require_once( plugin_dir_path( __FILE__ ) . 'class-debug-bar-screen-info.php' );

//run it baby!
Debug_Bar_Admin_Screen_Info::get_instance();