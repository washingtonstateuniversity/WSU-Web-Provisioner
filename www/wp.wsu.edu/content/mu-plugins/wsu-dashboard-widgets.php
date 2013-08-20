<?php

add_action( 'wp_dashboard_setup', 'wsu_remove_dashboard_widgets' );
function wsu_remove_dashboard_widgets() {
	remove_meta_box( 'dashboard_recent_comments', 'dashboard', 'normal' );
	remove_meta_box( 'dashboard_incoming_links' , 'dashboard', 'normal' );
	remove_meta_box( 'dashboard_primary'        , 'dashboard', 'side'   );
	remove_meta_box( 'dashboard_secondary'      , 'dashboard', 'side'   );
	remove_meta_box( 'dashboard_quick_press'    , 'dashboard', 'side'   );
	remove_meta_box( 'dashboard_recent_drafts'  , 'dashboard', 'side'   );
}

add_action( 'wp_network_dashboard_setup', 'wsu_remove_network_dashboard_widgets' );
function wsu_remove_network_dashboard_widgets() {
	remove_meta_box( 'network_dashboard_right_now', 'dashboard-network', 'normal' );
	remove_meta_box( 'dashboard_plugins'          , 'dashboard-network', 'normal' );
	remove_meta_box( 'dashboard_primary'          , 'dashboard-network', 'side'   );
	remove_meta_box( 'dashboard_secondary'        , 'dashboard-network', 'side'   );
}