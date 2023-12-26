#!/usr/bin/env bash

set -uo pipefail;

function find_local_version_file() {
  log 'debug' "Looking for a version file in ${1}";

  local root="${1}";

  while ! [[ "${root}" =~ ^//[^/]*$ ]]; do

    if [ -e "${root}/.opentofu-version" ]; then
      log 'debug' "Found at ${root}/.opentofu-version";
      echo "${root}/.opentofu-version";
      return 0;
    else
      log 'debug' "Not found at ${root}/.opentofu-version";
    fi;

    [ -n "${root}" ] || break;
    root="${root%/*}";

  done;

  log 'debug' "No version file found in ${1}";
  return 1;
};
export -f find_local_version_file;

function tofuenv-version-file() {
  if ! find_local_version_file "${TOFUENV_DIR:-${PWD}}"; then
    if ! find_local_version_file "${HOME:-/}"; then
      log 'debug' "No version file found in search paths. Defaulting to TOFUENV_CONFIG_DIR: ${TOFUENV_CONFIG_DIR}/version";
      echo "${TOFUENV_CONFIG_DIR}/version";
    fi;
  fi;
};
export -f tofuenv-version-file;
