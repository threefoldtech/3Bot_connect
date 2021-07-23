cd /usr/share/nginx/backend/ && uwsgi --http :5000 --gevent 1000 --http-websockets --master --wsgi-file __main__.py --callable app -s 0.0.0.0:3030 &
nginx -g 'daemon off;'
