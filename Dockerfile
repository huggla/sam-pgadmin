FROM huggla/alpine as stage1

FROM node:6 AS stage2
COPY ./pgadmin4/web/ /pgadmin4/web/
WORKDIR /pgadmin4/web
RUN yarn install --cache-folder ./ycache --verbose \
 && yarn run bundle \
 && rm -rf ./ycache ./pgadmin/static/js/generated/.cache

FROM huggla/alpine-official as stage3

COPY --from=stage1 / /rootfs
COPY --from=stage2 /pgadmin4/web/pgadmin/static/js/generated/ /pgadmin4/web/pgadmin/static/js/generated/
COPY ./rootfs /rootfs

ARG PGADMIN4_VERSION="3.3"
ARG APKS="python3 postgresql-libs libressl2.7-libssl libressl2.7-libcrypto"

RUN apk info > /pre_apks.list \
 && sed -i '/libressl2.7-libssl/d' /pre_apks.list \
 && sed -i '/libressl2.7-libcrypto/d' /pre_apks.list \
 && apk --no-cache add $APKS \
 && apk --no-cache info > /post_apks.list \
 && apk --no-cache manifest $(diff /pre_apks.list /post_apks.list | grep "^+[^+]" | awk -F + '{print $2}' | tr '\n' ' ') | awk -F "  " '{print $2;}' > /apks_files.list \
 && tar -cvp -f /apks_files.tar -T /apks_files.list -C / \
 && tar -xvp -f /apks_files.tar -C /rootfs/ \
 && apk --no-cache add --virtual .build-dependencies build-base postgresql-dev libffi-dev git \
 && pip3 --no-cache-dir install --upgrade pip \
 && pip3 --no-cache-dir install gunicorn \
 && git clone https://git.postgresql.org/git/pgadmin4.git \
	# && wget "https://git.postgresql.org/gitweb/?p=pgadmin4.git;a=blob_plain;f=requirements.txt;h=38646fbb4111fddb2c373a949ed59b429c398681;hb=HEAD" \
 && pip3 install --no-cache-dir -r /pgadmin4/requirements.txt \
 && apk --no-cache del .build-dependencies \
 && cp -a /pgadmin4/web /rootfs/pgadmin4 \
 && cp -a /pgadmin4/pkg/docker/run_pgadmin.py /rootfs/pgadmin4/ \
 && cp -a /pgadmin4/pkg/docker/config_distro.py /rootfs/pgadmin4/ \
 && python3.6 -O -m compileall /rootfs/pgadmin4

# && mkdir -p /rootfs/var/lib/pgadmin \
# && apk --no-cache add --virtual .build-dependencies python3-dev gcc musl-dev postgresql-dev wget ca-certificates libffi-dev make \
# && downloadDir="$(mktemp -d)" \
# && wget -O "$downloadDir/pgadmin4-${PGADMIN4_VERSION}-py2.py3-none-any.whl" https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v${PGADMIN4_VERSION}/pip/pgadmin4-${PGADMIN4_VERSION}-py2.py3-none-any.whl \
# && pip3 --no-cache-dir install --upgrade pip \
# && pip3 --no-cache-dir install "$downloadDir/pgadmin4-${PGADMIN4_VERSION}-py2.py3-none-any.whl" \
# && rm -rf "$downloadDir" /rootfs/usr/lib/python3.6/site-packages \
# && apk del .build-dependencies \
# && cp -a /usr/lib/python3.6/site-packages /rootfs/usr/lib/python3.6/ \
# && mv /rootfs/usr/bin/python3.6 /rootfs/usr/local/bin/ \
# && cd /rootfs/usr/bin \
# && ln -s ../local/bin/python3.6 python3.6

#FROM huggla/alpine

#COPY --from=stage2 /rootfs /

#ARG CONFIG_DIR="/etc/pgadmin"
#ARG DATA_DIR="/pgdata"

#ENV VAR_LINUX_USER="postgres" \
#    VAR_CONFIG_FILE="$CONFIG_DIR/config_local.py" \
#    VAR_param_DEFAULT_SERVER="'0.0.0.0'" \
#    VAR_param_SERVER_MODE="False" \
#    VAR_param_ALLOW_SAVE_PASSWORD="False" \
#    VAR_param_CONSOLE_LOG_LEVEL="30" \
#    VAR_param_LOG_FILE="'/var/log/pgadmin'" \
#    VAR_param_FILE_LOG_LEVEL="0" \
#    VAR_param_SQLITE_PATH="'$DATA_DIR/sqlite/pgadmin4.db'" \
#    VAR_param_SESSION_DB_PATH="'$DATA_DIR/sessions'" \
#    VAR_param_STORAGE_DIR="'$DATA_DIR/storage'" \
#    VAR_param_UPGRADE_CHECK_ENABLED="False" \
#    VAR_FINAL_COMMAND="/usr/local/bin/python3.6 /usr/lib/python3.6/site-packages/pgadmin4/pgAdmin4.py"

#USER starter

#ONBUILD USER root
