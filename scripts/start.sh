#!/bin/bash

# Run prerender
node /prerender/server.js &

# Run nginx
nginx -c /etc/nginx/nginx.conf
