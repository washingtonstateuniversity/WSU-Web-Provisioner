<?php
// @todo Clean this process up significantly. We should be able to use wp-cli during vagrant up

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

	// If this has already been run on the WordPress instance, bail.
	if ( false === get_site_option( 'wsu_networks_populated', false ) )
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
	populate_network( 2, 'network1.wp.wsu.edu', 'wsuwp.admin@wp.wsu.edu', 'Network 1', '/', true );

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
	populate_network( 3, 'network2.wp.wsu.edu', 'wsuwp.admin@wp.wsu.edu', 'Network 2', '/', true );

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
	populate_network( 4, 'school1.wsu.edu', 'wsuwp.admin@wp.wsu.edu', 'School 1', '/', true );

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
	populate_network( 5, 'school2.wsu.edu', 'wsuwp.admin@wp.wsu.ed', 'School 2', '/', true );

	wpmu_create_blog( 'school2.wsu.edu', '/',       'School 2',        1, '', 5 );
	wpmu_create_blog( 'school2.wsu.edu', '/site1/', 'School 2 Site 1', 1, '', 5 );
	wpmu_create_blog( 'school2.wsu.edu', '/site2/', 'School 2 Site 2', 1, '', 5 );

	update_site_option( 'wsu_networks_populated', true );
}

add_filter( 'populate_network_meta', 'wsu_populate_network_meta', 10, 1 );
/**
 * @param array $meta {
 *     - site_name                    => string 'School 1'
 *     - admin_email                  => string 'wsuwp-dev@wp.wsu.edu'
 *     - admin_user_id                => int 1
 *     - registration                 => string 'none'
 *     - upload_filetypes             => string 'jpg jpeg png gif mp3 mov avi wmv midi mid pdf'
 *     - blog_upload_space            => int 100
 *     - fileupload_maxk              => int 1500
 *     - site_admins                  => array(
 *         - 0 => 'admin'
 *     - allowedthemes                => array(
 *         - 'twentythirteen' => true
 *     - illegal_names                => array( www, web, root, admin, main, invite, administrator, files )
 *     - wpmu_upgrade_site            => int 25179
 *     - welcome_email                => string 'Dear User,

Your new SITE_NAME site has been successfully set up at:
BLOG_URL

You can log in to the administrator account with the following information:
Username: USERNAME
Password: PASSWORD
Log in here: BLOG_URLwp-login.php

We hope you enjoy your new site. Thanks!

--The Team @ SITE_NAME'
 *     - first_post                   => string 'Welcome to <a href="SITE_URL">SITE_NAME</a>. This is your first post. Edit or delete it, then start blogging!'
 *     - siteurl                      => string 'http://wp.wsu.edu/wordpress/'
 *     - add_new_users                => string '0'
 *     - upload_space_check_disabled' => string '1'
 *     - subdomain_install            => int 1
 *     - global_terms_enabled         => string '0'
 *     - ms_files_rewriting           => string '0'
 *     - initial_db_version           => string '24448'
 *     - active_sitewide_plugins      => array()
 *     - WPLANG                       => string 'en_US' (length=5)
 * }
 *
 * @return array
 */
function wsu_populate_network_meta( $meta ) {
	return $meta;
}
