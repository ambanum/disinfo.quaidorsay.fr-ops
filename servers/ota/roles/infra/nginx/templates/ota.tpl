server {
  server_name opentermsarchive.org www.opentermsarchive.org;

  location /health-check {
    add_header Content-Type text/plain always;
    return 200 'opentermsarchive.org up and running!';
  }

  location / {
    proxy_pass http://51.75.169.235:7021$request_uri;
  }


  listen 443 ssl; # managed by Certbot
  ssl_certificate /etc/letsencrypt/live/opentermsarchive.org/fullchain.pem; # managed by Certbot
  ssl_certificate_key /etc/letsencrypt/live/opentermsarchive.org/privkey.pem; # managed by Certbot
  include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}

server {
  server_name preprod.opentermsarchive.org;

  location /health-check {
    add_header Content-Type text/plain always;
    return 200 'preprod.opentermsarchive.org up and running!';
  }

  location / {
    proxy_pass http://51.75.169.235:7022$request_uri;
  }

  listen 443 ssl; # managed by Certbot
  ssl_certificate /etc/letsencrypt/live/preprod.opentermsarchive.org/fullchain.pem; # managed by Certbot
  ssl_certificate_key /etc/letsencrypt/live/preprod.opentermsarchive.org/privkey.pem; # managed by Certbot
  include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
  ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}


server {
  if ($host = preprod.opentermsarchive.org) {
    return 301 https://$host$request_uri;
  } # managed by Certbot


  listen 80;
  server_name preprod.opentermsarchive.org;
  return 404; # managed by Certbot
}

server {
  if ($host = www.opentermsarchive.org) {
    return 301 https://$host$request_uri;
  } # managed by Certbot


  if ($host = opentermsarchive.org) {
    return 301 https://$host$request_uri;
  } # managed by Certbot


  server_name opentermsarchive.org www.opentermsarchive.org;
  listen 80;
  return 404; # managed by Certbot
}