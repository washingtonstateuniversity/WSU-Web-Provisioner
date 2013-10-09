<?php
/*
Plugin Name: DEV WSU Environment Filters
Plugin URI: http://web.wsu.edu/
Description: Filters specific to the development environment in WSUWP.
Author: washingtonstateuniversity, jeremyfelt
Version: 0.1
*/

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