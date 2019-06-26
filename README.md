## Introduction

rpendleton/nginx-uwsgi is a Docker image that includes various components useful
for running a Python uWSGI service. It is comprised of:

* Supervisord
* nginx
* uWSGI
* Python 3

Although this image is based on Alpine Linux, I made the decision to include
build dependencies which result in a larger image. I prefer this since it
results in a simpler application Dockerfile and faster CI rebuild times. If
you're looking for a small image, you'll likely want to make modifications or
look elsewhere.

Additionally, since this image is mainly used for personal projects and changes
often, I'd advise against using it directly as the base for your own image.
Instead, I'd recommend forking it or simply using parts of it to create your own
images that fulfill your needs.

## How to Use

This image is meant to be a base image for an application image and makes no
effort to automatically configure your application. To use it, you must add both
nginx and uWSGI configuration files for your application.

By default, nginx has a site configured that serves static files from
`/usr/share/nginx/html`. This configuration file can be found at
`/etc/nginx/conf.d/default.conf` and should be replaced or removed in child
images. Additional configuration files can be placed at:

* `/etc/nginx/main.d/*.conf` for global level
* `/etc/nginx/conf.d/*.conf` for http level

By default, uWSGI is configured in Emperor mode. Configuration files can be
placed at:

* `/etc/uwsgi/conf.d/*.ini`

By default, Supervisord is configured to start nginx and uWSGI on container
start. If you need to start additional services, configuration files can be
placed at:

* `/etc/supervisord/conf.d/*.conf`

## Example

This example shows how to create an image for a simple Django app.

**Dockerfile:**

```Dockerfile
FROM rpendleton/nginx-uwsgi:python3
ADD requirements.txt /requirements.txt

RUN apk add --no-cache --virtual .build-deps mariadb-dev \
 && pip3 install --no-cache-dir -r /requirements.txt \
 && apk add --no-cache --virtual .runtime-deps mariadb-client-libs \
 && apk del .build-deps

WORKDIR /app/

RUN rm /etc/nginx/conf.d/default.conf
ADD conf/myapp-env.conf /etc/nginx/main.d/
ADD conf/myapp-site.conf /etc/nginx/conf.d/

COPY --chown=nginx:nginx conf/myapp-uwsgi.ini /etc/uwsgi/conf.d/
COPY --chown=nginx:nginx . /app

ENV DJANGO_SETTINGS_MODULE=myapp.settings
RUN python3 manage.py collectstatic --noinput
```

**env.conf:**

```nginx
env MYSQL_HOST;
env MYSQL_USER;
env MYSQL_PASSWORD;
env MYSQL_DATABASE;
```

**site.conf:**

```nginx
server {
    listen 80 default_server;
    server_name myapp.com;

    location / {
        try_files $uri @app;
    }

    location /static {
        alias /app/public/static;
    }

    location @app {
        include uwsgi_params;
        uwsgi_pass unix:///tmp/myapp-uwsgi.sock;
    }
}
```

**uwsgi.ini:**

```ini
[uwsgi]
chdir = /app/
module = site.wsgi
plugins = python
socket = /tmp/myapp-uwsgi.sock

cheaper = 2
processes = %(%k + 2)
```
