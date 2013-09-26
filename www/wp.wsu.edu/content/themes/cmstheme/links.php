<?php
/*
Template Name: Links
*/
?>

<?php 
include("setup.inc");
echo $before;
?>

<div id="content2" class="widecolumn">

<h2>Links:</h2>
<ul>
<?php wp_list_bookmarks(); ?>
</ul>

</div>

<?php 
echo $sidebar;
get_sidebar();
echo $after;
?>
