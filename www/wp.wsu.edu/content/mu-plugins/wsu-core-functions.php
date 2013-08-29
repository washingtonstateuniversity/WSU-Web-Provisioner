<?php
/**
 * Functions that perform some core functionality that we would love to live inside
 * of WordPress one day.
 */

/**
 * Retrieve a list of sites that with which the passed user has associated capabilities.
 *
 * @param int $user_id ID of the user
 * @param bool $all False to return all sites. True will return only those not marked as archived, spam, or deleted
 *
 * @return array A list of user's sites. An empty array of the user does not have any capabilities to any sites
 */
function wp_get_user_sites( $user_id, $all = false ) {
	return get_blogs_of_user( $user_id, $all );
}

/**
 * A wrapper with a better name for get_current_site() to avoid being so misleading
 * on the actual purpose. Returns what WordPress knows as the current site, which in
 * reality is the current network.
 *
 * @return object with current network information
 */
function wp_get_current_network() {
	return get_current_site();
}

/**
 * A wrapper with a better name for get_blog_details(). Returns what WordPress knows
 * as the current blog (by not passing any arguments), which in reality is the
 * current site.
 *
 * @return object with current site information
 */
function wp_get_current_site() {
	return get_blog_details();
}

/**
 * Checks to see if there is more than one network defined in the site table
 *
 * @return bool
 */
function is_multi_network() {
	if ( ! is_multisite() )
		return false;

	global $wpdb;

	if ( false === ( $is_multi_network = get_transient( 'is_multi_network' ) ) ) {
		$rows = (array) $wpdb->get_col("SELECT DISTINCT id FROM $wpdb->site LIMIT 2");
		$is_multi_network = 1 < count( $rows ) ? 1 : 0;
		set_transient( 'is_multi_network', $is_multi_network );
	}

	return apply_filters( 'is_multi_network', (bool) $is_multi_network );
}

/**
 * Return an array of sites on the specified network. If no network is specified,
 * return all sites, regardless of network.
 *
 * @since 3.7.0
 *
 * @param array|string $args Optional. Specify the status of the sites to return.
 * @return array An array of site data
 */
function wp_get_sites( $args = array() ) {
	global $wpdb;

	if ( wp_is_large_network() )
		return;

	$defaults = array( 'network_id' => null );

	$args = wp_parse_args( $args, $defaults );

	$query = "SELECT * FROM $wpdb->blogs WHERE 1=1 ";

	if ( isset( $args['network_id'] ) && ( is_array( $args['network_id'] ) || is_numeric( $args['network_id'] ) ) ) {
		$network_ids = array_map('intval', (array) $args['network_id'] );
		$network_ids = implode( ',', $network_ids );
		$query .= "AND site_id IN ($network_ids) ";
	}

	if ( isset( $args['public'] ) )
		$query .= $wpdb->prepare( "AND public = %s ", $args['public'] );

	if ( isset( $args['archived'] ) )
		$query .= $wpdb->prepare( "AND archived = %s ", $args['archived'] );

	if ( isset( $args['mature'] ) )
		$query .= $wpdb->prepare( "AND mature = %s ", $args['mature'] );

	if ( isset( $args['spam'] ) )
		$query .= $wpdb->prepare( "AND spam = %s ", $args['spam'] );

	if ( isset( $args['deleted'] ) )
		$query .= $wpdb->prepare( "AND deleted = %s ", $args['deleted'] );

	$key = 'wp_get_sites:' . md5( $query );

	if ( ! $site_results = wp_cache_get( $key, 'site-id-cache' ) ) {
		$site_results = $wpdb->get_results( $query );
		wp_cache_set( $key, $site_results, 'site-id-cache' );
	}

	$sites = Array();

	foreach ( $site_results as $site ) {
		$sites[ $site->blog_id ] = $site;
	}

	return $sites;
}
