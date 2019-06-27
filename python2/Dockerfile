FROM alpine:3.7
LABEL maintainer "Ryan Pendleton <me@ryanp.me>"

RUN apk add --no-cache \
      build-base \
      linux-headers \
      nginx \
      python2 \
      python2-dev \
      uwsgi \
      uwsgi-python \
    && python -m ensurepip \
    && rm -r /usr/lib/python*/ensurepip \
    && pip install --upgrade pip setuptools \
    && pip install --upgrade uwsgi supervisor \
    && rm /etc/nginx/conf.d/default.conf \
    && rm -r /root/.cache \
    && mkdir -p /usr/share/nginx/html \
    && chmod 0777 /var/log/uwsgi

COPY etc/ /etc/

EXPOSE 80
CMD ["/usr/bin/supervisord"]
