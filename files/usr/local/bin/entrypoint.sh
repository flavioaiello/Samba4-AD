#!/bin/sh

# Envs eg. default values
DOMAIN=${DOMAIN:-DOMAIN}
REALM=${REALM:-DOMAIN.SAMPLE.COM}
PASSWORD_ENCRYPTION=${PASSWORD_ENCRYPTION:-false}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-$(pwgen -cny 10 1)}
KERBEROS_PASSWORD=${KERBEROS_PASSWORD:-$(pwgen -cny 10 1)}

# Configuration not need actualy
#for VARIABLE in $(env); do
#    find /etc/samba -type f -name '*.xml' -exec sed -i "s#{{ ${VARIABLE%=*} }}#${VARIABLE#*=}#g" {} +
#done

# Setup
samba-tool domain provision --server-role=dc --use-rfc2307 --dns-backend=SAMBA_INTERNAL --realm=${REALM} --domain=${DOMAIN} --adminpass=${ADMIN_PASSWORD}

# Kerberos
ln -sf /var/lib/samba/private/krb5.conf /etc/krb5.conf

exec "$@"
