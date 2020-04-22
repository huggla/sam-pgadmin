# Secure and Minimal image of Pgadmin
# https://hub.docker.com/repository/docker/huggla/sam-pgadmin

# =========================================================================
# Init
# =========================================================================
# ARGs (can be passed to Build/Final) <BEGIN>
ARG SaM_VERSION="2.0.2"
ARG IMAGETYPE="application,base"
ARG PGADMIN4_TAG="REL-4_2"
ARG PYTHON_VERSION="2.7.17"
ARG CONTENTIMAGE1="huggla/sam-content:python-$PYTHON_VERSION"
ARG CONTENTSOURCE1="/content-dev"
ARG CONTENTDESTINATION1="/"
ARG BASEIMAGE="huggla/sam-python:$PYTHON_VERSION"
ARG CLONEGITS="'--branch $PGADMIN4_TAG --depth 1 https://git.postgresql.org/git/pgadmin4.git'"
ARG MAKEDIRS="/usr/lib/python2.7"
ARG RUNDEPS="python2 postgresql-libs libressl3.0-libssl"
ARG BUILDDEPS="postgresql-dev libffi-dev libsodium-dev"
ARG BUILDCMDS=\
'   pip --no-cache-dir install gunicorn '\
'&& pip install --no-cache-dir -r pgadmin4/requirements.txt '\
'&& cp -a pgadmin4/web /tmp/pgadmin4 '\
'&& cp -a /usr/bin/gunicorn /finalfs/usr/bin/ '\
'&& rm -rf pgadmin4 /tmp/pgadmin4/regression /tmp/pgadmin4/pgadmin/feature_tests '\
'&& find /tmp/pgadmin4 -name tests -type d | xargs rm -rf '\
'&& mv /tmp/pgadmin4 ./ '\
'&& python2.7 -OO -m compileall pgadmin4 '\
'&& mv pgadmin4 /finalfs/pgadmin4 '\
'&& cp -a /usr/lib/python2.7/site-packages /finalfs/usr/lib/python2.7/ '\
"&& sed -i 's|#!/usr/bin/python2.7|#!/usr/local/bin/python2.7|' /finalfs/usr/bin/gunicorn"
ARG STARTUPEXECUTABLES="/usr/bin/python2.7 /usr/bin/gunicorn"
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
