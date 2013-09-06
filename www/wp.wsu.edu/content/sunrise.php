<?php
/**
 * The sunrise file for WSUWP
 *
 * @type WPDB $wpdb
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

if ( ! $current_blog = wp_cache_get( 'wsuwp:site:' . $requested_domain . $requested_path ) ) {
	// Treat www the same as the root URL
	$alternate_domain = preg_replace( '|^www\.|', '', $requested_domain );

	//suppress errors and capture current suppression setting
	$suppression = $wpdb->suppress_errors();

	if ( $requested_domain !== $alternate_domain )
		$domain_where = $wpdb->prepare( "domain IN ( %s, %s )", $requested_domain, $alternate_domain );
	else
		$domain_where = $wpdb->prepare( "domain = %s", $requested_domain );

	/**
	 * The following query will find any one level deep subfolder sites on any page view, but
	 * will only help us with subdomain networks if it is a root visit with an empty path. If
	 * this returns null, we'll want to go to a backup.
	 */
	$query = $wpdb->prepare( "SELECT blog_id FROM $wpdb->blogs WHERE $domain_where AND path = %s", $requested_path );
	$found_site_id = $wpdb->get_var( $query );

	/**
	 * If the query for domain and path has failed, then we'll assume this is a site that has
	 * no path assigned and search for that accordingly.
	 */
	if ( ! $found_site_id ) {
		$query = "SELECT blog_id FROM $wpdb->blogs WHERE $domain_where and path = '/' ";
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
	if( $found_site_id )
		$current_blog = $wpdb->get_row( $wpdb->prepare( "SELECT * FROM $wpdb->blogs WHERE blog_id = %d LIMIT 1", $found_site_id ) );

	if ( $current_blog )
		wp_cache_set( 'wsuwp:site:' . $requested_domain . $requested_path, $current_blog, '', 60 * 60 * 12 );

}

if( $current_blog ) {

	//set the blog_id and site_id globals that WordPress expects
	$blog_id = $current_blog->blog_id;
	$site_id = $current_blog->site_id;

	if ( ! $current_site = wp_cache_get( 'wsuwp:network:' . $site_id ) ) {
		$current_site = $wpdb->get_row( $wpdb->prepare( "SELECT * from $wpdb->site WHERE id = %d LIMIT 0,1", $site_id ) );

		// Add blog ID after the fact because it is required by both scenarios
		$current_site->blog_id = $blog_id;

		// Attach the site name to our current_site object. This uses cache already.
		$current_site = get_current_site_name( $current_site );

		wp_cache_set( 'wsuwp:network:' . $site_id, $current_site, '', 60 * 60 * 12 );
	}

	define( 'COOKIE_DOMAIN', $requested_domain );
	define( 'DOMAIN_MAPPING', 1 );
} else {
	/**
	 * If we've made it here, the domain and path provided aren't doing us much good. At this
	 * point, we're okay to forget about the path and focus on best effort for the domain. Our
	 * first bet is to drop off the first part of the domain to see if it really is a subdomain
	 * request.
	 */
	$redirect_domain_parts = explode( '.', $requested_domain );
	array_shift( $redirect_domain_parts );
	$redirect_domain = implode( '.', $redirect_domain_parts );

	// Check to see if this redirect domain is a site that we can handle
	$redirect_site_id = $wpdb->get_var( $wpdb->prepare( "SELECT blog_id FROM $wpdb->blogs WHERE domain = %s", $redirect_domain ) );

	/** @todo think about santizing this properly as esc_url() and wp_redirect() are not available yet */
	if ( $redirect_site_id )
		header( "Location: http://" . $redirect_domain, true, 302 );
	else
		header( "Location: http://" . DOMAIN_CURRENT_SITE, true, 302 );

	die();
}
