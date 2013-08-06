<?php
/**
 * Class WSU_Network_Admin
 *
 * Adds various WSU customizations to handle networks in WordPress
 */
class WSU_Network_Admin {

	/**
	 * Maintain the single instance of WSU_Network_Admin
	 *
	 * @var bool|WSU_Network_Admin
	 */
	private static $instance = false;

	/**
	 * Add the filters and actions used
	 */
	private function __construct() {
		add_filter( 'parent_file', array( $this, 'add_master_network_menu' ), 10, 1 );
		add_action( 'admin_menu', array( $this, 'my_networks_dashboard' ), 1 );
	}

	/**
	 * Handle requests for the instance.
	 *
	 * @return bool|WSU_Network_Admin
	 */
	public static function get_instance() {
		if ( ! self::$instance )
			self::$instance = new WSU_Network_Admin();
		return self::$instance;
	}

	/**
	 * Add a top level menu item for 'Networks' to the network administration sidebar
	 */
	function add_master_network_menu() {
		if ( is_network_admin() ) {
			global $menu;
			$menu[6] = $menu[5];
			unset( $menu[5] );
			$menu[6][4] = 'menu-top menu-icon-site';
			$menu[5] = array(
				'Networks',
				'manage_networks',
				'networks.php',
				'',
				'menu-top menu-icon-site menu-top-first',
				'menu-site',
				'div',
			);
			ksort( $menu );
		}
	}

	/**
	 * Add a dashboard page to manage all WSU Networks that a user has access to
	 */
	function my_networks_dashboard() {
		add_dashboard_page( 'My Networks Dashboard', 'My WSU Networks', 'read', 'my-wsu-networks', array( $this, 'display_my_networks' ) );
	}

	/**
	 * Output the dashboard page for WSU Networks
	 */
	function display_my_networks() {
		?>
		<div class="wrap">
			<?php screen_icon( 'ms-admin' ); ?>
		<h2>My Networks<?php
	}

}
WSU_Network_Admin::get_instance();