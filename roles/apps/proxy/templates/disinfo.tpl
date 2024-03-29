upstream backend {
    server localhost:8065;
    keepalive 32;
}
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=mattermost_cache:10m max_size=3g inactive=120m use_temp_path=off;

server {
    server_name desinfo.quaidorsay.fr;
    rewrite ^/(.*)$ https://disinfo.quaidorsay.fr/$1 redirect;
}
server {
    listen 80 default_server;
    server_name disinfo.quaidorsay.fr;
{% if enable_https %}
    return 301 https://$server_name$request_uri;
}
server {
    listen 443 ssl http2;
    server_name disinfo.quaidorsay.fr;
    ssl_certificate /etc/letsencrypt/live/disinfo.quaidorsay.fr/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/disinfo.quaidorsay.fr/privkey.pem;
    ssl_session_timeout 1d;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256';
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:50m;
{% endif %}

    location /health-check {
      add_header Content-Type text/plain always;
      return 200 'disinfo up and running!';
    }

    location /political-ads-consistency {
        alias /home/{{ ansible_user }}/political-ads-consistency/build/;
        index index.html;
        try_files $uri $uri/ index.html =404;
    }
    location /political-ads {
        alias /home/{{ ansible_user }}/political-ads-crowdsourcing-client/build/;
        index index.html;
        try_files $uri $uri/ index.html =404;
    }
    location /ads/fr/crowdsourcing {
        return 301 /political-ads/fr/crowdsourcing;
    }
    location /ads/crowdsourcing {
        return 301 /political-ads/crowdsourcing;
    }
    location /ads {
        return 301 /political-ads;
    }
#    location /ads/dumps {
#        alias /mnt/data/political-ads-scraper;
#        autoindex on;
#        if ($request_method = 'OPTIONS') {
#            add_header 'Access-Control-Allow-Origin' '*';
#            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
#            #
#            # Custom headers and headers various browsers *should* be OK with but aren't
#            #
#            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
#            #
#            # Tell client that this pre-flight info is valid for 20 days
#            #
#            add_header 'Access-Control-Max-Age' 1728000;
#            add_header 'Content-Type' 'text/plain; charset=utf-8';
#            add_header 'Content-Length' 0;
#            return 204;
#        }
#        if ($request_method = 'POST') {
#            add_header 'Access-Control-Allow-Origin' '*';
#            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
#            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
#            add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
#        }
#        if ($request_method = 'GET') {
#            add_header 'Access-Control-Allow-Origin' '*';
#            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
#            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
#            add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
#        }
#    }
#    location /bots {
#        proxy_pass http://127.0.0.1:3000/;
#    }

    ###
    # Other
    ###
    location /api/media-scale {
        proxy_pass http://127.0.0.1:3030/media-scale;
    }
    location /api/politicals-ads/1.0/ {
        proxy_pass http://127.0.0.1:3003/;
    }
    location /api/ads/1.0/ {
        proxy_pass http://127.0.0.1:3003/;
    }
    location /DormantTwitterAccountsDetector {
        proxy_pass https://ambanum.github.io/DormantTwitterAccountsDetector/;
    }
    location /twitter-bot-clusters {
        proxy_pass https://ambanum.github.io/DormantTwitterAccountsDetector/;
    }
    location /encyclopedia {
        proxy_pass https://ambanum.github.io/disencyclopedia/;
    }
    location / {
        proxy_pass https://ambanum.github.io/disinfo.quaidorsay.fr/;
    }
}
