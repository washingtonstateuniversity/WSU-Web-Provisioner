<?php
/**
 * @package Hello_Dolly
 * @version 1.6
 */
/*
Plugin Name: WSU URL Handler
Description: Modifies URLs to maintain WordPress in a subdirectory with WordPress
Author: washingtonstateuniversity, jeremyfelt
Version: 0.1
Author URI: http://wsu.edu/
*/

add_filter( 'network_site_url', 'wsu_modify_network_site_url', 10, 3 );
function wsu_modify_network_site_url( $url ) {
	return str_replace( '/wp-admin/network/', '/wordpress/wp-admin/network/', $url );
}

add_filter( 'home_url', 'wsu_modify_home_url', 10, 4 );
function wsu_modify_home_url( $url ) {
	$allowed_schemes = array( 'http', 'https' );
	$url_parts = parse_url( $url );

	if ( isset( $url_parts['path'] ) && isset( $url_parts['scheme'] ) && in_array( $url_parts['scheme'], $allowed_schemes ) &&  '/wordpress' === substr( $url_parts['path'], 0, 10 ) ) {
		$url_parts['path'] = substr( $url_parts['path'], 10 );
		return $url_parts['scheme'] . '://' .  $url_parts['host'] . $url_parts['path'];
	}

	return $url;
}

add_filter( 'admin_url', 'wsu_modify_admin_url', 10, 3 );
function wsu_modify_admin_url( $url, $a, $b ) {
	return $url;
}

add_filter( 'site_url', 'wsu_modify_site_url', 10, 4 );
function wsu_modify_site_url( $url, $a, $b ) {
	return $url;
}

add_filter( 'includes_url', 'wsu_modify_includes_url', 10, 2 );
function wsu_modify_includes_url( $url, $a ) {
	return $url;
}

add_filter( 'content_url', 'wsu_modify_content_url', 10, 2 );
function wsu_modify_content_url( $url, $a ) {
	return $url;
}

add_filter( 'plugins_url', 'wsu_modify_plugins_url', 10, 3 );
function wsu_modify_plugins_url( $url, $a, $b ) {
	return $url;
}

add_filter( 'network_home_url', 'wsu_modify_network_home_url', 10, 3 );
function wsu_modify_network_home_url( $url, $a, $b ) {
	return $url;
}

add_filter( 'network_admin_url', 'wsu_modify_network_admin_url', 10, 2 );
function wsu_modify_network_admin_url( $url, $a ) {
	return $url;
}

add_filter( 'user_admin_url', 'wsu_modify_user_admin_url', 10, 2 );
function wsu_modify_user_admin_url( $url, $a ) {
	return $url;
}

add_filter( 'user_dashboard_url', 'wsu_modify_user_dashboard_url', 10, 4 );
function wsu_modify_user_dashboard_url( $url, $a, $b, $c ) {
	return $url;
}

add_filter( 'edit_profile_url', 'wsu_modify_edit_profile_url', 10, 3 );
function wsu_modify_edit_profile_url( $url, $a, $b ) {
	return $url;
}