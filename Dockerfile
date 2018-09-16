FROM huggla/alpine:20180907-edge as stage1

FROM node:6 AS stage2

ARG PGADMIN4_TAG="REL-3_3"

RUN apt-get update \
 && apt-get install -y --no-install-recommends git \
 && git clone --branch $PGADMIN4_TAG --depth 1 https://git.postgresql.org/git/pgadmin4.git \
 && yarn --cwd /pgadmin4/web install \
 && yarn --cwd /pgadmin4/web run bundle \
 && yarn cache clean \
 && apt-get purge -y --auto-remove git
 
FROM huggla/alpine-official:20180907-edge as stage3

COPY --from=stage1 / /rootfs
COPY ./rootfs /rootfs
COPY --from=stage2 /pgadmin4/requirements.txt /rootfs/pgadmin4/
COPY --from=stage2 /pgadmin4/pkg/docker/run_pgadmin.py /rootfs/pgadmin4/
COPY --from=stage2 /pgadmin4/pkg/docker/config_distro.py /rootfs/pgadmin4/
COPY --from=stage2 /pgadmin4/web/* /rootfs/pgadmin4/

ARG APKS="python3 postgresql-libs libressl2.7-libssl libressl2.7-libcrypto libffi ca-certificates libintl krb5-conf libcom_err keyutils-libs libverto krb5-libs libtirpc libnsl build-base postgresql-dev libffi-dev git python3-dev"

RUN apk --no-cache --quiet info > /pre_apks.list \
 && sed -i '/libressl2.7-libssl/d' /pre_apks.list \
 && sed -i '/libressl2.7-libcrypto/d' /pre_apks.list \
 && apk --no-cache add $APKS \
 && apk --no-cache --quiet info > /post_apks.list \
 && apk --no-cache --quiet manifest $(diff /pre_apks.list /post_apks.list | grep "^+[^+]" | awk -F + '{print $2}' | tr '\n' ' ') | awk -F "  " '{print $2;}' > /apks_files.list \
 && tar -cvp -f /apks_files.tar -T /apks_files.list -C / \
 && tar -xvp -f /apks_files.tar -C /rootfs/ \
 && mv /rootfs/pgadmin4 / \
 && pip3 --no-cache-dir install --upgrade pip \
 && pip3 --no-cache-dir install gunicorn \
 && cp -a /usr/bin/gunicorn /rootfs/usr/bin/ \
 && cp -a /usr/lib/python3.6/site-packages /rootfs/usr/lib/python3.6/ \
 && mkdir -p /pgadmin4/pgadmin/tillf \
 && cp -a /pgadmin4/requirements.txt \
 && pip3 install --no-cache-dir -r requirements.txt \
 && mkdir -p /var/lib/pgadmin \
 && mv /rootfs/usr/bin/python3.6 /rootfs/usr/local/bin/ \
 && cd /rootfs/usr/bin \
 && ln -s ../local/bin/python3.6 python3.6 \
 && cd /rootfs/usr/local/bin \
 && ln -s python3.6 python
