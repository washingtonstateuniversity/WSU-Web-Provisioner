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
 * Return a list of networks that the user is a member of.
 *
 * @uses wp_get_networks
 * @param null $user_id Optional. Defaults to the current user.
 *
 * @return array containing list of user's networks
 */
function wp_get_user_networks( $user_id = null ) {

	if ( ! $user_id )
		$user_id = get_current_user_id();

	$user_sites = wp_get_user_sites( $user_id );
	$user_network_ids = array_values( array_unique( wp_list_pluck( $user_sites, 'site_id' ) ) );

	return wp_get_networks( array( 'network_id' => $user_network_ids ) );
}

/**
 * A wrapper with a better name for get_current_site(). Returns what WordPress knows
 * as the current site, which in reality is the current network.
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
 * Switch to another network by backing up the $current_site global so that we can run
 * various queries and functions while impersonating it.
 *
 * The resulting $current_site global will need to include properties for:
 *     - id
 *     - domain
 *     - path
 *     - blog_id
 *     - site_name
 *     - cookie_domain (?)
 *
 * @param int $network_id Network ID to switch to.
 */
function switch_to_network( $network_id ) {
	if ( ! $network_id )
		return false;

	global $current_site, $wpdb;

	// Create a backup of $current_site in the global scope
	$GLOBALS['_wp_switched_network'] = $current_site;

	$new_network = wp_get_networks( array( 'network_id' => $network_id ) );
	$current_site = array_shift( $new_network );
	$current_site->blog_id = $wpdb->get_var( $wpdb->prepare( "SELECT blog_id FROM $wpdb->blogs WHERE domain = %s AND path = %s", $current_site->domain, $current_site->path ) );
	$current_site = get_current_site_name( $current_site );

	return true;
}

/**
 * Restore the network we are currently viewing to the $current_site global. If $current_site
 * already contains the current network, then there is no need to modify anything. If we do
 * restore from the _wp_switched_network global, then unset to require another use of
 * switch_to_network().
 */
function restore_current_network() {
	global $current_site;
	if ( isset( $GLOBALS['_wp_switched_network'] ) ) {
		$current_site = $GLOBALS['_wp_switched_network'];
		unset( $GLOBALS['_wp_switched_network'] );
	}
}

/**
 * Wrapper function for the WordPress switch_to_blog() intended to better match the
 * name of what we're doing in the backend vs the frontend
 *
 * @param int $site_id ID of the site to switch to
 *
 * @return bool True on success, false if the validation failed
 */
function switch_to_site( $site_id ) {
	return switch_to_blog( $site_id );
}

/**
 * Used after switch_to_site(), this is a wrapper for restore_current_blog() that gets
 * us back to the current site
 *
 * @return bool True on success, false if we're already on the current blog
 */
function restore_current_site() {
	return restore_current_blog();
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
 * Get an array of data on requested networks
 *
 * @param array $args Optional.
 *     - 'network_id' a single network ID or an array of network IDs
 *
 * @return array containing network data
 */
function wp_get_networks( $args = array() ) {
	if ( ! is_multisite() || ! is_multi_network() )
		return array();

	global $wpdb;

	$network_results = (array) $wpdb->get_results( "SELECT * FROM $wpdb->site" );

	if ( isset( $args['network_id'] ) ) {
		$network_id = (array) $args['network_id'];
		foreach( $network_results as $key => $network ) {
			if ( ! in_array( $network->id, $network_id ) ) {
				unset( $network_results[ $key ] );
			}
		}
	}

	return array_values( $network_results );
}

/**
 * Return an array of sites on the specified network. If no network is specified,
 * return all sites, regardless of network.
 *
 * @since 3.7.0
 *
 * @param array $args (optional) An array of arguments to modify the query {
 *     @type int|array 'network_id' A network ID or array of network IDs
 *     @type int       'limit'      Number of sites to limit the query to
 * }
 *
 * @return array An array of site data
 */
function wp_get_sites( $args = array() ) {
	global $wpdb;

	if ( wp_is_large_network() )
		return;

	$defaults = array(
		'network_id' => null,
		'limit'      => 100,
	);

	$args = wp_parse_args( $args, $defaults );

	$query = "SELECT * FROM $wpdb->blogs WHERE 1=1 ";

	if ( isset( $args['network_id'] ) && ( is_array( $args['network_id'] ) || is_numeric( $args['network_id'] ) ) ) {
		$network_ids = array_map('intval', (array) $args['network_id'] );
		$network_ids = implode( ',', $network_ids );
		$query .= "AND site_id IN ($network_ids) ";
	}

	if ( isset( $args['public'] ) )
		$query .= $wpdb->prepare( "AND public = %d ", $args['public'] );

	if ( isset( $args['archived'] ) )
		$query .= $wpdb->prepare( "AND archived = %d ", $args['archived'] );

	if ( isset( $args['mature'] ) )
		$query .= $wpdb->prepare( "AND mature = %d ", $args['mature'] );

	if ( isset( $args['spam'] ) )
		$query .= $wpdb->prepare( "AND spam = %d ", $args['spam'] );

	if ( isset( $args['deleted'] ) )
		$query .= $wpdb->prepare( "AND deleted = %d ", $args['deleted'] );

	if ( isset( $args['limit'] ) )
		$query .= $wpdb->prepare( "LIMIT %d ", $args['limit'] );

	$site_results = (array) $wpdb->get_results( $query );

	return $site_results;
}
