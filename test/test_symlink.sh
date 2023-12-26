#!/usr/bin/env bash

set -uo pipefail;

####################################
# Ensure we can execute standalone #
####################################

function early_death() {
  echo "[FATAL] ${0}: ${1}" >&2;
  exit 1;
};

if [ -z "${TOFUENV_ROOT:-""}" ]; then
  # http://stackoverflow.com/questions/1055671/how-can-i-get-the-behavior-of-gnus-readlink-f-on-a-mac
  readlink_f() {
    local target_file="${1}";
    local file_name;

    while [ "${target_file}" != "" ]; do
      cd "$(dirname ${target_file})" || early_death "Failed to 'cd \$(dirname ${target_file})' while trying to determine TOFUENV_ROOT";
      file_name="$(basename "${target_file}")" || early_death "Failed to 'basename \"${target_file}\"' while trying to determine TOFUENV_ROOT";
      target_file="$(readlink "${file_name}")";
    done;

    echo "$(pwd -P)/${file_name}";
  };

  TOFUENV_ROOT="$(cd "$(dirname "$(readlink_f "${0}")")/.." && pwd)";
  [ -n ${TOFUENV_ROOT} ] || early_death "Failed to 'cd \"\$(dirname \"\$(readlink_f \"${0}\")\")/..\" && pwd' while trying to determine TOFUENV_ROOT";
else
  TOFUENV_ROOT="${TOFUENV_ROOT%/}";
fi;
export TOFUENV_ROOT;

if [ -n "${TOFUENV_HELPERS:-""}" ]; then
  log 'debug' 'TOFUENV_HELPERS is set, not sourcing helpers again';
else
  [ "${TOFUENV_DEBUG:-0}" -gt 0 ] && echo "[DEBUG] Sourcing helpers from ${TOFUENV_ROOT}/lib/helpers.sh";
  if source "${TOFUENV_ROOT}/lib/helpers.sh"; then
    log 'debug' 'Helpers sourced successfully';
  else
    early_death "Failed to source helpers from ${TOFUENV_ROOT}/lib/helpers.sh";
  fi;
fi;

#####################
# Begin Script Body #
#####################

declare -a errors=();

log 'info' '### Testing symlink functionality';

TOFUENV_BIN_DIR='/tmp/tfenv-test';
log 'info' "## Creating/clearing ${TOFUENV_BIN_DIR}"
rm -rf "${TOFUENV_BIN_DIR}" && mkdir "${TOFUENV_BIN_DIR}";
log 'info' "## Symlinking ${PWD}/bin/* into ${TOFUENV_BIN_DIR}";
ln -s "${PWD}"/bin/* "${TOFUENV_BIN_DIR}";

cleanup || log 'error' 'Cleanup failed?!';

log 'info' '## Installing 1.6.1';
${TOFUENV_BIN_DIR}/tfenv install 1.6.1 || error_and_proceed 'Install failed';

log 'info' '## Using 1.6.1';
${TOFUENV_BIN_DIR}/tfenv use 1.6.1 || error_and_proceed 'Use failed';

log 'info' '## Check-Version for 1.6.1';
check_active_version 1.6.1 || error_and_proceed 'Version check failed';

if [ "${#errors[@]}" -gt 0 ]; then
  log 'warn' '===== The following symlink tests failed =====';
  for error in "${errors[@]}"; do
    log 'warn' "\t${error}";
  done;
  log 'error' 'Symlink test failure(s)';
  exit 1;
else
  log 'info' 'All symlink tests passed.';
fi;

exit 0;
