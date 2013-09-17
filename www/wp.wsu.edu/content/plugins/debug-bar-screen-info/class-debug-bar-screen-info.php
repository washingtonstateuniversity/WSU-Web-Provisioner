<?php
/**
 * Debug Bar Screen Info
 *
 * @package   debug-bar-screen-info
 * @author    Brad Vincent <brad@fooplugins.com>
 * @license   GPL-2.0+
 * @link      https://github.com/fooplugins/debug-bar-screen-info
 * @copyright 2013 FooPlugins LLC
 */

class Debug_Bar_Admin_Screen_Info {

	/**
	 * Plugin version, used for cache-busting of style and script file references.
	 *
	 * @since   1.0.0
	 *
	 * @var     string
	 */
	protected $version = '1.0.0';

	/**
	 * Unique identifier for your plugin.
	 *
	 * @since    1.0.0
	 *
	 * @var      string
	 */
	protected $plugin_slug = 'debug-bar-screen-info';

	/**
	 * Instance of this class.
	 *
	 * @since    1.0.0
	 *
	 * @var      object
	 */
	protected static $instance = null;

	/**
	 * Return an instance of this class.
	 *
	 * @since     1.0.0
	 *
	 * @return    object    A single instance of this class.
	 */
	public static function get_instance() {

		// If the single instance hasn't been set, set it now.
		if ( null == self::$instance ) {
			self::$instance = new self;
		}

		return self::$instance;
	}

	/**
	 * Initialize the plugin
	 *
	 * @since     1.0.0
	 */
	private function __construct() {
		add_filter( 'debug_bar_panels', array($this, 'screen_info_panel' ) );
	}

	function screen_info_panel( $panels ) {
		require_once( 'class-debug-bar-screen-info-panel.php' );
		$panel = new Debug_Bar_Screen_Info_Panel();
		$panel->set_tab( 'Screen Info', array($this, 'screen_info_render') );
		$panels[] = $panel;
		return $panels;
	}

	function screen_info_render() {
		$screen = get_current_screen();

		if ($screen !== null) {

			$output = '<table>
	<tr><td colspan="3"><h2>'.__('Screen Info', 'debug-bar-screen-info').'</h2></td></tr>
	<tr><td>'. __('id','debug-bar-screen-info').'</td><td><strong>'.$screen->id.'</strong></td><td><small>('.__('The unique ID of the screen','debug-bar-screen-info').')</small></td></tr>
	<tr><td>'. __('action','debug-bar-screen-info').'</td><td><strong>'.$screen->action.'</strong></td><td><small>('.__('Any action associated with the screen','debug-bar-screen-info').')</small></td></tr>
	<tr><td>'. __('base','debug-bar-screen-info').'</td><td><strong>'.$screen->base.'</strong></td><td><small>('.__('The base type of the screen. This is typically the same as id but with any post types and taxonomies stripped','debug-bar-screen-info').')</small></td></tr>
	<tr><td>'. __('parent_base','debug-bar-screen-info').'</td><td><strong>'.$screen->parent_base.'</strong></td><td><small>('.__('The base menu parent.','debug-bar-screen-info').')</small></td></tr>
	<tr><td>'. __('parent_file','debug-bar-screen-info').'</td><td><strong>'.$screen->parent_file.'</strong></td><td><small>('.__('The parent_file for the screen per the admin menu system','debug-bar-screen-info').')</small></td></tr>
	<tr><td>'. __('post_type','debug-bar-screen-info').'</td><td><strong>'.$screen->post_type.'</strong></td><td><small>('.__('The post type associated with the screen, if any','debug-bar-screen-info').')</small></td></tr>
	<tr><td>'. __('taxonomy','debug-bar-screen-info').'</td><td><strong>'.$screen->taxonomy.'</strong></td><td><small>('.__('The taxonomy associated with the screen, if any','debug-bar-screen-info').')</small></td></tr>
</table>
';
		} else {
			$output = '<h2>'.__('No Screen Info Found', 'debug-bar-screen-info').'</h2>';
		}

		return $output;
	}
}