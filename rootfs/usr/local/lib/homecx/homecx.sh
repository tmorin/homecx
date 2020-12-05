#!/usr/bin/env bash

set -exo pipefail

function init() {
    local destination="/data/cfg"
    local repository="${HOMECX_REPOSITORY}"
    local branch="${HOMECX_BRANCH:-master}"

    while [[ $# -gt 0 ]]; do case $1 in
      -r | --repository )
        shift; repository=$1
        ;;
      -b | --branch )
        shift; branch=$1
        ;;
      -d | --destination )
        shift; destination=$1
        ;;
      -h | --help )
        echo "Usage: $0 init <repository> [-r repository, -b branch, -d destination]"; exit 0
        ;;
    esac; shift; done

    if [[ -z ${repository} ]]; then
        echo "The repository is required"; exit 1
    fi

    echo "Initialize [${destination}] with [${repository}#${branch}]"
    rm -Rf ${destination}
    git clone ${repository} ${destination}
    cd "${destination}"
    if [[ ! $(git rev-parse --abbrev-ref HEAD) == "${branch}" ]]; then
        git checkout -f "${branch}"
    fi
}

case "$1" in
  init)
    shift; init $@
    ;;
  *)
    echo "Usage: $0 {init} [options] [-h]"
    ;;
esac
