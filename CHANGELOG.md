# WSU Web Provisioner CHANGELOG

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
