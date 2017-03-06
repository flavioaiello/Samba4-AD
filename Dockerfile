FROM alpine:latest

COPY files /

RUN set ex;\
    apk update;\
    apk upgrade;\
    apk add --no-cache supervisor samba-dc krb5-server bind bind-tools pwgen acl-dev attr-dev blkid gnutls-dev readline-dev python-dev linux-pam-dev py-pip popt-dev openldap-dev libbsd-dev cups-dev ca-certificates py-certifi tdb tdb-dev py-tdb;\
    pip install --upgrade pip;\
    pip install dnspython;\
    chmod -R +x /usr/local/bin

VOLUME ["/etc/samba", "/var/lib/samba", "/var/run/samba"]

EXPOSE 22 53 389 88 135 139 138 445 464 3268 3269

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
