<?php 
include("setup.inc");

echo $before;
?>

	<div id="content2" class="narrowcolumn">
    
	<?php if (have_posts()) : ?>

		<?php while (have_posts()) : the_post(); ?>

			<div class="post" style="padding:15px 0px 10px 0px; border-bottom:1px solid #b6bcbf;" id="post-<?php the_ID(); ?>">
         
				<h4><a href="<?php the_permalink() ?>" rel="bookmark" title="Permanent Link to <?php the_title_attribute(); ?>"><?php the_title(); ?></a></h4>
				<small><?php the_time('l, F j, Y') ?> <!-- by <?php the_author() ?> --></small>

				<div class="entry" style="padding-top:15px;">
					<?php the_content('<small>&nbsp;Continue story&nbsp;&rarr;</small>'); ?>
				</div>

				<p class="postmetadata">
          <?php comments_popup_link('<small><img src="http://cas.wsu.edu/about/images/comment.gif" alt="Add Comment" align="absbottom" /> <b>(0)</b></small>', '<small><img src="http://cas.wsu.edu/about/images/comment.gif" alt="Add Comment" align="absbottom" /> <b>(1)</b></small>', '<small><img src="http://cas.wsu.edu/about/images/comment.gif" alt="Add Comment" align="absbottom" /> (%)</small>'); ?><small> &nbsp;|&nbsp; Filed in <?php the_category(', ') ?>.<br/><?php the_tags('Tagged as ', ', ', '.&nbsp;'); ?><?php edit_post_link('Edit', '', ''); ?></small>  </p>
        
			</div>
		<?php endwhile; ?>

		<div class="navigation" style="padding-top:10px;">			
			<div class="alignleft">
      <?php previous_posts_link('&laquo; Newer Entries') ?></div>
      <div class="alignright">
        <?php next_posts_link('Older Entries &raquo;') ?></div>
		</div>

	<?php else : ?>

		<h2 class="center">Not Found</h2>
		<p class="center">Sorry, but you are looking for something that isn't here.</p>
		<?php include (TEMPLATEPATH . "/searchform.php"); ?>

	<?php endif; ?>

	</div>

<?php
echo $sidebar;
get_sidebar();
echo $after;
?>