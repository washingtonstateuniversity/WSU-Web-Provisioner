<?php

add_action( 'init', 'wsu_populate_network' );
/**
 * Populate a new WordPress multisite installation with a handful of default networks, each
 * with a couple of sites, to enable troubleshooting around the various URL structures that
 * will need to be supported.
 *
 * In order for this to fire, the WSU_LOCAL_CONFIG constant must be defined, most likely in
 * the local-config.php file.
 */
function wsu_populate_network() {

	// Only do this in a specific local environment.
	if ( ! defined( 'WSU_LOCAL_CONFIG' ) || true !== WSU_LOCAL_CONFIG || ! is_multisite() )
		return;

	// We need access to populate_network()
	require_once( ABSPATH . 'wp-admin/includes/schema.php' );

	/**
	 * The core site is setup already at wp.wsu.edu, there should be no other site
	 * assigned to this network as it will be used for managing global options and
	 * other networks.
	 */

	/**
	 * Create the network1.wp.wsu.edu network and two additional sites as subdomains
	 * on that network. This is an example of a standard network that extends the core
	 * wp.wsu.edu domain via subdomains.
	 *
	 *       network1.wp.wsu.edu
	 * site1.network1.wp.wsu.edu
	 * site2.network1.wp.wsu.edu
	 */
	populate_network( 2, 'network1.wp.wsu.edu', 'wsuwp-dev@wp.wsu.edu', 'Network 1', '/', true );

	wpmu_create_blog(       'network1.wp.wsu.edu', '/', 'Network 1',        1, '', 2 );
	wpmu_create_blog( 'site1.network1.wp.wsu.edu', '/', 'Network 1 Site 1', 1, '', 2 );
	wpmu_create_blog( 'site2.network1.wp.wsu.edu', '/', 'Network 1 Site 2', 1, '', 2 );

	/**
	 * Create the network2.wp.wsu.edu network and two additional sites as subfolders
	 * rather than subdomains. This is an example of a standard network that extends
	 * the core wp.wsu.edu domain via subfolders.
	 *
	 * network2.wp.wsu.edu
	 * network2.wp.wsu.edu/site1/
	 * network2.wp.wsu.edu/site2/
	 *
	 * Note: Most likely unstable if this note is here
	 */
	populate_network( 3, 'network2.wp.wsu.edu', 'wsuwp-dev@wp.wsu.edu', 'Network 2', '/', true );

	wpmu_create_blog( 'network2.wp.wsu.edu', '/',       'Network 2',        1, '', 3 );
	wpmu_create_blog( 'network2.wp.wsu.edu', '/site1/', 'Network 2 Site 1', 1, '', 3 );
	wpmu_create_blog( 'network2.wp.wsu.edu', '/site2/', 'Network 2 Site 2', 1, '', 3 );

	/**
	 * Create the school1.wsu.edu network and two additional sites as subdomains on
	 * that network. This is an example of a subdomain setup that does not use the core
	 * wp.wsu.edu domain associated with the initial WordPress install.
	 *
	 *       school1.wsu.edu
	 * site1.school1.wsu.edu
	 * site2.school1.wsu.edu
	 */
	populate_network( 4, 'school1.wsu.edu', 'wsuwp-dev@wp.wsu.edu', 'School 1', '/', true );

	wpmu_create_blog(       'school1.wsu.edu', '/', 'School 1',        1, '', 4 );
	wpmu_create_blog( 'site1.school1.wsu.edu', '/', 'School 1 Site 1', 1, '', 4 );
	wpmu_create_blog( 'site2.school1.wsu.edu', '/', 'School 1 Site 2', 1, '', 4 );

	/**
	 * Create the school2.wsu.edu network and two additional sites using subfolders
	 * rather than subdomains. This is an example of a subfolder setup that does not use
	 * the core wp.wsu.edu domain associated with the initial WordPress install.
	 *
	 * school2.wsu.edu
	 * school2.wsu.edu/site1/
	 * school2.wsu.edu/site2/
	 *
	 * Note: Most likely unstable if this note is here
	 */
	populate_network( 5, 'school2.wsu.edu', 'wsuwp-dev@wp.wsu.ed', 'School 2', '/', true );

	wpmu_create_blog( 'school2.wsu.edu', '/',       'School 2',        1, '', 5 );
	wpmu_create_blog( 'school2.wsu.edu', '/site1/', 'School 2 Site 1', 1, '', 5 );
	wpmu_create_blog( 'school2.wsu.edu', '/site2/', 'School 2 Site 2', 1, '', 5 );
}

// filter would be activated via #25020
//add_filter( 'populate_network_sitemeta', 'wsu_populate_network_sitemeta', 10, 1 );
/**
 * @param $sitemeta
 */
function wsu_populate_network_sitemeta( $sitemeta ) {
	return $sitemeta;
}
