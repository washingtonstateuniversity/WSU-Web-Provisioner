<?php
/**
 * The sunrise file for WSUWP
 */

if ( defined( 'COOKIE_DOMAIN' ) )
	die( 'The constant "COOKIE_DOMAIN" is defined (probably in wp-config.php). Please remove or comment out that define() line.' );

// capture the current domain request
$requested_domain    = $_SERVER['HTTP_HOST'];
$requested_uri       = trim( $_SERVER['REQUEST_URI'], '/' );

// If we only support one subfolder deep, then this will be it
// otherwise, we may need to find a site option that matches the domain to indicate depth level
$requested_uri_parts = explode( '/', $requested_uri );
$requested_path = $requested_uri_parts[0] . '/';

// If we're dealing with a root domain, we want to leave it at /
if ( '/' !== $requested_path )
	$requested_path = '/' . $requested_path;

/** @todo implement an object cache to capture this */

// Treat www the same as the root URL
$alternate_domain = preg_replace( '|^www\.|', '', $requested_domain );

/** @type WPDB $wpdb  */
if ( $requested_domain !== $alternate_domain )
	$where = $wpdb->prepare( 'wp_postmeta.meta_value IN ( %s, %s )', $requested_domain, $alternate_domain );
else
	$where = $wpdb->prepare( 'wp_postmeta.meta_value = %s', $requested_domain );

//suppress errors and capture current suppression setting
$suppression = $wpdb->suppress_errors();

/**
 * The following query will find any one level deep subfolder sites on any page view, but
 * will only help us with subdomain networks if it is a root visit with an empty path. If
 * this returns null, we'll want to go to a backup.
 */
$query = $wpdb->prepare( "SELECT blog_id FROM $wpdb->blogs WHERE domain = %s AND path = %s", $requested_domain, $requested_path );
$found_site_id = $wpdb->get_var( $query );

/**
 * If the query for domain and path has failed, then we'll assume this is a site that has
 * no path assigned and search for that accordingly.
 */
if ( ! $found_site_id ) {
	$query = $wpdb->prepare( "SELECT blog_id FROM $wpdb->blogs WHERE domain = %s and path = '/' ", $requested_domain );
	$found_site_id = $wpdb->get_var( $query );
}

//reset error suppression setting
$wpdb->suppress_errors( $suppression );

/**
 * If we found a blog_id to match the domain above, then we turn to WordPress to get the
 * remaining bits of info from the standard wp_blogs and wp_site tables. Then we squash
 * it all together in the $current_site, $current_blog, $site_id, and $blog_id globals so
 * that it is available for the remaining operations on this page request.
 */
if( $found_site_id ) {
	$current_blog = $wpdb->get_row( $wpdb->prepare( "SELECT * FROM $wpdb->blogs WHERE blog_id = %d LIMIT 1", $found_site_id ) );

	//set the blog_id and site_id globals that WordPress expects
	$blog_id = $found_site_id;
	$site_id = $current_blog->site_id;

	$current_site = $wpdb->get_row( $wpdb->prepare( "SELECT * from $wpdb->site WHERE id = %d LIMIT 0,1", $site_id ) );

	// Add blog ID after the fact because it is required by both scenarios
	$current_site->blog_id = $blog_id;

	// Attach the site name to our current_site object. This uses cache already.
	$current_site = get_current_site_name( $current_site );

	define( 'COOKIE_DOMAIN', $requested_domain );
	define( 'DOMAIN_MAPPING', 1 );
}
