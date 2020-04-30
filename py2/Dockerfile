# Secure and Minimal image of Pgadmin
# https://hub.docker.com/repository/docker/huggla/sam-pgadmin

# =========================================================================
# Init
# =========================================================================
# ARGs (can be passed to Build/Final) <BEGIN>
ARG SaM_VERSION="dev"
ARG IMAGETYPE="application"
ARG PGADMIN_VERSION="4.20"
ARG PYTHON_VERSION="2.7.17"
ARG CONTENTIMAGE1="huggla/pgadmin4-node_build:$PGADMIN_VERSION"
ARG CONTENTSOURCE1="/pgadmin4"
ARG CONTENTDESTINATION1="/pgadmin4"
ARG CONTENTIMAGE2="huggla/sam-content:python-$PYTHON_VERSION"
ARG CONTENTSOURCE2="/content-dev"
ARG CONTENTDESTINATION2="/"
ARG BASEIMAGE="huggla/sam-python:$PYTHON_VERSION"
ARG DOWNLOADS="https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v$PGADMIN_VERSION/source/pgadmin4-$PGADMIN_VERSION.tar.gz"
ARG RUNDEPS="sqlite-libs postgresql-libs libffi libsodium"
ARG BUILDDEPS="postgresql-dev libffi-dev libsodium-dev sqlite-dev"
ARG BUILDCMDS=\
'   cp -a /pgadmin4 /finalfs/ '\
"&& pip install --no-cache-dir --disable-pip-version-check --requirement pgadmin4-$PGADMIN_VERSION/requirements.txt "\
'&& pip install --no-cache-dir --disable-pip-version-check gunicorn '\
'&& python2.7 -OO -m compileall -x node_modules /pgadmin4 '\
'&& cp -a /usr/bin/gunicorn /finalfs/usr/bin/ '\
'&& pip uninstall --no-cache-dir --disable-pip-version-check --yes pip '\
'&& cp -a /usr/lib/python2.7/site-packages /finalfs/usr/lib/python2.7/ '\
"&& sed -i 's|#!/usr/bin/python2.7|#!/usr/local/bin/python2.7|' /finalfs/usr/bin/gunicorn"
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
# Needs sync from coreutils! Workaround: set VAR_LINUX_USER=root
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
