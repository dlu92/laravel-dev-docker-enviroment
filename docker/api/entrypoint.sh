#!/bin/bash
set -e

sudo chown -R www-data:www-data /var/www

exec "$@"