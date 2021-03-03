upstream backend {
    server localhost:8065;
    keepalive 32;
}
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=mattermost_cache:10m max_size=3g inactive=120m use_temp_path=off;

# cache pour API CGUs
proxy_cache_path /dev/shm/nginx-cgu levels=1:2 keys_zone=cgus_cache:10m max_size=1g inactive=1m use_temp_path=off;

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
      return 200 'up and running!';
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
    location /ads/dumps {
        alias /mnt/data/political-ads-scraper;
        autoindex on;
        if ($request_method = 'OPTIONS') {
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
            #
            # Custom headers and headers various browsers *should* be OK with but aren't
            #
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
            #
            # Tell client that this pre-flight info is valid for 20 days
            #
            add_header 'Access-Control-Max-Age' 1728000;
            add_header 'Content-Type' 'text/plain; charset=utf-8';
            add_header 'Content-Length' 0;
            return 204;
        }
        if ($request_method = 'POST') {
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
            add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
        }
        if ($request_method = 'GET') {
            add_header 'Access-Control-Allow-Origin' '*';
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
            add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
            add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
        }
    }
    location /bots {
        proxy_pass http://127.0.0.1:3000/;
    }

    location /preprod/api/open-terms-archive {
        proxy_pass http://51.75.169.235:7012$request_uri;
    }

    location /api/open-terms-archive {
        proxy_pass http://51.75.169.235/api/open-terms-archive/;
        proxy_cache cgus_cache;
        proxy_cache_valid 1m;
    }

    location /api/media-scale {
        proxy_pass http://127.0.0.1:3030/media-scale;
    }
    location /api/politicals-ads/1.0/ {
        proxy_pass http://127.0.0.1:3003/;
    }
    location /api/ads/1.0/ {
        proxy_pass http://127.0.0.1:3003/;
    }
    location ~ /collaborate/api/v[0-9]+/(users/)?websocket$ {
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Frame-Options SAMEORIGIN;
        client_max_body_size 50M;
        proxy_buffers 256 16k;
        proxy_buffer_size 16k;
        client_body_timeout 60;
        send_timeout 300;
        lingering_timeout 5;
        proxy_connect_timeout 90;
        proxy_send_timeout 300;
        proxy_read_timeout 90s;
        proxy_pass http://backend;
    }
    location /collaborate/ {
        client_max_body_size 50M;
        proxy_set_header Connection "";
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Frame-Options SAMEORIGIN;
        proxy_buffers 256 16k;
        proxy_buffer_size 16k;
        proxy_read_timeout 600s;
        proxy_cache mattermost_cache;
        proxy_cache_revalidate on;
        proxy_cache_min_uses 2;
        proxy_cache_use_stale timeout;
        proxy_cache_lock on;
        proxy_http_version 1.1;
        proxy_pass http://backend;
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