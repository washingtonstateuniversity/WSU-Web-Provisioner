<?php  if ( ! defined( 'ABSPATH' ) ) exit;

if ( ! class_exists( 'Debug_Bar_Super_Globals' ) ) :

class Debug_Bar_Super_Globals extends Debug_Bar_Panel {
	public function init() {
		$this->title( __( 'Super Globals', 'debug-bar' ) );
	}

	public function prerender() {
		$this->set_visible( true );
	}

	public function render() {
?>
<div id="debug-bar-super-globals">
<h3>$_GET :</h3>
<p><pre><?php var_dump($_GET); ?></pre></p>
<h3>$_POST :</h3>
<p><pre><?php var_dump($_POST); ?></pre></p>
<h3>$_COOKIE :</h3>
<p><pre><?php var_dump($_COOKIE); ?></pre></p>
<h3>$_SERVER :</h3>
<p><pre><?php var_dump($_SERVER); ?></pre></p>
</div>
<?php
	}
}

endif;
