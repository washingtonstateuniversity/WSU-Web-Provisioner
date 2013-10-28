wsuwp-initial:
  cmd.run:
    - name: cd /var/tmp/; git clone https://github.com/washingtonstateuniversity/WSUWP-Platform.git wsuwp-platform-vcs; cd wsuwp-platform-vcs; git submodule init
    - unless: cd /var/tmp/wsuwp-platform-vcs
  require:
    - pkg: git

wsuwp-update:
  cmd.run:
    - name: cd /var/tmp/wsuwp-platform-vcs; git pull origin master; git submodule update

wsuwp-sync:
  cmd.run:
    - name: rsync -rvzh --delete --exclude='.git' /var/tmp/wsuwp-platform-vcs/ /var/www/wsuwp-platform