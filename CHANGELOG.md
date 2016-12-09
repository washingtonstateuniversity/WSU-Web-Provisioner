# WSU Web Provisioner CHANGELOG

## 1.11.4 (TBD)

* Elasticsearch: Update local YUM config for ES 2.x.
* Java: Update JDK8u101 on WSUSEARCH.
* Nginx: Update Nginx to 1.11.5.
* Nginx: Always add certain headers, even when an error response.
* Nginx: Force a trailing slash on wp-admin URLs
* Nginx: Avoid logging missing favicon requests
* Nginx: Adjust rate limit config to match production value
* Nginx: Allow 200M uploads via main nginx configuration
* Nginx: Remove deprecated log formats, now unused.
* Nginx: Avoid unnecessary logs on the default-wsuwp nginx fallback
* Nginx: Remove unneeded with-ipv6 config for nginx build
* Nginx: Use the same post_max_size config for php-fpm and nginx
* OpenSSL: Compile Nginx with 1.0.2j.
* PHP: Set the default max PHP memory usage to 256M
* Salt: Update Salt Bootstrap 2016.10.25
* WSUSEARCH no longer requires MySQL

### Deployments

* uc-proxy1: November 14, 2016 (reboot)
* wsusearch-prod-01: November 14, 2016 (reboot)
* wsuwp-indie-prod-01: November 17, 2016 (reboot)
* wsuwp-prod-01:
* wsuwp-prod-02: November 14, 2016 (reboot)
* wsu-lists: November 17, 2016 (reboot)

## 1.11.3 (October 2, 2016)

_Changes through October 2 were deployed to all servers but wsu-lists on this day, but no official release was tagged._

## 1.11.2 (July 30, 2016)

* MySQL: Add `innodb_buffer_pool_instances` to configuration.
* Nginx: Update Nginx 1.11.3
* Nginx: Add mitigation for httpoxy vulnerability.
* Nginx: Start tracking fastcgi_params.
* Nginx: Add `REQUEST_SCHEME` to fastcgi_params.
* PHP List: Provision config to `config-custom.php` to avoid overwriting.
* Provision: Upgrade uc-proxy1 to a WSUWP dev box.
* WP-CLI: Always update WP-CLI to nightly.

### Deployments

* uc-proxy1: July 28, 2016
* wsusearch-prod-01: July 27, 2016
* wsuwp-indie-prod-01: July 27, 2016
* wsuwp-prod-01: July 30, 2016
* wsuwp-prod-02: July 27, 2016
* wsu-lists: July 29, 2016

## 1.11.1 (June 13, 2016)

* Nginx: Update Nginx 1.11.1
* Nginx: Create `/etc/nginx/ssl` directory before attempting to add files.
* ImageMagick: Update security policy.
* Spine: Provide a local development environment for the WSU Spine.

### Deployments

* uc-proxy1: June 13, 2016
* wsusearch-prod-01: June 13, 2016
* wsuwp-indie-prod-01: June 13, 2016
* wsuwp-prod-01: June 13, 2016
* wsuwp-prod-02: June 13, 2016
* wsu-lists: June 13, 2016

## 1.11.0 (May 3, 2016)

* Start tracking a CHANGELOG.
* Fail2ban: Allow maximum of 5 retries over 3 hours, not 6
* Fail2ban: Jail banned IPs for 48 hours, not 24
* HTTPS: Update allowed cipher list, SSL session cache timing
* HTTPS: Provide a default response for invalid HTTPS requests
* HTTPS: Generate a self signed cert for invalid HTTPS requests (#243)
* HTTPS: Document why ssl_session_tickets are disabled in our nginx config
* HTTPS: Document why ssl_session_timeout is set at 1 day
* ImageMagick: Provide an ImageMagick security policy configuration
* Logrotate: Add initial lograte configurations (#252)
* MySQL: Disable log_queries_not_using_indexes (#253)
* MySQL: Grant ALL privileges to the wsuwp DB user (#261)
* Nginx: Update Nginx 1.9.15
* Nginx: Block direct access to `xmlrpc.php`
* Nginx: Make sure the content type header is sent with the 404
* Nginx: Provide a WordPress specific default site (#254)
* Nginx: Add a request limiting configuration to Nginx (#250)
* Ntp: Make sure latest ntpd is installed (#256)
* OpenSSL: Update OpenSSL built with Nginx to 1.0.2h
* Provision: Remove all previous nginx and openssl directories
* Salt: Update Salt Bootstrap script to 2016.04.18 (#251)
* SeLinux: Start tracking an selinux config file

### Deployments

* uc-proxy1: May 3, 2016 (reboot)
* wsusearch-prod-01: May 3, 2016 (reboot)
* wsuwp-indie-prod-01: May 3, 2016
* wsuwp-prod-01: May 3, 2016
* wsuwp-prod-02: May 3, 2016 (reboot)
* wsu-lists: May 3, 2016 (reboot)
