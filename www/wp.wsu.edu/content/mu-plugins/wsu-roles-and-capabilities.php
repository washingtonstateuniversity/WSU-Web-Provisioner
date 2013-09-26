<?php

class WSU_Roles_And_Capabilities {
	/**
	 * Maintain the single instance of WSU_Roles_And_Capabilities
	 *
	 * @var bool|WSU_Roles_And_Capabilities
	 */
	private static $instance = false;

	/**
	 * Add the filters and actions used
	 */
	private function __construct() {
		add_action( 'init',           array( $this, 'modify_editor_capabilities' ), 10    );
		add_filter( 'editable_roles', array( $this, 'editable_roles'             ), 10, 1 );
		add_filter( 'map_meta_cap',   array( $this, 'map_meta_cap'               ), 10, 4 );
	}

	/**
	 * Handle requests for the instance.
	 *
	 * @return bool|WSU_Roles_And_Capabilities
	 */
	public static function get_instance() {
		if ( ! self::$instance )
			self::$instance = new WSU_Roles_And_Capabilities();
		return self::$instance;
	}

	function modify_editor_capabilities() {
		$editor = get_role( 'editor' );
		$editor->add_cap( 'create_users' );
		$editor->add_cap( 'promote_users' );
	}

	function editable_roles( $roles ) {
		if ( isset( $roles['administrator'] ) && ! current_user_can( 'administrator' ) )
			unset( $roles['administrator'] );

		return $roles;
	}

	function map_meta_cap( $caps, $cap, $user_id, $args ) {
		switch( $cap ){
			case 'edit_user':
			case 'remove_user':
			case 'promote_user':
				if( isset( $args[0] ) && $args[0] == $user_id )
					break;
				elseif( ! isset( $args[0] ) )
					$caps[] = 'do_not_allow';
				$other = new WP_User( absint( $args[0] ) );
				if( $other->has_cap( 'administrator' ) ){
					if( ! current_user_can( 'administrator' ) ) {
						$caps[] = 'do_not_allow';
					}
				}
				break;
			case 'delete_user':
			case 'delete_users':
				if( ! isset( $args[0] ) )
					break;
				$other = new WP_User( absint( $args[0] ) );
				if( $other->has_cap( 'administrator' ) ){
					if( ! current_user_can( 'administrator' ) ) {
						$caps[] = 'do_not_allow';
					}
				}
				break;
			default:
				break;
		}
		return $caps;
	}

}
WSU_Roles_And_Capabilities::get_instance();
