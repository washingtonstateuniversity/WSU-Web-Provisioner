	
<div id="sidebar">
    
    
    <script type="text/javascript" src="http://s7.addthis.com/js/250/addthis_widget.js#username=mcwsu"></script>
<style type="text/css">
  #secondary h2 {font-size: 1.5em; line-height: 1.4em;}
  #content #secondary .widget {padding-top: 15px;}
  #content #secondary ul{margin-left: 0px; margin-right: 0px; list-style:none;}
  #content #secondary li{padding-left: 0px;margin-left:0px;}
  #content #secondary  ul ul{padding-left: 0px;margin-left:0px; list-style:none;}
  #content #secondary #categories-3 li{padding-left: 0px;margin-left:0px;text-align:left;}
</style>
<script type="text/javascript">
	var addthis_config = {
          services_compact: 'email, facebook, twitter, myspace, google, more',
          services_exclude: 'print',
		  ui_click: true 
}
</script>
	<div style="float:left;padding-right:20px;">
		<h2><a href="<?php bloginfo('rss2_url'); ?>"><img src="http://images.wsu.edu/index-images/rss.png" alt="RSS" style="padding-left:10px; padding-right:5px;" /></a>Subscribe</h2>
	</div>	
<!--<div>	
		<a style="float:left; padding-right:5px;" href="http://addthis.com/bookmark.php?v=250&amp;username=mcwsu" class="addthis_button_compact"></a> Share  
	</div>-->
    <!--FOR FEEDBURNER, put this url in above href http://feeds2.feedburner.com/wsu/EducationBlog/ -->
           <br /> <ul>
			<?php 	/* Widgetized sidebar, if you have the plugin installed. */
					if ( !function_exists('dynamic_sidebar') || !dynamic_sidebar() ) : 
            ?>
            </ul>

				<?php include (TEMPLATEPATH . '/searchform.php'); ?>

<br/><br/>
			<!-- Author information is disabled per default. Uncomment and fill in your details if you want to use it.
			<h3>Author</h3>
			<p>A little something about you, the author. Nothing lengthy, just an overview.</p>-->

			

			<?php if ( is_404() || is_category() || is_day() || is_month() ||
						is_year() || is_search() || is_paged() ) {
			?> 

			<?php /* If this is a 404 page */ if (is_404()) { ?>
			<?php /* If this is a category archive */ } elseif (is_category()) { ?>
			<p>You are currently browsing the archives for the <?php single_cat_title(''); ?> category.</p>

			<?php /* If this is a yearly archive */ } elseif (is_day()) { ?>
			<p>You are currently browsing the <a href="<?php bloginfo('url'); ?>/"><?php echo bloginfo('name'); ?></a> blog archives
			for the day <?php the_time('l, F jS, Y'); ?>.</p>

			<?php /* If this is a monthly archive */ } elseif (is_month()) { ?>
			<p>You are currently browsing the <a href="<?php bloginfo('url'); ?>/"><?php echo bloginfo('name'); ?></a> blog archives
			for <?php the_time('F, Y'); ?>.</p>

			<?php /* If this is a yearly archive */ } elseif (is_year()) { ?>
			<p>You are currently browsing the <a href="<?php bloginfo('url'); ?>/"><?php echo bloginfo('name'); ?></a> blog archives
			for the year <?php the_time('Y'); ?>.</p>

			<?php /* If this is a monthly archive */ } elseif (is_search()) { ?>
			<p>You have searched the <a href="<?php echo bloginfo('url'); ?>/"><?php echo bloginfo('name'); ?></a> blog archives
			for <strong>'<?php the_search_query(); ?>'</strong>. If you are unable to find anything in these search results, you can try one of these links.</p>

			<?php /* If this is a monthly archive */ } elseif (isset($_GET['paged']) && !empty($_GET['paged'])) { ?>
			<p>You are currently browsing the <a href="<?php echo bloginfo('url'); ?>/"><?php echo bloginfo('name'); ?></a> blog archives.</p>

			<?php } ?>

			<?php }?>
<br/><br/>
			<?php wp_list_pages('title_li=<h3>Pages</h3>' ); ?>

			<br />
			<br />
			<br/>
			<h3>Archives</h3>
				<ul>
				<?php wp_get_archives('type=monthly'); ?>
				</ul>


			<?php wp_list_categories('show_count=1&title_li=<h3>Categories</h3>'); ?>

			<?php /* If this is the frontpage */ if ( is_home() || is_page() ) { ?>
				<?php //wp_list_bookmarks(); ?>

				<h3>Meta</h3>
				<ul>
					<?php //wp_register(); ?>
					<li><?php wp_loginout(); ?></li>
					<?php wp_meta(); ?>
				

			<?php } ?>

			<?php endif; ?>
</ul>
	</div>

