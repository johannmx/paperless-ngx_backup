ARG ARCH=
FROM ${ARCH}alpine:latest

RUN addgroup -S app && adduser -S -G app app

RUN apk add --no-cache \
    busybox-suid \
    su-exec \
    xz \
    tzdata

ENV CRON_TIME "*/5 * * * *"
ENV UID 100
ENV GID 100
ENV DELETE_AFTER 0
ENV GOTIFY_TOKEN 12345
ENV GOTIFY_SERVER server.com

# Install python/pip
ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools

# Install apprise for notificactions
RUN pip install apprise

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY script.sh /app/

RUN mkdir /app/log/ \
    && chown -R app:app /app/ \
    && chmod -R 777 /app/ \
    && chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
