FROM huggla/alpine:20180907-edge as stage1

FROM node:6 AS stage2

ARG PGADMIN4_TAG="REL-3_3"

RUN apt-get update \
 && apt-get install -y --no-install-recommends git \
 && git clone --branch $PGADMIN4_TAG --depth 1 https://git.postgresql.org/git/pgadmin4.git \
 && yarn --cwd /pgadmin4/web install \
 && yarn --cwd /pgadmin4/web run bundle \
 && yarn cache clean \
 && apt-get purge -y --auto-remove git \
 && mv /pgadmin4/web/pgadmin/static/js/generated / \
 && rm -rf /pgadmin4

FROM huggla/alpine-official:20180907-edge as stage3

COPY --from=stage1 / /rootfs
COPY ./rootfs /rootfs
COPY --from=stage2 /generated/ /rootfs/pgadmin4/web/pgadmin/static/js/generated/

ARG PGADMIN4_TAG="REL-3_3"
ARG APKS="python3 postgresql-libs libressl2.7-libssl libressl2.7-libcrypto"

RUN apk --no-cache --quiet info > /pre_apks.list \
 && sed -i '/libressl2.7-libssl/d' /pre_apks.list \
 && sed -i '/libressl2.7-libcrypto/d' /pre_apks.list \
 && apk --no-cache add $APKS \
 && apk --no-cache --quiet info > /post_apks.list \
 && apk --no-cache --quiet manifest $(diff /pre_apks.list /post_apks.list | grep "^+[^+]" | awk -F + '{print $2}' | tr '\n' ' ') | awk -F "  " '{print $2;}' > /apks_files.list \
 && tar -cvp -f /apks_files.tar -T /apks_files.list -C / \
 && tar -xvp -f /apks_files.tar -C /rootfs/ \
 && apk --no-cache add --virtual .build-dependencies build-base postgresql-dev libffi-dev git python3-dev \
 && pip3 --no-cache-dir install --upgrade pip \
 && pip3 --no-cache-dir install gunicorn \
 && git clone --branch $PGADMIN4_TAG --depth 1 https://git.postgresql.org/git/pgadmin4.git \
 && pip3 install --no-cache-dir -r /pgadmin4/requirements.txt \
 && apk --no-cache del .build-dependencies \
 && cp -a /pgadmin4/web/* /rootfs/pgadmin4/ \
 && cp -a /pgadmin4/pkg/docker/run_pgadmin.py /rootfs/pgadmin4/ \
 && cp -a /pgadmin4/pkg/docker/config_distro.py /rootfs/pgadmin4/ \
 && rm -rf /pgadmin \
 && python3.6 -O -m compileall /rootfs/pgadmin4 \
 && cp -a /usr/lib/python3.6/site-packages /rootfs/usr/lib/python3.6/ \
 && mv /rootfs/usr/bin/python3.6 /rootfs/usr/local/bin/ \
 && cd /rootfs/usr/bin \
 && ln -s ../local/bin/python3.6 python3.6 \
 && cd /rootfs/usr/local/bin \
 && ln -s python3.6 python

#FROM huggla/alpine:20180907-edge

#COPY --from=stage3 /rootfs /

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
    VAR_FINAL_COMMAND="/bin/ls"

USER starter

ONBUILD USER root
