<?php 
include("setup.inc");
echo $before;
?>

	<div id="content2" class="narrowcolumn">

	<?php if (have_posts()) : ?>

		<h1 class="pagetitle" style="padding-bottom:15px;">Search Results</h1>

	<div class="navigation">
			<!-- <div class="alignleft"><?php previous_posts_link('&laquo; Newer Entries') ?></div>
			<div class="alignright"><?php next_posts_link('Older Entries &raquo;') ?></div> -->

		</div>


		<?php while (have_posts()) : the_post(); ?>

			<div class="post" style="border-bottom:1px solid #b6bcbf; padding-top:10px;">
				<h5 id="post-<?php the_ID(); ?>"><a href="<?php the_permalink() ?>" rel="bookmark" title="Permanent Link to <?php the_title_attribute(); ?>"><?php the_title(); ?></a></h5>
				<small><?php the_time('l, F j, Y') ?></small>

				<p class="postmetadata" style="padding-top:3px;">
          <?php comments_popup_link('<small><img src="http://cas.wsu.edu/about/images/comment.gif" alt="Comments" align="absbottom" /> <b>(0)</b></small>', '<small><img src="http://cas.wsu.edu/about/images/comment.gif" alt="Comments" align="absbottom" /> <b>(1)</b></small>', '<small><img src="http://cas.wsu.edu/about/images/comment.gif" alt="Comments" align="absbottom" /> (%)</small>'); ?><small> &nbsp;|&nbsp; Filed in <?php the_category(', ') ?>.<br/><?php the_tags('Tagged as ', ', ', '.&nbsp;'); ?><?php edit_post_link('Edit', '', ''); ?></small>  </p>
			</div>

		<?php endwhile; ?>

		<div class="navigation" style="padding-top:10px;">
			<div class="alignleft"><?php previous_posts_link('&laquo; Newer Entries') ?></div>
			<div class="alignright"><?php next_posts_link('Older Entries &raquo;') ?></div>
		</div>

	<?php else : ?>

		<h2 class="center">No posts found. Try a different search?</h2>
		<?php include (TEMPLATEPATH . '/searchform.php'); ?>

	<?php endif; ?>

	</div>

<?php 
echo $sidebar;
get_sidebar();
echo $after;
?>