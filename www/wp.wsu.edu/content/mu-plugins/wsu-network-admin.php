<?php

add_filter( 'parent_file', 'wsu_add_master_network_menu', 10, 1 );

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