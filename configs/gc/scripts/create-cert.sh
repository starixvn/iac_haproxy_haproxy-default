#!/bin/bash

set -e

echo "Starting create new certificate..."
if [ "$#" -lt 2 ]; then
    echo "Usage: ...  <domain> <email> [options]"
    exit
fi

DOMAIN=$1
DOMAIN2=$2
DOMAIN3=$3
DOMAIN4=$4
EMAIL=$5
OPTIONS=$6

docker run --rm \
  -v $PWD/letsencrypt:/etc/letsencrypt \
  -v $PWD/webroot:/webroot \
  certbot/certbot \
  certonly --webroot -w /webroot \
  -d $DOMAIN -d $DOMAIN2 -d $DOMAIN3 -d $DOMAIN4 \
  --email $EMAIL \
  --non-interactive \
  --agree-tos \
  $6

# Merge private key and full chain in one file and add them to haproxy certs folder
function cat-cert() {
  dir="./letsencrypt/live/$1"
  cat "$dir/privkey.pem" "$dir/fullchain.pem" > "./certs/$1.pem"
}

# Run merge certificate for the requested domain name
cat-cert $DOMAIN
cp -R /var/www/ssl/certs /var/www/haproxy/
docker kill --signal USR2 $(docker container ls --filter name=haproxy_service --quiet)