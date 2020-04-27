# Secure and Minimal image of Pgadmin
# https://hub.docker.com/repository/docker/huggla/sam-pgadmin

# =========================================================================
# Init
# =========================================================================
# ARGs (can be passed to Build/Final) <BEGIN>
ARG SaM_VERSION="dev"
ARG IMAGETYPE="application,base"
ARG PGADMIN_VERSION="4.20"
ARG PYTHON_VERSION="2.7.17"
ARG CONTENTIMAGE1="huggla/sam-content:pgadmin-$PGADMIN_VERSION"
ARG CONTENTSOURCE1="/content-app"
ARG CONTENTDESTINATION1="/tmp/content-app"
ARG INITIMAGE="node:alpine"
ARG RUNDEPS="sqlite-libs postgresql-libs libffi libsodium"
ARG BUILDDEPS="python2 g++ zlib-dev libpng-dev postgresql-dev libffi-dev libsodium-dev sqlite-dev"
ARG BUILDCMDS=\
'   rm -rf /finalfs/* '\
'&& cp -a /tmp/content-app/pgadmin4 / '\
'&& cp -a /tmp/content-app/* /finalfs/ '\
'&& yarn config set cache ~/.yarn-cache '\
'&& yarn --cwd /pgadmin4 install '\
'&& yarn --cwd /pgadmin4 run bundle '\
'&& yarn cache clean '\
'&& mkdir -p /finalfs/pgadmin4/pgadmin/static/js/generated '\
'&& cp -a /pgadmin4/pgadmin/static/js/generated/* /finalfs/pgadmin4/pgadmin/static/js/generated/'
ARG REMOVEFILES="/pgadmin4/babel.cfg /pgadmin4/karma.conf.js /pgadmin4/package.json /pgadmin4/webpack* /pgadmin4/yarn.lock /pgadmin4/.e* /pgadmin4/.p*"
ARG EXECUTABLES="/usr/bin/python2.7 /usr/bin/gunicorn"
# ARGs (can be passed to Build/Final) </END>

# Generic template (don't edit) <BEGIN>
FROM ${CONTENTIMAGE1:-scratch} as content1
FROM ${CONTENTIMAGE2:-scratch} as content2
FROM ${CONTENTIMAGE3:-scratch} as content3
FROM ${CONTENTIMAGE4:-scratch} as content4
FROM ${CONTENTIMAGE5:-scratch} as content5
FROM ${INITIMAGE:-${BASEIMAGE:-huggla/secure_and_minimal:$SaM_VERSION-base}} as init
# Generic template (don't edit) </END>

RUN mkdir /environment

# =========================================================================
# Build
# =========================================================================
# Generic template (don't edit) <BEGIN>
FROM ${BUILDIMAGE:-huggla/secure_and_minimal:$SaM_VERSION-build} as build
FROM ${BASEIMAGE:-huggla/secure_and_minimal:$SaM_VERSION-base} as final
COPY --from=build /finalfs /
# Generic template (don't edit) </END>

# =========================================================================
# Final
# =========================================================================
ARG CONFIG_DIR="/etc/pgadmin"
ARG DATA_DIR="/pgdata"

ENV VAR_LINUX_USER="postgres" \
    VAR_CONFIG_FILE="$CONFIG_DIR/config_local.py" \
    VAR_THREADS="1" \
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
    VAR_FINAL_COMMAND="\$gunicornCmdArgs gunicorn pgAdmin4:app"
    
# Generic template (don't edit) <BEGIN>
USER starter
ONBUILD USER root
# Generic template (don't edit) </END>
