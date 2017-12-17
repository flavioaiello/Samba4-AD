FROM alpine:3.7

COPY files /

RUN set -ex;\
    apk update;\
    apk upgrade;\
    apk add --no-cache supervisor samba-dc pwgen ca-certificates;\
    chmod -R +x /usr/local/bin

VOLUME ["/var/lib/samba"]

EXPOSE 22 53 389 88 135 139 138 445 464 3268 3269

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["supervisord", "-c", "/etc/supervisord.conf"]
