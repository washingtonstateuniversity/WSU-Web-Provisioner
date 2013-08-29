<?php
/**
 * Functions that perform some core functionality that we would love to live inside
 * of WordPress one day.
 */

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
