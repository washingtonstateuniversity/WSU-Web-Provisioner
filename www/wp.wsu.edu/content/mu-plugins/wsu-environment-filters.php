<?php
/**
 * Filters specific to the environment provided by WSUWP
 */

// Avoid generating .htaccess files whenever rewrite rules are flushed
add_filter( 'flush_rewrite_rules_hard', '__return_false');
