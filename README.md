**Note! I use Docker latest tag for development, which means that it isn't allways working. Date tags are stable.**

# pgadmin-alpine
Pgadmin 4 on Alpine (currently v3.3) without postgresql-client and docs. Will by default run in desktop mode (no multi-user or authentication). Set VAR_param_SERVER_MODE="True" to run in server mode. I recommend putting VAR_param_SQLITE_PATH on persistent storage. Listens on port 5050 internally.

## Environment variables
### pre-set runtime variables
* VAR_LINUX_USER (postgres)
* VAR_CONFIG_FILE (/etc/pgadmin/config_local.py)
* VAR_THREADS (1): Number of threads used (by Gunicorn).
* VAR_FINAL_COMMAND (\$gunicornCmdArgs gunicorn pgAdmin4:app)
* VAR_param_DEFAULT_SERVER ('0.0.0.0')
* VAR_param_SERVER_MODE (False)
* VAR_param_ALLOW_SAVE_PASSWORD (False)
* VAR_param_CONSOLE_LOG_LEVEL (30)
* VAR_param_LOG_FILE ('/var/log/pgadmin')
* VAR_param_FILE_LOG_LEVEL (0)
* VAR_param_SQLITE_PATH ('/pgdata/sqlite/pgadmin4.db')
* VAR_param_SESSION_DB_PATH ('/pgdata/sessions')
* VAR_param_STORAGE_DIR ('/pgdata/storage')
* VAR_param_UPGRADE_CHECK_ENABLED (False)
* VAR_ARGON2_PARAMS (-r): Custom password encryption parameters, if VAR_ENCRYPT_PW="yes".
* VAR_SALT_FILE (/proc/sys/kernel/hostname): Password encryption salt, if VAR_ENCRYPT_PW="yes".

### Optional runtime variables
* VAR_param_&lt;parameter name&gt;: For Pgadmin4 parameters.
* VAR_ENABLE_TLS: Set to "True" to use ssl.
* VAR_SSL_KEYFILE: Path to key file. Needed if VAR_ENABLE_TLS is set to True.
* VAR_SSL_CERTFILE: Path to cert file. Needed if VAR_ENABLE_TLS is set to True.
* VAR_email_server: Set initial login email during server mode initialization.
* VAR_password_server: Set initial login password during server mode initialization. 
* VAR_password_file_server
* VAR_ENCRYPT_PW: Set to "yes" to create a hashed password with Argon2.
* VAR_SALT

## Capabilities
Can drop all but SETPCAP, SETGID and SETUID.
