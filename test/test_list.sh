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

log 'info' '### List local versions';
cleanup || log 'error' "Cleanup failed?!";

for v in 0.7.2 0.7.13 0.9.1 0.9.2 v0.9.11 0.14.6; do
  log 'info' "## Installing version ${v} to construct list";
  tofuenv install "${v}" \
    && log 'debug' "Install of version ${v} succeeded" \
    || error_and_proceed "Install of version ${v} failed";
done;

log 'info' '## Ensuring tofuenv list success with no default set';
tofuenv list \
  && log 'debug' "List succeeded with no default set" \
  || error_and_proceed "List failed with no default set";

tofuenv use 0.14.6;

log 'info' '## Comparing "tofuenv list" with default set';
result="$(tofuenv list)";
expected="$(cat << EOS
* 0.14.6 (set by $(tofuenv version-file))
  0.9.11
  0.9.2
  0.9.1
  0.7.13
  0.7.2
EOS
)";

[ "${expected}" == "${result}" ] \
  && log 'info' 'List matches expectation.' \
  || error_and_proceed "List mismatch.\nExpected:\n${expected}\nGot:\n${result}";

if [ "${#errors[@]}" -gt 0 ]; then
  log 'warn' "===== The following list tests failed =====";
  for error in "${errors[@]}"; do
    log 'warn' "\t${error}";
  done;
  log 'error' 'List test failure(s)';
else
  log 'info' 'All list tests passed.';
fi;

exit 0;
