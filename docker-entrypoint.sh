#!/bin/bash
set -e

# Who and where am I ?
echo >&2 "[INFO] ---------------------------------------------------"
echo >&2 "[INFO] GLOBAL INFORMATIONS"
echo >&2 "[INFO] ---------------------------------------------------"
echo >&2 "[INFO] whoami : $(whoami)"
echo >&2 "[INFO] pwd : $(pwd)"

# Backup the prev install in case of fail...
echo >&2 "[INFO] ---------------------------------------------------"
echo >&2 "[INFO] Backup old pydio installation in $(pwd)"
echo >&2 "[INFO] ---------------------------------------------------"
tar -zcvf /var/backup/pydio/pydio-v$(date '+%Y%m%d%H%M%S').tar.gz .
echo >&2 "[INFO] Complete! Backup successfully done in $(pwd)"

# Upgrade
echo >&2 "[INFO] ---------------------------------------------------"
echo >&2 "[INFO] Installing or upgrading pydio in $(pwd)"
echo >&2 "[INFO] ---------------------------------------------------"
echo >&2 "[INFO] Removing old installation"
find -maxdepth 1 ! -regex '^\./data.*$' ! -regex '^\.$' -exec rm -rvf {} +
echo >&2 "[INFO] Extracting new installation"
tar cvf - --one-file-system -C /usr/src/pydio . | tar xvf -
echo >&2 "[INFO] Fixing rights"
chown -Rfv nginx:nginx .
echo >&2 "[INFO] Complete! PhotoShow has been successfully installed / upgraded to $(pwd)"

# Exec main command
exec "$@"
