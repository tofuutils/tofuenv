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
  [ "${TOFUENV_DEBUG:-0}" -gt 0 ] && echo "[DEBUG] Sourcing helpers from ${TOFUENV_ROOT}/lib/tofuenv-helpers.sh";
  if source "${TOFUENV_ROOT}/lib/tofuenv-helpers.sh"; then
    log 'debug' 'Helpers sourced successfully';
  else
    early_death "Failed to source helpers from ${TOFUENV_ROOT}/lib/tofuenv-helpers.sh";
  fi;
fi;

#####################
# Begin Script Body #
#####################

declare -a errors=();

cleanup || log 'error' 'Cleanup failed?!';


log 'info' '### Install latest-allowed normal version (#.#.#)';

echo "terraform {
  required_version = \"~> 1.6.0\"
}" > latest_allowed.tf;

(
  tofuenv install latest-allowed;
  tofuenv use latest-allowed;
  check_active_version 1.6.1;
) || error_and_proceed 'Latest allowed version does not match';

cleanup || log 'error' 'Cleanup failed?!';


log 'info' '### Install latest-allowed tagged version (#.#.#-tag#)'

echo "terraform {
    required_version = \"<=1.6.0-rc1\"
}" > latest_allowed.tf;

(
  tofuenv install latest-allowed;
  tofuenv use latest-allowed;
  check_active_version 1.6.0-rc1;
) || error_and_proceed 'Latest allowed tagged-version does not match';

cleanup || log 'error' 'Cleanup failed?!';


log 'info' '### Install latest-allowed incomplete version (#.#.<missing>)'

echo "terraform {
  required_version = \"~> 1.6\"
}" >> latest_allowed.tf;

(
  tofuenv install latest-allowed;
  tofuenv use latest-allowed;
  check_active_version 1.6.1;
) || error_and_proceed 'Latest allowed incomplete-version does not match';

cleanup || log 'error' 'Cleanup failed?!';


log 'info' '### Install latest-allowed with TOFUENV_AUTO_INSTALL';

echo "terraform {
  required_version = \"~> 1.6.0-rc1\"
}" >> latest_allowed.tf;
echo 'latest-allowed' > .opentofu-version;

(
  TOFUENV_AUTO_INSTALL=true tofu version;
  check_active_version 1.6.1;
) || error_and_proceed 'Latest allowed auto-installed version does not match';

cleanup || log 'error' 'Cleanup failed?!';


log 'info' '### Install latest-allowed with TOFUENV_AUTO_INSTALL & -chdir';

mkdir -p chdir-dir
echo "terraform {
  required_version = \"~> 1.6.0-rc1\"
}" >> chdir-dir/latest_allowed.tf;
echo 'latest-allowed' > chdir-dir/.opentofu-version

(
  TOFUENV_AUTO_INSTALL=true tofu -chdir=chdir-dir version;
  check_active_version 1.6.1 chdir-dir;
) || error_and_proceed 'Latest allowed version from -chdir does not match';

cleanup || log 'error' 'Cleanup failed?!';

if [ "${#errors[@]}" -gt 0 ]; then
  log 'warn' '===== The following use_latestallowed tests failed =====';
  for error in "${errors[@]}"; do
    log 'warn' "\t${error}";
  done;
  log 'error' 'use_latestallowed test failure(s)';
else
  log 'info' 'All use_latestallowed tests passed.';
fi;

exit 0;
