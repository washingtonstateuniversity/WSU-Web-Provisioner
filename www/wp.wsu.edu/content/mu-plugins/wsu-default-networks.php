<?php

add_action( 'init', 'wsu_populate_network' );
function wsu_populate_network() {

	// Only do this in a specific local environment.
	if ( ! defined( 'WSU_LOCAL_CONFIG' ) || true !== WSU_LOCAL_CONFIG )
		return;

	require_once( ABSPATH . 'wp-admin/includes/schema.php' );
	populate_network( 2, 'network1.wp.wsu.edu', 'wsuwp-dev@wp.wsu.edu', 'Network 1', '/', true );
	populate_network( 3, 'network2.wp.wsu.edu', 'wsuwp-dev@wp.wsu.edu', 'Network 2', '/', true );
	populate_network( 4, 'network3.wp.wsu.edu', 'wsuwp-dev@wp.wsu.edu', 'Network 3', '/', true );

	/**
	 * Things to copy from current populate_network()
	 * 
	$current_site = new stdClass;
	$current_site->domain = $domain;
	$current_site->path = $path;
	$current_site->site_name = ucfirst( $domain );
	$wpdb->insert( $wpdb->blogs, array( 'site_id' => $network_id, 'domain' => $domain, 'path' => $path, 'registered' => current_time( 'mysql' ) ) );
	$current_site->blog_id = $blog_id = $wpdb->insert_id;
	update_user_meta( $site_user->ID, 'source_domain', $domain );
	update_user_meta( $site_user->ID, 'primary_blog', $blog_id );

	if ( $subdomain_install )
		$wp_rewrite->set_permalink_structure( '/%year%/%monthnum%/%day%/%postname%/' );
	else
		$wp_rewrite->set_permalink_structure( '/blog/%year%/%monthnum%/%day%/%postname%/' );

	flush_rewrite_rules();
	 */
}

// filter would be activated via #25020
//add_filter( 'populate_network_sitemeta', 'wsu_populate_network_sitemeta', 10, 1 );
/**
 * @param $sitemeta
 */
function wsu_populate_network_sitemeta( $sitemeta ) {
	return $sitemeta;
}
