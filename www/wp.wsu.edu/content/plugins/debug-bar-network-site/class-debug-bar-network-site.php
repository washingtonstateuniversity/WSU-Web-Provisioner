<?php

class Debug_Bar_Network_Site extends Debug_Bar_Panel {

	public function init() {
		$this->title( 'Network and Site' );
	}

	public function prerender() {
		$this->set_visible( true );
	}

	public function render() {
		global $current_site, $current_blog, $blog_id, $site_id;
		?>
		<div id="debug-bar-network-site">
			<h3>Current Network Id : <?php echo $site_id; ?></h3>
			<p><pre><?php var_dump( $current_site ); ?></pre></p>
			<h3>Current Site Id: <?php echo $blog_id; ?></h3>
			<p><pre><?php var_dump( $current_blog ); ?></pre></p>
		</div>
	<?php
	}
}
