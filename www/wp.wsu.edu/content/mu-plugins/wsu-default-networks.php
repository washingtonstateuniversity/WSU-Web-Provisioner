<?php

add_action( 'init', 'wsu_populate_network' );
function wsu_populate_network() {

	// Only do this in a specific local environment.
	if ( ! defined( 'WSU_LOCAL_CONFIG' ) || true !== WSU_LOCAL_CONFIG || ! is_multisite() )
		return;

	require_once( ABSPATH . 'wp-admin/includes/schema.php' );

	/**
	 * The core site is setup already at wp.wsu.edu, there should be no other site
	 * assigned to this network as it will be used for managing global options and
	 * other networks.
	 */

	/**
	 * Create network1.wp.wsu.edu and two additional sites as subdomains on that
	 * network. This is an example of a standard network that extends the core
	 * wp.wsu.edu domain via subdomains.
	 */
	populate_network( 2, 'network1.wp.wsu.edu', 'wsuwp-dev@wp.wsu.edu', 'Network 1', '/', true );
	wpmu_create_blog( 'network1.wp.wsu.edu', '/', 'Network 1', 1, '', 2 );
	wpmu_create_blog( 'site1.network1.wp.wsu.edu', '/', 'Network 1 Site 1', 1, '', 2 );
	wpmu_create_blog( 'site2.network1.wp.wsu.edu', '/', 'Network 1 Site 2', 1, '', 2 );

	/**
	 * Create network2.wp.wsu.edu and two additional sites as subfolders rather than
	 * sub domains.
	 */
	populate_network( 3, 'network2.wp.wsu.edu', 'wsuwp-dev@wp.wsu.edu', 'Network 2', '/', true );
	wpmu_create_blog( 'network2.wp.wsu.edu', '/', 'Network 2', 1, '', 3 );
	wpmu_create_blog( 'network2.wp.wsu.edu', '/site1/', 'Network 2 Site 1', 1, '', 3 );
	wpmu_create_blog( 'network2.wp.wsu.edu', '/site2/', 'Network 2 Site 2', 1, '', 3 );

	/**
	 * Create wp-school1.wsu.edu and two additional sites as subdomains on that
	 * network. This is an example of a subdomain setup that does not use the core
	 * wp.wsu.edu domain.
	 */
	populate_network( 4, 'wp-school1.wsu.edu', 'wsuwp-dev@wp.wsu.edu', 'School 1', '/', true );
	wpmu_create_blog( 'wp-school1.wsu.edu', '/', 'School 1', 1, '', 4 );
	wpmu_create_blog( 'site1.wp-school1.wsu.edu', '/', 'School 1 Site 1', 1, '', 4 );
	wpmu_create_blog( 'site2.wp-school1.wsu.edu', '/', 'School 1 Site 2', 1, '', 4 );

	/**
	 * Create wp-school2.wsu.edu and two additional sites using subfolders rather than
	 * sub domains.
	 */
	populate_network( 5, 'wp-school2.wsu.edu', 'wsuwp-dev@wp.wsu.ed', 'School 2', '/', true );
	wpmu_create_blog( 'wp-school2.wsu.edu', '/', 'School 2', 1, '', 5 );
	wpmu_create_blog( 'wp-school2.wsu.edu', '/site1/', 'School 2 Site 1', 1, '', 5 );
	wpmu_create_blog( 'wp-school2.wsu.edu', '/site2/', 'School 2 Site 2', 1, '', 5 );
}

// filter would be activated via #25020
//add_filter( 'populate_network_sitemeta', 'wsu_populate_network_sitemeta', 10, 1 );
/**
 * @param $sitemeta
 */
function wsu_populate_network_sitemeta( $sitemeta ) {
	return $sitemeta;
}
