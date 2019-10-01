#!/bin/bash
set -e

sed -i "s|{{ APACHE_DOCUMENT_ROOT }}|${APACHE_DOCUMENT_ROOT}|" /etc/apache2/sites-enabled/*.conf

source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND
