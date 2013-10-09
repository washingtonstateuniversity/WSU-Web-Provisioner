<?php
/*
Plugin Name: DEV WSU Log wp_mail()
Version: 0.1
Plugin URI: http://web.wsu.edu
Description: Log emails sent through WordPress to a text file.
Author: washingtonstateuniversity, jeremyfelt
*/

add_filter( 'wp_mail', 'wsu_log_wp_mail', 1 );
/**
 * Stores emails sent through WordPress to a log file in the content directory.
 *
 * @param array $args arguments passed to wp_mail()
 *
 * @return array arguments, unmodified
 */
function wsu_log_wp_mail( $args ) {

	// Only do this in a specific local environment.
	if ( defined( 'WSU_LOCAL_CONFIG' ) && true === WSU_LOCAL_CONFIG ) {
		$log_message = "---MESSAGE---\n" . var_export( array( date('r'), $args ), true );
		$fp = fopen( WP_CONTENT_DIR . '/log/wp-mail.log', 'a+' );
		fwrite( $fp, $log_message );
		fclose( $fp );
	}

	return $args;
}
