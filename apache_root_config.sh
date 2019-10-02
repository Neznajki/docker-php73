#!/bin/bash
set -e

sed -i "s|{{ APACHE_DOCUMENT_ROOT }}|${APACHE_DOCUMENT_ROOT}|" /etc/apache2/sites-enabled/*.conf

sudo bash -c "source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND"
