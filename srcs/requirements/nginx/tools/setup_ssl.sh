#!/bin/bash

#only if ssl cert isnt done already
if [ ! -f /etc/ssl/certs/inception.crt ]; then
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/ssl/private/inception.key \
		-out /etc/ssl/certs/inception.crt \
		-subj "/C=BE/ST=Brussels/L=Brussels/O=42/CN=${DOMAIN_NAME}"
	echo "SSL Cert generated"
fi

exec nginx -g "daemon off;"
#daemon off, if not, nginx goes in background, req for docker
