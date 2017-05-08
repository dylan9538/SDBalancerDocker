#!/bin/bash
set -e  

# if $proxy_domain is not set, then default to $HOSTNAME
export namePage=${namePage:-"No parameter asigned"}

# ensure the following environment variables are set. exit script and container if not set.
test $namePage

/usr/local/bin/confd -onetime -backend env

echo "Starting web server apache"
exec httpd -DFOREGROUND
