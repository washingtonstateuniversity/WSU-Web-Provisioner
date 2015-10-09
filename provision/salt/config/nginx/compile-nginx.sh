#!/bin/bash
#
# Compile Nginx with SPDY and Pagespeed support.
rm -fr /tmp/nginx-1.9.5
rm -fr /tmp/openssl-1.0.2d

# Compile against OpenSSL to enable NPN.
cd /tmp/
wget https://www.openssl.org/source/openssl-1.0.2d.tar.gz
tar -xzvf openssl-1.0.2d.tar.gz

# Get the Nginx source.
#
# Best to get the latest mainline release. Of course, your mileage may
# vary depending on future changes
cd /tmp/
wget http://nginx.org/download/nginx-1.9.5.tar.gz
tar zxf nginx-1.9.5.tar.gz
cd /tmp/nginx-1.9.5

./configure \
--user=www-data \
--group=www-data \
--prefix=/etc/nginx \
--sbin-path=/usr/sbin/nginx \
--conf-path=/etc/nginx/nginx.conf \
--pid-path=/var/run/nginx.pid \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--lock-path=/var/lock/subsys/nginx \
--http-client-body-temp-path=/var/cache/nginx/client_temp \
--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
--with-debug \
--with-file-aio \
--with-http_auth_request_module \
--with-http_addition_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_mp4_module \
--with-http_realip_module \
--with-http_v2_module \
--with-http_ssl_module \
--with-http_stub_status_module \
--with-http_sub_module \
--with-ipv6 \
--with-cc-opt='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2' \
--with-ld-opt='-Wl,-z,relro -Wl,--as-needed' \
--with-openssl=/tmp/openssl-1.0.2d

cd /tmp/nginx-1.9.5
make
make install