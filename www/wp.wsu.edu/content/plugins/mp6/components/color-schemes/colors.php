<?php

/***********************************************************************************

  This component is in an experimental stage and it's behavior
  might change in the future!

************************************************************************************/

// register additonal MP6 color schemes
add_action( 'admin_init' , 'mp6_colors_register_schemes', 7 );
function mp6_colors_register_schemes() {

	global $_wp_admin_css_colors;

	// Blue
	wp_admin_css_color(
		'blue',
		'Blue',
		plugins_url( 'schemes/blue/colors.css', __FILE__ ),
		array( '#096484', '#4796b3', '#52accc', '#e5f8ff' )
	);
	$_wp_admin_css_colors[ 'blue' ]->icon_colors = array( 'base' => '#e5f8ff', 'focus' => '#fff', 'current' => '#fff' );

	// Seaweed
	wp_admin_css_color(
		'seaweed',
		'Seaweed',
		plugins_url( 'schemes/seaweed/colors.css', __FILE__ ),
		array( '#15757a', '#a8c274', '#e78229', '#f1f3f3' )
	);
	$_wp_admin_css_colors[ 'seaweed' ]->icon_colors = array( 'base' => '#e1f9fa', 'focus' => '#fff', 'current' => '#fff' );

	// Pixel
	wp_admin_css_color(
		'pixel',
		'Pixel',
		plugins_url( 'schemes/pixel/colors.css', __FILE__ ),
		array( '#59524c', '#c7a589', '#9ea476', '#f1f3f3' )
	);
	$_wp_admin_css_colors[ 'pixel' ]->icon_colors = array( 'base' => '#f3f2f1', 'focus' => '#fff', 'current' => '#fff' );

	// Ghostbusters
	wp_admin_css_color(
		'ectoplasm',
		'Ectoplasm',
		plugins_url( 'schemes/ectoplasm/colors.css', __FILE__ ),
		array( '#523f6d', '#a3b745', '#d46f15', '#f2f1f3' )
	);
	$_wp_admin_css_colors[ 'ectoplasm' ]->icon_colors = array( 'base' => '#ece6f6', 'focus' => '#fff', 'current' => '#fff' );

/*
	// MP6 Light
	wp_admin_css_color(
		'mp6-light',
		'MP6 Light',
		plugins_url( 'schemes/mp6-light/colors.css', __FILE__ ),
		array( '#0076a2', '#444', '#666', '#ddd' )
	);
	$_wp_admin_css_colors[ 'mp6-light' ]->icon_colors = array( 'base' => '#666', 'focus' => '#fff', 'current' => '#fff' );

	// Malibu Dreamhouse
	wp_admin_css_color(
		'malibu-dreamhouse',
		'Malibu Dreamhouse',
		plugins_url( 'schemes/malibu-dreamhouse/colors.css', __FILE__ ),
		array( '#b476aa', '#c18db8', '#e5cfe1', '#70c0aa' )
	);
	$_wp_admin_css_colors[ 'malibu-dreamhouse' ]->icon_colors = array( 'base' => '#f0e1ed', 'focus' => '#fff', 'current' => '#fff' );

	// 80's Kid
	wp_admin_css_color(
		'80s-kid',
		'80\'s Kid',
		plugins_url( 'schemes/80s-kid/colors.css', __FILE__ ),
		array( '#0c4da1', '#ed5793', '#43db2a', '#f1f2f3' )
	);
	$_wp_admin_css_colors[ '80s-kid' ]->icon_colors = array( 'base' => '#ebf0f6', 'focus' => '#fff', 'current' => '#fff' );

	// Lioness
	wp_admin_css_color(
		'lioness',
		'Lioness',
		plugins_url( 'schemes/lioness/colors.css', __FILE__ ),
		array( '#78231d', '#bfa013', '#906c4d', '#f3f1f1' )
	);
	$_wp_admin_css_colors[ 'lioness' ]->icon_colors = array( 'base' => '#f5f2e2', 'focus' => '#fff', 'current' => '#fff' );
*/

}

