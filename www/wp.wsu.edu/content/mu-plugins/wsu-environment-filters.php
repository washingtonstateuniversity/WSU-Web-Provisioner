<?php
/*
Plugin Name: WSU Environment Filters
Plugin URI: http://web.wsu.edu/
Description: Filters specific to the server environment at WSU.
Author: washingtonstateuniversity, jeremyfelt
Version: 0.1
*/

/**
 * Remove `index.php` from permalinks when using Nginx
 *
 * If `index.php` is showing up as a level within your permalinks when running
 * WordPress on Nginx, it can be removed by hooking into 'got_rewrite' and
 * explicitly forcing WordPress to believe that rewrite is available.
 *
 */
add_filter( 'got_rewrite', '__return_true', 999 );

// Avoid generating .htaccess files whenever rewrite rules are flushed
add_filter( 'flush_rewrite_rules_hard', '__return_false');

/**
 * Alter the timeout on cron requests from 0.01 to 0.5. Something about
 * the Vagrant and/or Ubuntu setup doesn't like these self requests
 * happening so quickly.
 */
//add_filter( 'cron_request', 'vvv_cron_request', 10, 1 );
function vvv_cron_request( $cron_request ) {
	$cron_request['args']['timeout'] = (float) 0.5;
	return $cron_request;
}