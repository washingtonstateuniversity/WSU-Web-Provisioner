<?php

add_action( 'admin_bar_menu', 'wsu_admin_bar_my_networks_menu', 210 );

/**
 * @param WP_Admin_Bar $wp_admin_bar
 */
function wsu_admin_bar_my_networks_menu( $wp_admin_bar ) {

	/**
	 * Remove the default My Sites menu, as we will be grouping sites under networks
	 * in a custom menu.
	 */
	$wp_admin_bar->remove_menu( 'my-sites' );

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

	/**
	 * Now that we have a My Networks menu, we should generate a list of networks to output
	 * under that menu. The existing logic displays all blogs that the user is a member of.
	 * We'll need to alter this to show sites (networks) instead, and then list the blogs
	 * as sub menus of those.
	 */
	$wp_admin_bar->add_group( array(
		'parent' => 'my-networks',
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