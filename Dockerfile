FROM huggla/alpine:20180907-edge as stage1
FROM huggla/alpine-official:20180907-edge as stage2

COPY --from=stage1 / /rootfs
COPY ./rootfs /rootfs

ARG PGADMIN4_VERSION="3.3"
ARG APKS="python3 postgresql-libs"

RUN apk info > /pre_apks.list \
 && apk --no-cache add $APKS \
 && apk info > /post_apks.list \
 && apk manifest $(diff /pre_apks.list /post_apks.list | grep "^+[^+]" | awk -F + '{print $2}' | tr '\n' ' ') | awk -F "  " '{print $2;}' > /apks_files.list \
 && tar -cvp -f /apks_files.tar -T /apks_files.list -C / \
 && tar -xvp -f /apks_files.tar -C /rootfs/ \
 && mkdir -p /rootfs/var/lib/pgadmin \
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
 && ln -s ../local/bin/python3.6 python3.6

FROM huggla/alpine:20180907-edge

COPY --from=stage2 /rootfs /

ARG CONFIG_DIR="/etc/pgadmin"
ARG DATA_DIR="/pgdata"

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
