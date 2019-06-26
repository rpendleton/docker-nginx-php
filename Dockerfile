FROM alpine:3.7
LABEL maintainer "Ryan Pendleton <me@ryanp.me>"

RUN apk add --no-cache \
      build-base \
      linux-headers \
      nginx \
      python3 \
      python3-dev \
      supervisor \
      uwsgi \
      uwsgi-python3 \
    && python3 -m ensurepip \
    && rm -r /usr/lib/python*/ensurepip \
    && pip3 install --upgrade pip setuptools uwsgi supervisor-stdout \
    && rm /etc/nginx/conf.d/default.conf \
    && rm -r /root/.cache \
    && mkdir -p /usr/share/nginx/html \
    && chmod 0777 /var/log/uwsgi

COPY etc/ /etc/

EXPOSE 80
CMD ["/usr/bin/supervisord"]
