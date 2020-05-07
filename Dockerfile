FROM node:12 as builder

COPY frontend /frontend
WORKDIR /frontend
RUN npm ci && npm run build

COPY example /example
WORKDIR /example
RUN npm ci && npm run build

COPY wizard /wizard
WORKDIR /wizard
RUN npm ci && npm run build

FROM nginx
COPY backend/requirements.txt requirements.txt

RUN apt update && apt install -y python3 python3-pip gcc libssl-dev python-gevent
RUN CFLAGS="-I/usr/local/opt/openssl/include" LDFLAGS="-L/usr/local/opt/openssl/lib" \
  UWSGI_PROFILE_OVERRIDE=ssl=true pip3 install uwsgi -Iv
# RUN pip3 install flask flask_socketio flask_cors pyfcm pynacl
RUN pip3 install -r requirements.txt
RUN pip3 install gevent

COPY --from=builder /frontend/dist /var/www/html/frontend
COPY --from=builder /example/dist /var/www/html/example
COPY --from=builder /wizard/dist /var/www/html/wizard
COPY backend/ /usr/share/nginx/backend

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY services.sh /services.sh
RUN chmod +x /services.sh
WORKDIR /usr/share/nginx/backend/

CMD /./services.sh