// make sure `colors-mp6.css` gets enqueued
add_action( 'admin_init', 'mp6_colors_load_mp6_default_css', 20 );
function mp6_colors_load_mp6_default_css() {

	global $wp_styles, $_wp_admin_css_colors;

	$color_scheme = get_user_option( 'admin_color' );

	if ( $color_scheme == 'mp6' )
		return;

	// add `colors-mp6.css` and make it a dependency of the current color scheme
	$modtime = filemtime( realpath( dirname( __FILE__ ) . '/../../css/' . basename( $_wp_admin_css_colors[ 'mp6' ]->url ) ) );
	$wp_styles->add( 'colors-mp6', $_wp_admin_css_colors[ 'mp6' ]->url, false, $modtime );
	$wp_styles->registered[ 'colors' ]->deps[] = 'colors-mp6';

	// remove incorrect modification time
	$wp_styles->registered[ 'colors' ]->ver = false;

}

// turn `color_scheme->icon_colors` into `mp6_color_scheme` javascript variable
add_action( 'admin_head', 'mp6_colors_set_script_colors' );
function mp6_colors_set_script_colors() {

	global $_wp_admin_css_colors;

	$color_scheme = get_user_option( 'admin_color' );

	if ( isset( $_wp_admin_css_colors[ $color_scheme ]->icon_colors ) ) {
		echo '<script type="text/javascript">var mp6_color_scheme = ' . json_encode( array( 'icons' => $_wp_admin_css_colors[ $color_scheme ]->icon_colors ) ) . ";</script>\n";
	}

}

// enqueue new color scheme picker (on profile/edit-user screen)
add_action( 'admin_enqueue_scripts', 'mp6_colors_enqueue_picker' );
function mp6_colors_enqueue_picker() {
	if ( ! in_array( get_current_screen()->base, array( 'profile', 'user-edit', 'profile-network', 'user-edit-network' ) ) )
		return;

	wp_enqueue_style( 'mp6-color-scheme-picker', plugins_url( 'picker/style.css', __FILE__ ) );
	wp_enqueue_script( 'mp6-color-scheme-picker', plugins_url( 'picker/scripts.js', __FILE__ ), array( 'user-profile' ) );
}

// replace default color scheme picker
remove_action( 'admin_color_scheme_picker', 'admin_color_scheme_picker' );
add_action( 'admin_color_scheme_picker', 'mp6_colors_scheme_picker' );
function mp6_colors_scheme_picker() {
	global $_wp_admin_css_colors, $user_id;
?>

	<fieldset id="color-picker">
		<legend class="screen-reader-text"><span><?php _e( 'Admin Color Scheme' ); ?></span></legend>

<?php
	$current_color = get_user_option( 'admin_color', $user_id );

	if ( empty( $current_color ) )
		$current_color = 'mp6';

	$color_info = $_wp_admin_css_colors[$current_color];
?>

		<div class="dropdown dropdown-current">
			<div class="picker-dropdown"></div>
			<label for="admin_color_<?php echo esc_attr( $current_color ); ?>"><?php echo esc_html( $color_info->name ); ?></label>
			<table class="color-palette">
				<tr>
				<?php foreach ( $color_info->colors as $html_color ): ?>
					<td style="background-color: <?php echo esc_attr( $html_color ); ?>" title="<?php echo esc_attr( $current_color ); ?>">&nbsp;</td>
				<?php endforeach; ?>
				</tr>
			</table>
		</div>

		<div class="dropdown dropdown-container">

		<?php foreach ( $_wp_admin_css_colors as $color => $color_info ) : ?>

			<div class="color-option <?php echo ( $color == $current_color ) ? 'selected' : ''; ?>">
				<input name="admin_color" id="admin_color_<?php echo esc_attr( $color ); ?>" type="radio" value="<?php echo esc_attr( $color ); ?>" class="tog" <?php checked( $color, $current_color ); ?> />
				<input type="hidden" class="css_url" value="<?php echo esc_attr( $color_info->url ); ?>" />
				<input type="hidden" class="icon_colors" value="<?php echo esc_attr( json_encode( array( 'icons' => $color_info->icon_colors ) ) ); ?>" />
				<label for="admin_color_<?php echo esc_attr( $color ); ?>"><?php echo esc_html( $color_info->name ); ?></label>
				<table class="color-palette">
					<tr>
					<?php foreach ( $color_info->colors as $html_color ): ?>
						<td style="background-color: <?php echo esc_attr( $html_color ); ?>" title="<?php echo esc_attr( $color ); ?>">&nbsp;</td>
					<?php endforeach; ?>
					</tr>
				</table>
			</div>

		<?php endforeach; ?>

		</div>

	</fieldset>

<?php
}
