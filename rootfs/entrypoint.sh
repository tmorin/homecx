#!/usr/bin/env bash

set -exo pipefail

mkdir -p /data/.ssh
chmod 700 /data/.ssh
chmod 600 /data/.ssh/*

if [[ -n "${HOMECX_REPOSITORY}" ]]; then
    if [[ ! -d "/data/cfg/.git" ]]; then
        homecx init -r "${HOMECX_REPOSITORY}"
    fi
fi

exec /usr/bin/supervisord -c /data/supervisord.conf
