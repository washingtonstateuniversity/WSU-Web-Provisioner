<?php 
include("setup.inc");
echo $before;
?>

	<div id="content2" class="narrowcolumn">

		<?php if (have_posts()) : ?>

 	  <?php $post = $posts[0]; // Hack. Set $post so that the_date() works. ?>
 	  <?php /* If this is a category archive */ if (is_category()) { ?>
		<h1 class="pagetitle" style="padding-bottom:10px;">Category: <?php single_cat_title(); ?></h1>
 	  <?php /* If this is a tag archive */ } elseif( is_tag() ) { ?>
		<h1 class="pagetitle" style="padding-bottom:10px;">Posts Tagged '<?php single_tag_title(); ?>'</h1>
 	  <?php /* If this is a daily archive */ } elseif (is_day()) { ?>
		<h1 class="pagetitle" style="padding-bottom:10px;">Archive for <?php the_time('F j, Y'); ?></h1>
 	  <?php /* If this is a monthly archive */ } elseif (is_month()) { ?>
		<h1 class="pagetitle" style="padding-bottom:10px;">Archive for <?php the_time('F Y'); ?></h1>
 	  <?php /* If this is a yearly archive */ } elseif (is_year()) { ?>
		<h1 class="pagetitle" style="padding-bottom:10px;">Archive for <?php the_time('Y'); ?></h1>
	  <?php /* If this is an author archive */ } elseif (is_author()) { ?>
		<h1 class="pagetitle" style="padding-bottom:10px;">Author Archive</h1>
 	  <?php /* If this is a paged archive */ } elseif (isset($_GET['paged']) && !empty($_GET['paged'])) { ?>
		<h1 class="pagetitle" style="padding-bottom:10px;">Blog Archives</h1>
 	  <?php } ?>


		<!--	<div class="navigation">
		<div class="alignleft"><?php previous_posts_link('&laquo; Newer Entries') ?></div>
			<div class="alignright"><?php next_posts_link('Older Entries &raquo;') ?></div> 
		</div>  -->

		<?php while (have_posts()) : the_post(); ?>
		<div class="post" style="padding:15px 0px 10px 0px; border-bottom:1px solid #b6bcbf;" >
				<h4 id="post-<?php the_ID(); ?>"><a href="<?php the_permalink() ?>" rel="bookmark" title="Permanent Link to <?php the_title_attribute(); ?>"><?php the_title(); ?></a></h4>
				<small><?php the_time('l, F j, Y') ?></small>

				<div class="entry" style="padding-top:15px;">
					<?php the_content('<small>&nbsp;Continue story&nbsp;&rarr;</small>'); ?>
				</div>

<p class="postmetadata">
          <?php comments_popup_link('<small><img src="http://cas.wsu.edu/about/images/comment.gif" alt="Add Comment" align="absbottom" /> <b>(0)</b></small>', '<small><img src="http://cas.wsu.edu/about/images/comment.gif" alt="Add Comment" align="absbottom" /> <b>(1)</b></small>', '<small><img src="http://cas.wsu.edu/about/images/comment.gif" alt="Add Comment" align="absbottom" /> (%)</small>'); ?><small> &nbsp;|&nbsp; Filed in <?php the_category(', ') ?>.<br/><?php the_tags('Tagged as ', ', ', '.&nbsp;'); ?><?php edit_post_link('Edit', '', ''); ?></small>  </p>

			</div>

		<?php endwhile; ?>

		<div class="navigation" style="padding-top:10px;">
				<div class="alignleft"><?php previous_posts_link('&laquo; Newer Entries') ?></div>
			<div class="alignright"><?php next_posts_link('Older Entries &raquo;') ?></div>
		</div>

	<?php else : ?>

		<h2 class="center">Not Found</h2>
		<?php include (TEMPLATEPATH . '/searchform.php'); ?>

	<?php endif; ?>
	</div>
<?php 
echo $sidebar;
get_sidebar();
echo $after;
?>