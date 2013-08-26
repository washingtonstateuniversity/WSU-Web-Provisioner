<?php

add_action( 'admin_bar_menu', 'wsu_admin_bar_my_networks_menu', 210 );

/**
 * @param WP_Admin_Bar $wp_admin_bar
 */
function wsu_admin_bar_my_networks_menu( $wp_admin_bar ) {
	/**
	 * The 'My Networks' menu goes to the right of the admin bar as it is most
	 * likely a low frequency visit for those who are members of multiple networks.
	 */
	$wp_admin_bar->add_menu( array(
		'id'    => 'my-networks',
		'parent' => 'top-secondary',
		'title' => apply_filters( 'wsu_my_networks_title', 'My WSU Networks' ),
		'href'  => admin_url( 'index.php?page=my-wsu-networks' ),
	) );

	// add sub menu items to the My Networks menu item

	// modify the default My Sites menu
	$current_network_name = 'CAHNRS';
	
	$wp_admin_bar->add_menu( array(
		'id'    => 'my-sites',
		'title' => apply_filters( 'wsu_my_sites_title', 'My ' . $current_network_name . ' Sites' ),
		'href'  => admin_url( 'my-sites.php' ),
	) );

	// Add site links
	$wp_admin_bar->add_group( array(
		'parent' => 'my-sites',
		'id'     => 'my-sites-list',
		'meta'   => array(
			'class' => is_super_admin() ? 'ab-sub-secondary' : '',
		),
	) );

	foreach ( (array) $wp_admin_bar->user->blogs as $blog ) {
		switch_to_blog( $blog->userblog_id );

		$blavatar = '<div class="blavatar"></div>';

		$blogname = empty( $blog->blogname ) ? $blog->domain : $blog->blogname;
		$menu_id  = 'blog-' . $blog->userblog_id;

		$wp_admin_bar->add_menu( array(
			'parent'    => 'my-sites-list',
			'id'        => $menu_id,
			'title'     => $blavatar . $blogname,
			'href'      => admin_url(),
		) );

		$wp_admin_bar->add_menu( array(
			'parent' => $menu_id,
			'id'     => $menu_id . '-d',
			'title'  => __( 'Dashboard' ),
			'href'   => admin_url(),
		) );

		if ( current_user_can( get_post_type_object( 'post' )->cap->create_posts ) ) {
			$wp_admin_bar->add_menu( array(
				'parent' => $menu_id,
				'id'     => $menu_id . '-n',
				'title'  => __( 'New Post' ),
				'href'   => admin_url( 'post-new.php' ),
			) );
		}

		if ( current_user_can( 'edit_posts' ) ) {
			$wp_admin_bar->add_menu( array(
				'parent' => $menu_id,
				'id'     => $menu_id . '-c',
				'title'  => __( 'Manage Comments' ),
				'href'   => admin_url( 'edit-comments.php' ),
			) );
		}

		$wp_admin_bar->add_menu( array(
			'parent' => $menu_id,
			'id'     => $menu_id . '-v',
			'title'  => __( 'Visit Site' ),
			'href'   => home_url( '/' ),
		) );

		restore_current_blog();
	}
}