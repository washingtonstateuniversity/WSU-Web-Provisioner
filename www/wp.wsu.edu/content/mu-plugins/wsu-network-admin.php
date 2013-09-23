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
		add_filter( 'parent_file',                       array( $this, 'add_master_network_menu' ), 10, 1 );
		add_action( 'admin_menu',                        array( $this, 'my_networks_dashboard'   ), 1     );
		add_filter( 'wpmu_validate_user_signup',         array( $this, 'validate_user_signup'    ), 10, 1 );
		add_filter( 'network_admin_plugin_action_links', array( $this, 'plugin_action_links'     ), 10, 3 );
		add_action( 'activate_plugin',                   array( $this, 'activate_global_plugin'  ), 10, 1 );
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
	 * Modify the plugin action links with our custom functionality
	 *
	 * @param array  $actions     Current assigned actions and links.
	 * @param string $plugin_file The plugin file associated with the action.
	 * @param array  $plugin_data Information about the plugin from the header.
	 *
	 * @return array The resulting array of actions and links assigned to the plugin.
	 */
	public function plugin_action_links( $actions, $plugin_file, $plugin_data ) {
		// $plugin_file = debug-bar/debug-bar.php
		// $plugin_data = array()
		//     Name, PluginURI, Version, Description, Author, AuthorURI, Title, AuthorName
		// pass a nonce
		if ( is_main_network() )
			$actions['global'] = '<a href="' . wp_nonce_url('plugins.php?action=activate&amp;wsu-activate-global=1&amp;plugin=' . $plugin_file, 'activate-plugin_' . $plugin_file) . '" title="Activate this plugin for all sites on all networks" class="edit">Global Activate</a>';
		return $actions;
	}

	/**
	 * Activate a plugin globally on all sites in all networks.
	 *
	 * @param string $plugin Slug of plugin to be activated.
	 *
	 * @return null
	 */
	public function activate_global_plugin( $plugin ) {

		if ( ! isset( $_GET['wsu-activate-global'] ) )
			return null;

		$networks = wp_get_networks();
		foreach ( $networks as $network ) {
			switch_to_network( $network->id );
			$current = get_site_option( 'active_sitewide_plugins', array() );
			$current[ $plugin ] = time();
			update_site_option( 'active_sitewide_plugins', $current );
			restore_current_network();
		}
	}

	/**
	 * Temporarily override user validation in anticpation of ticket #17904. In reality, we'll
	 * be doing all of our authentication through active directory, so this won't be necessary,
	 * but it does come in useful during initial testing.
	 *
	 * @param array $result Existing result from the wpmu_validate_user_signup() process
	 *
	 * @return array New results of our own validation
	 */
	public function validate_user_signup( $result ) {
		global $wpdb;

		$user_login = $result['user_name'];
		$original_user_login = $user_login;
		$result = array();
		$result['errors'] = new WP_Error();

		// User login cannot be empty
		if( empty( $user_login ) )
			$result['errors']->add( 'user_name', __( 'Please enter a username.' ) );

		// User login must be at least 4 characters
		if ( strlen( $user_login ) < 4 )
			$result['errors']->add( 'user_name',  __( 'Username must be at least 4 characters.' ) );

		// Strip any whitespace and then match against case insensitive characters a-z 0-9 _ . - @
		$user_login = preg_replace( '/\s+/', '', sanitize_user( $user_login, true ) );

		// If the previous operation generated a different value, the username is invalid
		if ( $user_login !== $original_user_login )
			$result['errors']->add( 'user_name', __( '<strong>ERROR</strong>: This username is invalid because it uses illegal characters. Please enter a valid username.' ) );

		// Check the user_login against an array of illegal names
		$illegal_names = get_site_option( 'illegal_names' );
		if ( false == is_array( $illegal_names ) ) {
			$illegal_names = array(  'www', 'web', 'root', 'admin', 'main', 'invite', 'administrator' );
			add_site_option( 'illegal_names', $illegal_names );
		}

		if ( true === in_array( $user_login, $illegal_names ) )
			$result['errors']->add( 'user_name',  __( 'That username is not allowed.' ) );

		// User login must have at least one letter
		if ( preg_match( '/^[0-9]*$/', $user_login ) )
			$result['errors']->add( 'user_name', __( 'Sorry, usernames must have letters too!' ) );

		// Check if the username has been used already.
		if ( username_exists( $user_login ) )
			$result['errors']->add( 'user_name', __( 'Sorry, that username already exists!' ) );

		if ( is_multisite() ) {
			// Is a signup already pending for this user login?
			$signup = $wpdb->get_row( $wpdb->prepare( "SELECT * FROM $wpdb->signups WHERE user_login = %s ", $user_login ) );
			if ( $signup != null ) {
				$registered_at =  mysql2date( 'U', $signup->registered );
				$now = current_time( 'timestamp', true );
				$diff = $now - $registered_at;
				// If registered more than two days ago, cancel registration and let this signup go through.
				if ( $diff > 2 * DAY_IN_SECONDS )
					$wpdb->delete( $wpdb->signups, array( 'user_login' => $user_login ) );
				else
					$result['errors']->add( 'user_name', __( 'That username is currently reserved but may be available in a couple of days.' ) );
			}
		}

		$result['user_login']          = $user_login;
		$result['original_user_login'] = $original_user_login;

		return $result;
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