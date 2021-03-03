upstream backend {
    server localhost:8065;
    keepalive 32;
}

server {
    listen 80 default_server;
    server_name disinfo.quaidorsay.fr;

    # #################
    # Common
    # #################

    location /health-check {
      add_header Content-Type text/plain always;
      return 200 'up and running!';
    }
}