#!/usr/bin/env bash

set -uo pipefail;

function tofuenv-version-name() {
  if [[ -z "${TOFUENV_TOFU_VERSION:-""}" ]]; then
    log 'debug' 'We are not hardcoded by a TOFUENV_TOFU_VERSION environment variable';

    TOFUENV_VERSION_FILE="$(tofuenv-version-file)" \
      && log 'debug' "TOFUENV_VERSION_FILE retrieved from tofuenv-version-file: ${TOFUENV_VERSION_FILE}" \
      || log 'error' 'Failed to retrieve TOFUENV_VERSION_FILE from tofuenv-version-file';

    TOFUENV_VERSION="$(cat "${TOFUENV_VERSION_FILE}" || true)" \
      && log 'debug' "TOFUENV_VERSION specified in TOFUENV_VERSION_FILE: ${TOFUENV_VERSION}";

    TOFUENV_VERSION_SOURCE="${TOFUENV_VERSION_FILE}";

  else
    TOFUENV_VERSION="${TOFUENV_TOFU_VERSION}" \
      && log 'debug' "TOFUENV_VERSION specified in TOFUENV_TOFU_VERSION environment variable: ${TOFUENV_VERSION}";

    TOFUENV_VERSION_SOURCE='TOFUENV_TOFU_VERSION';
  fi;

  local auto_install="${TOFUENV_AUTO_INSTALL:-true}";

  if [[ "${TOFUENV_VERSION}" == "min-required" ]]; then
    log 'debug' 'TOFUENV_VERSION uses min-required keyword, looking for a required_version in the code';

    local potential_min_required="$(tofuenv-min-required)";
    if [[ -n "${potential_min_required}" ]]; then
      log 'debug' "'min-required' converted to '${potential_min_required}'";
      TOFUENV_VERSION="${potential_min_required}" \
      TOFUENV_VERSION_SOURCE='opentofu{required_version}';
    else
      log 'error' 'Specifically asked for min-required via terraform{required_version}, but none found';
    fi;
  fi;

  if [[ "${TOFUENV_VERSION}" =~ ^latest.*$ ]]; then
    log 'debug' "TOFUENV_VERSION uses 'latest' keyword: ${TOFUENV_VERSION}";

    if [[ "${TOFUENV_VERSION}" == latest-allowed ]]; then
        TOFUENV_VERSION="$(tofuenv-resolve-version)";
        log 'debug' "Resolved latest-allowed to: ${TOFUENV_VERSION}";
    fi;

    if [[ "${TOFUENV_VERSION}" =~ ^latest\:.*$ ]]; then
      regex="${TOFUENV_VERSION##*\:}";
      log 'debug' "'latest' keyword uses regex: ${regex}";
    else
      regex="^[0-9]\+\.[0-9]\+\.[0-9]\+$";
      log 'debug' "Version uses latest keyword alone. Forcing regex to match stable versions only: ${regex}";
    fi;

    declare local_version='';
    if [[ -d "${TOFUENV_CONFIG_DIR}/versions" ]]; then
      local_version="$(\find "${TOFUENV_CONFIG_DIR}/versions/" -type d -exec basename {} \; \
        | tail -n +2 \
        | sort -t'.' -k 1nr,1 -k 2nr,2 -k 3nr,3 \
        | grep -e "${regex}" \
        | head -n 1)";

      log 'debug' "Resolved ${TOFUENV_VERSION} to locally installed version: ${local_version}";
    elif [[ "${auto_install}" != "true" ]]; then
      log 'error' 'No versions of tofu installed and TOFUENV_AUTO_INSTALL is not true. Please install a version of tofu before it can be selected as latest';
    fi;

    if [[ "${auto_install}" == "true" ]]; then
      log 'debug' "Using latest keyword and auto_install means the current version is whatever is latest in the remote. Trying to find the remote version using the regex: ${regex}";
      remote_version="$(tofuenv-list-remote | grep -e "${regex}" | head -n 1)";
      if [[ -n "${remote_version}" ]]; then
          if [[ "${local_version}" != "${remote_version}" ]]; then
            log 'debug' "The installed version '${local_version}' does not much the remote version '${remote_version}'";
            TOFUENV_VERSION="${remote_version}";
          else
            TOFUENV_VERSION="${local_version}";
          fi;
      else
        log 'error' "No versions matching '${requested}' found in remote";
      fi;
    else
      if [[ -n "${local_version}" ]]; then
        TOFUENV_VERSION="${local_version}";
      else
        log 'error' "No installed versions of tofu matched '${TOFUENV_VERSION}'";
      fi;
    fi;
  else
    log 'debug' 'TOFUENV_VERSION does not use "latest" keyword';

    # Accept a v-prefixed version, but strip the v.
    if [[ "${TOFUENV_VERSION}" =~ ^v.*$ ]]; then
      log 'debug' "Version Requested is prefixed with a v. Stripping the v.";
      TOFUENV_VERSION="${TOFUENV_VERSION#v*}";
    fi;
  fi;

  if [[ -z "${TOFUENV_VERSION}" ]]; then
    log 'error' "Version could not be resolved (set by ${TOFUENV_VERSION_SOURCE} or tofuenv use <version>)";
  fi;

  if [[ "${TOFUENV_VERSION}" == min-required ]]; then
    TOFUENV_VERSION="$(tofuenv-min-required)";
  fi;

  if [[ ! -d "${TOFUENV_CONFIG_DIR}/versions/${TOFUENV_VERSION}" ]]; then
    log 'debug' "version '${TOFUENV_VERSION}' is not installed (set by ${TOFUENV_VERSION_SOURCE})";
  fi;

  echo "${TOFUENV_VERSION}";
};
export -f tofuenv-version-name;

