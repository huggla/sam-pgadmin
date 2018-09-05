FROM huggla/alpine as stage1

ARG PGADMIN4_VERSION="3.2"
ARG APKS="python3 postgresql-libs"

COPY ./rootfs /rootfs

RUN find bin usr lib etc var home sbin root run srv -type d -print0 | sed -e 's|^|/rootfs/|' | xargs -0 mkdir -p \
 && cp -a /lib/apk/db /rootfs/lib/apk/ \
 && cp -a /etc/apk /rootfs/etc/ \
 && cd / \
 && cp -a /bin /sbin /rootfs/ \
 && cp -a /usr/bin /usr/sbin /rootfs/usr/ \
 && apk --no-cache --quiet info | xargs apk --quiet --no-cache --root /rootfs fix \
 && apk --no-cache --quiet --root /rootfs add $APKS \
 && rm /rootfs/usr/bin/sudo /rootfs/usr/bin/dash \
 && mkdir -p /rootfs/var/lib/pgadmin \
 && apk --no-cache --quiet add $APKS \
 && apk --no-cache add --virtual .build-dependencies python3-dev gcc musl-dev postgresql-dev wget ca-certificates libffi-dev make \
 && downloadDir="$(mktemp -d)" \
 && wget -O "$downloadDir/pgadmin4-${PGADMIN4_VERSION}-py2.py3-none-any.whl" https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v${PGADMIN4_VERSION}/pip/pgadmin4-${PGADMIN4_VERSION}-py2.py3-none-any.whl \
 && pip3 --no-cache-dir install --upgrade pip \
 && pip3 --no-cache-dir install "$downloadDir/pgadmin4-${PGADMIN4_VERSION}-py2.py3-none-any.whl" \
 && rm -rf "$downloadDir" /rootfs/usr/lib/python3.6/site-packages \
 && apk del .build-dependencies \
 && cp -a /usr/lib/python3.6/site-packages /rootfs/usr/lib/python3.6/ \
 && mv /rootfs/usr/bin/python3.6 /rootfs/usr/local/bin/ \
 && cd /rootfs/usr/bin \
 && ln -s ../local/bin/python3.6 python3.6 \
 && apk --no-cache --root /rootfs del apk-tools \
 && rm -r /rootfs/lib/apk /var/cache

FROM huggla/alpine

ARG CONFIG_DIR="/etc/pgadmin"
ARG DATA_DIR="/pgdata"

COPY --from=stage1 /rootfs /

ENV VAR_LINUX_USER="postgres" \
    VAR_CONFIG_FILE="$CONFIG_DIR/config_local.py" \
    VAR_param_DEFAULT_SERVER="'0.0.0.0'" \
    VAR_param_SERVER_MODE="False" \
    VAR_param_ALLOW_SAVE_PASSWORD="False" \
    VAR_param_CONSOLE_LOG_LEVEL="30" \
    VAR_param_LOG_FILE="'/var/log/pgadmin'" \
    VAR_param_FILE_LOG_LEVEL="0" \
    VAR_param_SQLITE_PATH="'$DATA_DIR/sqlite/pgadmin4.db'" \
    VAR_param_SESSION_DB_PATH="'$DATA_DIR/sessions'" \
    VAR_param_STORAGE_DIR="'$DATA_DIR/storage'" \
    VAR_param_UPGRADE_CHECK_ENABLED="False" \
    VAR_FINAL_COMMAND="/usr/local/bin/python3.6 /usr/lib/python3.6/site-packages/pgadmin4/pgAdmin4.py"

USER starter

ONBUILD USER root
