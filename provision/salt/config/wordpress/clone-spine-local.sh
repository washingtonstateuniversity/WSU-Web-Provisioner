#!/bin/bash
#
# Clone the latest version of the Spine if it does not exist.

if [[ ! -d /var/www/wsu-spine ]]; then
	cd /var/www/
	git clone https://github.com/washingtonstateuniversity/wsu-spine.git wsu-spine
fi
