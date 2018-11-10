ARG TAG="20181108-edge"
ARG CONTENTIMAGE1="huggla/pgadmin4:$TAG"
ARG CONTENTSOURCE1="/apps"
ARG CONTENTDESTINATION1="/"
ARG RUNDEPS="python3 postgresql-libs libressl2.7-libssl"
ARG BUILDCMDS="\
"   cd /imagefs/usr/bin "\
"&& ln -s python3.6 python "\
"&& mv python /imagefs/usr/local/bin/"
ARG EXECUTABLES="/usr/bin/python3.6 /usr/bin/gunicorn"

#---------------Don't edit----------------
FROM ${CONTENTIMAGE1:-scratch} as content1
FROM ${CONTENTIMAGE2:-scratch} as content2
FROM ${BASEIMAGE:-huggla/base:$TAG} as base
FROM huggla/build:$TAG as build
FROM ${BASEIMAGE:-huggla/base:$TAG} as image
COPY --from=build /imagefs /
#-----------------------------------------

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

#---------------Don't edit----------------
USER starter
ONBUILD USER root
#-----------------------------------------
