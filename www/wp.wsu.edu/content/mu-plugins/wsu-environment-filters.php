<?php
/**
 * Filters specific to the environment provided by WSUWP
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
