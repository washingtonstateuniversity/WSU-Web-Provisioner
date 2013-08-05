<?php

add_filter( 'parent_file', 'wsu_add_master_network_menu', 10, 1 );

/**
 * Add a top level menu item for 'Networks' to the network administration sidebar
 */
function wsu_add_master_network_menu() {
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

add_action( 'admin_menu', 'wsu_dashboard_my_networks',1 );
/**
 * Add a dashboard page to manage all WSU Networks that a user has access to
 */
function wsu_dashboard_my_networks() {
	add_dashboard_page( 'My Networks Dashboard', 'My WSU Networks', 'read', 'my-wsu-networks', 'wsu_display_my_networks' );
}

/**
 * Output the dashboard page for WSU Networks
 */
function wsu_display_my_networks() {
	echo 'WSU Network Dashboard';
}
