#!/bin/bash
#
# Clone the latest version of the Spine parent theme if it does not exist.

if [[ ! -d /var/www/wp-content/themes/spine ]]; then
	cd /var/www/wp-content/themes/
	git clone https://github.com/washingtonstateuniversity/WSUWP-spine-parent-theme.git spine
fi
