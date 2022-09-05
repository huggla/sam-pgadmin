# Secure and Minimal image of Pgadmin
# https://hub.docker.com/repository/docker/huggla/sam-pgadmin

# =========================================================================
# Init
# =========================================================================
# ARGs (can be passed to Build/Final) <BEGIN>
ARG SaM_VERSION="2.0.6-3.16"
ARG IMAGETYPE="application"
ARG PGADMIN_VERSION="6.13"
ARG PYTHON_VERSION="2.7.17"
ARG COREUTILS_VERSION="9.1"
ARG CONTENTIMAGE1="huggla/sam-content:coreutils-$COREUTILS_VERSION"
ARG CONTENTSOURCE1="/content-app/usr/bin/sync"
ARG CONTENTDESTINATION1="/tmp/finalfs/bin/"
ARG CONTENTIMAGE2="dpage/pgadmin4:$PGADMIN_VERSION"
ARG RUNDEPS="python3 postfix krb5-libs libjpeg-turbo shadow libedit libldap libcap gawk"
ARG BUILDDEPS=""
ARG BUILDCMDS=\
'   cp -a pgadmin4 entrypoint.sh /finalfs/ '\
'&& cp -a usr/local/pgsql* /finalfs/usr/local/ '\
'&& cp -a usr/lib/libpq.so* /finalfs/usr/lib/ '\
'&& cp -a venv /finalfs/ '\
'&& cd /finalfs/venv/bin '\
'&& ln -sf ../../usr/local/bin/python3.10 python3 '
#'&& mkdir -p /finalfs/venv/bin '\
#'&& cp -a venv/bin/gunicorn /finalfs/venv/bin/ '\
#'&& cp -a venv/lib venv/share venv/pyvenv.cfg /finalfs/venv/ '\
#'&& cd /finalfs/venv/bin '\
#'&& ln -sf ../../usr/local/bin/python3.10 python3 '
#"&& pip install --no-cache-dir --disable-pip-version-check --requirement pgadmin4-$PGADMIN_VERSION/requirements.txt "\
#'&& pip install --no-cache-dir --disable-pip-version-check gunicorn '\
#'&& python2.7 -OO -m compileall -x node_modules /pgadmin4 '\
#'&& cp -a /usr/bin/gunicorn /finalfs/usr/bin/ '\
#'&& pip uninstall --no-cache-dir --disable-pip-version-check --yes pip '\
#'&& cp -a /usr/lib/python2.7/site-packages /finalfs/usr/lib/python2.7/ '\
#"&& sed -i 's|#!/usr/bin/python2.7|#!/usr/local/bin/python2.7|' /finalfs/usr/bin/gunicorn"
ARG REMOVEFILES="/pgadmin4/babel.cfg /pgadmin4/karma.conf.js /pgadmin4/package.json /pgadmin4/webpack* /pgadmin4/yarn.lock /pgadmin4/.e* /pgadmin4/.p*"
ARG REMOVEDIRS="/pgadmin4/docs"
ARG MAKEDIRS="/var/lib/pgadmin"
ARG LINUXUSEROWNED="/var/lib/pgadmin /pgadmin4/config_distro.py"
ARG EXECUTABLES="/usr/bin/python3.10 /venv/bin/gunicorn /bin/sync /usr/bin/gawk"
# ARGs (can be passed to Build/Final) </END>

#ARG TAG="20190220"
#ARG CONTENTIMAGE1="huggla/pgadmin4:py3-$TAG"
#ARG CONTENTSOURCE1="/apps"
#ARG RUNDEPS="python3 postgresql-libs libressl2.7-libssl"
#ARG INITCMDS="chroot /buildfs /usr/bin/pip3 --no-cache-dir uninstall --yes pip"
#ARG BUILDCMDS=\
#"   sed -i 's|#!/usr/bin/python3.6|#!/usr/local/bin/python3.6|' /imagefs/usr/bin/gunicorn"
#ARG STARTUPEXECUTABLES="/usr/bin/python3.6 /usr/bin/gunicorn"

# Generic template (don't edit) <BEGIN>
FROM ${CONTENTIMAGE1:-scratch} as content1
FROM ${CONTENTIMAGE2:-scratch} as content2
FROM ${CONTENTIMAGE3:-scratch} as content3
FROM ${CONTENTIMAGE4:-scratch} as content4
FROM ${CONTENTIMAGE5:-scratch} as content5
FROM ${BASEIMAGE:-huggla/secure_and_minimal:$SaM_VERSION-base} as base
FROM ${INITIMAGE:-scratch} as init
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

#--------Generic template (don't edit)--------
USER starter
ONBUILD USER root
#---------------------------------------------
