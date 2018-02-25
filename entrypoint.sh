#!/bin/sh

mysql_install_db --user=mysql > /dev/null

exec "$@"
