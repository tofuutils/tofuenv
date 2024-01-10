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

test_install_and_use() {
  # Takes a static version and the optional keyword to install it with
  local k="${2-""}";
  local v="${1}";
  tofuenv install "${k}" || return 1;
  check_installed_version "${v}" || return 1;
  tofuenv use "${k}" || return 1;
  check_active_version "${v}" || return 1;
  return 0;
};

test_install_and_use_with_env() {
  # Takes a static version and the optional keyword to install it with
  local k="${2-""}";
  local v="${1}";
  TOFUENV_TOFU_VERSION="${k}" tofuenv install || return 1;
  check_installed_version "${v}" || return 1;
  TOFUENV_TOFU_VERSION="${k}" tofuenv use || return 1;
  TOFUENV_TOFU_VERSION="${k}" check_active_version "${v}" || return 1;
  return 0;
};

test_install_and_use_overridden() {
  # Takes a static version and the optional keyword to install it with
  local k="${2-""}";
  local v="${1}";
  tofuenv install "${k}" || return 1;
  check_installed_version "${v}" || return 1;
  tofuenv use "${k}" || return 1;
  check_default_version "${v}" || return 1;
  return 0;
};

declare -a errors=();

log 'info' '### Test Suite: Install and Use';

tests__desc=(
#  'latest version'
  'latest possibly-unstable version'
  'latest alpha'
  'latest beta'
  'latest rc'
  'latest possibly-unstable version from 1.6'
  'latest version matching regex'
  'specific version'
  'specific version with v prefix'
);

tests__kv=(
#  "$(tofuenv list-remote | grep -e "^[0-9]\+\.[0-9]\+\.[0-9]\+$" | head -n 1),latest"
  "$(tofuenv list-remote | head -n 1),latest:"
  "$(tofuenv list-remote | grep 'alpha' | head -n 1),latest:alpha"
  "$(tofuenv list-remote | grep 'beta' | head -n 1),latest:beta"
  "$(tofuenv list-remote | grep 'rc' | head -n 1),latest:rc"
  "$(tofuenv list-remote | grep '^1\.6\.' | head -n 1),latest:^1.6."
  '1.6.0,latest:^1\.6'
  '1.6.0-alpha5'
  '1.6.0-rc1,v1.6.0-rc1'
);

log 'info' "Kernel under test: $(uname -s)";

tests_count=${#tests__desc[@]};

declare desc kv k v test_num;

for ((test_iter=0; test_iter<${tests_count}; ++test_iter )) ; do
  cleanup || log 'error' 'Cleanup failed?!';
  test_num=$((test_iter + 1)); 
  desc=${tests__desc[${test_iter}]};
  kv="${tests__kv[${test_iter}]}";
  v="${kv%,*}";
  k="${kv##*,}";
  log 'info' "## Param Test ${test_num}/${tests_count}: ${desc} ( ${k} / ${v} )";
  test_install_and_use "${v}" "${k}" \
    && log info "## Param Test ${test_num}/${tests_count}: ${desc} ( ${k} / ${v} ) succeeded" \
    || error_and_proceed "## Param Test ${test_num}/${tests_count}: ${desc} ( ${k} / ${v} ) failed";
done;

for ((test_iter=0; test_iter<${tests_count}; ++test_iter )) ; do
  cleanup || log 'error' 'Cleanup failed?!';
  test_num=$((test_iter + 1)); 
  desc=${tests__desc[${test_iter}]};
  kv="${tests__kv[${test_iter}]}";
  v="${kv%,*}";
  k="${kv##*,}";
  log 'info' "## ./.opentofu-version Test ${test_num}/${tests_count}: ${desc} ( ${k} / ${v} )";
  log 'info' "Writing ${k} to ./.opentofu-version";
  echo "${k}" > ./.opentofu-version;
  test_install_and_use "${v}" \
    && log info "## ./.opentofu-version Test ${test_num}/${tests_count}: ${desc} ( ${k} / ${v} ) succeeded" \
    || error_and_proceed "## ./.opentofu-version Test ${test_num}/${tests_count}: ${desc} ( ${k} / ${v} ) failed";
done;

for ((test_iter=0; test_iter<${tests_count}; ++test_iter )) ; do
  cleanup || log 'error' 'Cleanup failed?!';
  test_num=$((test_iter + 1)); 
  desc=${tests__desc[${test_iter}]};
  kv="${tests__kv[${test_iter}]}";
  v="${kv%,*}";
  k="${kv##*,}";
  log 'info' "## TOFUENV_TOFU_VERSION Test ${test_num}/${tests_count}: ${desc} ( ${k} / ${v} )";
  log 'info' "Writing 0.0.0 to ./.opentofu-version";
  echo "0.0.0" > ./.opentofu-version;
  test_install_and_use_with_env "${v}" "${k}" \
    && log info "## TOFUENV_TOFU_VERSION Test ${test_num}/${tests_count}: ${desc} ( ${k} / ${v} ) succeeded" \
    || error_and_proceed "## TOFUENV_TOFU_VERSION Test ${test_num}/${tests_count}: ${desc} ( ${k} / ${v} ) failed";
done;

cleanup || log 'error' 'Cleanup failed?!';
log 'info' '## ${HOME}/.opentofu-version Test Preparation';

log 'info' 'Install invalid specific version';
cleanup || log 'error' 'Cleanup failed?!';

neg_tests__desc=(
  'specific version'
  'latest:word'
);

neg_tests__kv=(
  '9.9.9'
  'latest:word'
);

neg_tests_count=${#neg_tests__desc[@]};

for ((test_iter=0; test_iter<${neg_tests_count}; ++test_iter )) ; do
  cleanup || log 'error' 'Cleanup failed?!';
  test_num=$((test_iter + 1));
  desc=${neg_tests__desc[${test_iter}]}
  k="${neg_tests__kv[${test_iter}]}";
  v="${k%%\:*} ";
  regex="${k##*\:}";
  if [[ "${v}" =~ ${regex} ]]; then v=''; fi
  expected_error_message="No ${v}versions matching '${regex}' found in remote";
  log 'info' "##  Invalid Version Test ${test_num}/${neg_tests_count}: ${desc} ( ${k} )";
  [ -z "$(tofuenv install "${k}" 2>&1 | grep "${expected_error_message}")" ] \
    && error_and_proceed "Installing invalid version ${k}";
done;

if [ "${#errors[@]}" -gt 0 ]; then
  log 'warn' '===== The following install_and_use tests failed =====';
  for error in "${errors[@]}"; do
    log 'warn' "\t${error}";
  done
  log 'error' 'Test failure(s): install_and_use';
else
  log 'info' 'All install_and_use tests passed';
fi;

exit 0;
