wsuwp-initial:
  cmd.run:
    - name: cd /var/local/; git clone https://github.com/washingtonstateuniversity/WSUWP-Platform.git wsuwp-platform-vcs; cd wsuwp-platform-vcs; git submodule init
    - unless: cd /var/local/wsuwp-platform-vcs
  require:
    - pkg: git

wsuwp-update:
  cmd.run:
    - name: cd /var/local/wsuwp-platform-vcs; git pull origin master; git submodule update

wsuwp-sync:
  cmd.run:
    - name: rsync -rvzh --delete --exclude='.git' /var/local/wsuwp-platform-vcs/ /var/www/wsuwp-platform; chown -R www-data:www-data /var/www/wsuwp-platform