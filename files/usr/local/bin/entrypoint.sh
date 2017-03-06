#!/bin/bash

set -e

echo "Stage specific configuration"
for VARIABLE in $(env); do
    find /home/airlock -type f -name '*.xml' -exec sed -i "s#{{ ${VARIABLE%=*} }}#${VARIABLE#*=}#g" {} +
done

DOMAIN=${DOMAIN:-DOMAIN}
REALM=${REALM:-DOMAIN.SAMPLE.COM}
PASSWORD_ENCRYPTION=${PASSWORD_ENCRYPTION:-false}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-$(pwgen -cny 10 1)}
KERBEROS_PASSWORD=${KERBEROS_PASSWORD:-$(pwgen -cny 10 1)}

rm -rf /etc/samba/smb.conf /var/lib/samba/*
mkdir -p /var/lib/samba/private

samba-tool domain provision --use-rfc2307 --domain=$DOMAIN --realm=$REALM --server-role=dc --dns-backend=BIND9_DLZ --adminpass=$ADMIN_PASSWORD
#--host-ip=${HOST_IP}

cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

if [ "${PASSWORD_ENCRYPTION,,}" == "false" ]; then
    sed -i "/\[global\]/a \\\t\# enable unencrypted passwords\nldap server require strong auth = no" /etc/samba/smb.conf
fi

/usr/sbin/kdb5_util create -s << ANSWERS
"$env(KERBEROS_PASSWORD)"
"$env(KERBEROS_PASSWORD)"

exit
ANSWERS

# Export kerberos keytab for use with sssd
if [ "${OMIT_EXPORT_KEY_TAB}" != "true" ]; then
    samba-tool domain exportkeytab /etc/krb5.keytab --principal ${HOSTNAME}\$
fi
