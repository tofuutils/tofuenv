#!/usr/bin/env bash

set -uo pipefail;

function tofuenv-exec() {
  for _arg in ${@:1}; do
    if [[ "${_arg}" == -chdir=* ]]; then
      log 'debug' "Found -chdir arg. Setting TOFUENV_DIR to: ${_arg#-chdir=}";
      export TOFUENV_DIR="${PWD}/${_arg#-chdir=}";
    fi;
  done;

  log 'debug' 'Getting version from tofuenv-version-name';
  TOFUENV_VERSION="$(tofuenv-version-name)" \
    && log 'debug' "TOFUENV_VERSION is ${TOFUENV_VERSION}" \
    || {
      # Errors will be logged from tofuenv-version name,
      # we don't need to trouble STDERR with repeat information here
      log 'debug' 'Failed to get version from tofuenv-version-name';
      return 1;
    };
  export TOFUENV_VERSION;

  if [ ! -d "${TOFUENV_CONFIG_DIR}/versions/${TOFUENV_VERSION}" ]; then
  if [ "${TOFUENV_AUTO_INSTALL:-true}" == "true" ]; then
    if [ -z "${TOFUENV_TERRAFORM_VERSION:-""}" ]; then
      TOFUENV_VERSION_SOURCE="$(tofuenv-version-file)";
    else
      TOFUENV_VERSION_SOURCE='TOFUENV_TERRAFORM_VERSION';
    fi;
      log 'info' "version '${TOFUENV_VERSION}' is not installed (set by ${TOFUENV_VERSION_SOURCE}). Installing now as TOFUENV_AUTO_INSTALL==true";
      tofuenv-install;
    else
      log 'error' "version '${TOFUENV_VERSION}' was requested, but not installed and TOFUENV_AUTO_INSTALL is not 'true'";
    fi;
  fi;

  TF_BIN_PATH="${TOFUENV_CONFIG_DIR}/versions/${TOFUENV_VERSION}/tofu";
  export PATH="${TF_BIN_PATH}:${PATH}";
  log 'debug' "TF_BIN_PATH added to PATH: ${TF_BIN_PATH}";
  log 'debug' "Executing: ${TF_BIN_PATH} $@";

  exec "${TF_BIN_PATH}" "$@" \
  || log 'error' "Failed to execute: ${TF_BIN_PATH} $*";

  return 0;
};
export -f tofuenv-exec;
