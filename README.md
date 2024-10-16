<!-- BADGES -->
[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/8816/badge)](https://www.bestpractices.dev/projects/8816) [![Github release](https://img.shields.io/github/v/release/tofuutils/tofuenv)](https://github.com/tofuutils/tofuenv/releases) [![Contributors](https://img.shields.io/github/contributors/tofuutils/tofuenv)](https://github.com/tofuutils/tofuenv/graphs/contributors) ![maintenance status](https://img.shields.io/maintenance/yes/2024.svg)

<h1 align="center">tofuenv</h1>

<h3 align="center"> <a href="https://opentofu.org/">OpenTofu</a> version manager inspired by <a href="https://github.com/tfutils/tfenv">tfenv</a> </h3>

### Table of Content
<div align="center">
  <a href="#important-notice">Important Notice</a> •
  <a href="#supported-os">Supported OS</a> •
  <a href="#installation">Installation</a> •
  <a href="#install-dependencies">Install dependencies</a> •
  <a href="#usage">Usage</a> •
  <a href="#environment-variables">Environment Variables</a> •
  <a href="#upgrading">Upgrading</a> •
  <a href="#uninstalling">Uninstalling</a> •
  <a href="#contributing">Contributing</a> •
  <a href="#community">Community</a> •
  <a href="#authors">Authors</a> •
  <a href="#license">License</a>
</div>

### Important Notice
Many people have asked about Terraform support, and we are finally ready to announce a successor for **tfenv** and **tofuenv**: <a href="https://github.com/tofuutils/tenv">tenv </a> 🚀 written in Golang. tenv is able to handle Terraform binaries as well as OpenTofu binaries. 🎉

Please contribute to <a href="https://github.com/tofuutils/tenv">tenv </a> and award us stars⭐.

## Supported OS

Currently, **tofuenv** supports the following operating systems:

<details>
  <summary><b>macOS</b></summary>
  <ul>
    <li>64bit</li>
    <li>Arm (Apple Silicon)</li>
  </ul>
</details>
<details>
  <summary><b>Linux</b></summary>
  <ul>
    <li>64bit</li>
    <li>Arm</li>
  </ul>
</details>
<details>
  <summary><b>Windows</b> (Only tested in git-bash - currently presumed failing due to symlink issues in git-bash)</summary> 
  <ul>
    <li>64bit</li>
  </ul>
</details>


## Installation

### Automatic

<details><summary><b>Install via Homebrew</b></summary>

  ```console
    brew tap tofuutils/tap
    brew install tofuenv
  ```  
</details>

<details><summary><b>Install via Arch User Repository (AUR)</b></summary>

```console
git clone https://aur.archlinux.org/tofuenv.git
cd tofuenv
makepkg -si
```
</details>


<details><summary><b>Install via Arch User Repository (AUR) via yay</b></summary>
   
```console
yay --sync tofuenv
```
</details>

### Manual
<details><summary><b>Linux and MacOS</b></summary>
  
1. Check out tofuenv into any path (here is `${HOME}/.tofuenv`)

```console
git clone --depth=1 https://github.com/tofuutils/tofuenv.git ~/.tofuenv
```

2. Add `~/.tofuenv/bin` to your `$PATH` any way you like

bash:
```console
echo 'export PATH="$HOME/.tofuenv/bin:$PATH"' >> ~/.bash_profile
```
zsh:
```console
$ echo 'export PATH="$HOME/.tofuenv/bin:$PATH"' >> ~/.zprofile
```

For WSL users:
```bash
echo 'export PATH=$PATH:$HOME/.tofuenv/bin' >> ~/.bashrc
```

  OR you can make symlinks for `tofuenv/bin/*` scripts into a path that is already added to your `$PATH` (e.g. `/usr/local/bin`) `OSX/Linux Only!`

```console
ln -s ~/.tofuenv/bin/* /usr/local/bin
```

  On Ubuntu/Debian touching `/usr/local/bin` might require sudo access, but you can create `${HOME}/bin` or `${HOME}/.local/bin` and on next login it will get added to the session `$PATH`
  or by running `. ${HOME}/.profile` it will get added to the current shell session's `$PATH`.

```console
mkdir -p ~/.local/bin/
. ~/.profile
ln -s ~/.tofuenv/bin/* ~/.local/bin
which tofuenv
```

</details>

<details><summary><b>Windows</b></summary>
  
1. Install Git-Bash
```console
winget install --id Git.Git -e --source winget
```

2. Launch git-bash environment, execute (keep the quotes):
```console
"C:\Program Files\Git\bin\sh.exe"
```

2. Check out tofuenv into any path (here is ${HOME}/.tofuenv)
```console
git clone --depth=1 https://github.com/tofuutils/tofuenv.git ~/.tofuenv
```

2. Add ~/.tofuenv/bin to your $PATH
```console
echo 'export PATH=$PATH:$HOME/.tofuenv/bin' >> ~/.bashrc
```

4. Relaunch git-bash environment for the changes to be applied (you can do it via ```exit``` command).

5. Verify installation by executing:
```console
which tofuenv
```

</details>

## Install dependencies

Install **jq** (required) and **GnuPG** (optional, in case you want to enable GPG verification during OpenTofu installation)

<details><summary><b>MacOs</b></summary>
  
```console
brew install jq gnupg grep
```
</details>

<details><summary><b>Linux</b></summary>
  
```console
sudo apt-get update -y
sudo apt-get install -y jq gnupg
```
</details>

<details><summary><b>Windows</b> (git-bash)</summary>
Install jq package into git-bash default installation folder:
  
```console
curl -L -o /usr/bin/jq.exe https://github.com/jqlang/jq/releases/latest/download/jq-win64.exe
```
</details>

## Usage

### tofuenv install [version]

Install a specific version of OpenTofu.

If no parameter is passed, the version to use is resolved automatically via [TOFUENV_TOFU_VERSION environment variable](#TOFUENV_TOFU_VERSION) or [.opentofu-version files](#opentofu-version-file), in that order of precedence, i.e. TOFUENV_TOFU_VERSION, then .opentofu-version. The default is `latest` if none are found.

If a parameter is passed, available options:

- `x.y.z` [Semver 2.0.0](https://semver.org/) string specifying the exact version to install
- `latest:<regex>` is a syntax to install latest version matching regex (used by grep -e)
- `latest-allowed` is a syntax to scan your OpenTofu files to detect which version is maximally allowed.
- `min-required` is a syntax to scan your OpenTofu files to detect which version is minimally required.

Options will be available after first stable release:

- `latest` is a syntax to install latest stable version

See [required_version](https://developer.hashicorp.com/terraform/language/settings) docs. Also [see min-required & latest-allowed](#min-required) section below.

```console
$ tofuenv install 1.6.0-rc1 
$ tofuenv install latest:^1.6
$ tofuenv install latest-allowed
$ tofuenv install min-required
```

If `shasum` is present in the path, tofuenv will verify the download against OpenTofu published sha256 hash.

You can opt-in to using GnuPG tools for GPG signature verification:


```console
echo 'trust-tofuenv: yes' > ${TOFUENV_INSTALL_DIR}/use-gpgv
tofuenv install
```
Where `TOFUENV_INSTALL_DIR` is for example, `~/tofuenv` or `/opt/homebrew/Cellar/tofuenv/<version>`

The `trust-tofuenv` directive means that verification uses a copy of the
OpenTofu GPG key found in the tofuenv repository. Skipping that directive
means that the OpenTofu key must be in the existing default trusted keys.
Use the file `${TOFUENV_INSTALL_DIR}/use-gnupg` to instead invoke the full `gpg` tool and
see web-of-trust status; beware that a lack of trust path will not cause a
validation failure.
Default `gpg/gpgv` command can be overridden by adding `binary` directive to `use-gpgv`/`use-gnupg` file, ex.:
```console
echo 'binary: gpgv --keyring ./path/to/gpg/opentofu.gpg' > ${TOFUENV_INSTALL_DIR}/use-gpgv
tofuenv install
```

For now keybase tool GPG signature verification is not supported by OpenTofu. This verification mechanism will be added after support is added by OpenTofu.

#### .opentofu-version

If you use a [.opentofu-version](#opentofu-version-file) file, `tofuenv install` (no argument) will install the version written in it.

<a name="min-required"></a>
#### min-required & latest-allowed

Please note that we don't do semantic version range parsing but use first ever found version as the candidate for minimally required one. It is up to the user to keep the definition reasonable. I.e.

```terraform
// this will detect 0.12.3
terraform {
  required_version  = "<0.12.3, >= 0.10.0"
}
```

```terraform
// this will detect 0.10.8 (the latest 0.10.x release)
terraform {
  required_version  = "~> 0.10.0, <0.12.3"
}
```

## Environment Variables

### TOFUENV

<details id="TOFUENV_GITHUB_TOKEN"><summary><b>TOFUENV_GITHUB_TOKEN</b></summary><br>
  
String (Default: "")

Specify GitHub token. Because of OpenTofu binares placed in the GitHub you may encounter with rate limit problem.
Using a personal access token dramatically increases rate limit.
[GitHub Rate limits for the REST API](https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api)
</details>

<details id="TOFUENV_ARCH"><summary><b>TOFUENV_ARCH</b></summary><br>
  
String (Default: `amd64`)

Specify architecture. Architecture other than the default amd64 can be specified with the `TOFUENV_ARCH` environment variable

Note: Default changes to `arm64` for versions that have arm64 builds available when `$(uname -m)` matches `aarch64* | arm64*`

```console
TOFUENV_ARCH=arm64 tofuenv install 0.7.9
```
</details>

<details id="TOFUENV_AUTO_INSTALL"><summary><b>TOFUENV_AUTO_INSTALL</b></summary><br>
  
String (Default: true)

Should tofuenv automatically install tofu if the version specified by defaults or a .opentofu-version file is not currently installed.

Example: if auto installation is enabled, the version will be installed.
```console
TOFUENV_AUTO_INSTALL=true tofu use <version that is not yet installed>
```

Example: use 1.6.0-beta3 version that is not installed, and auto installation is disabled.
```console
$ TOFUENV_AUTO_INSTALL=false tofuenv use 1.6.0-beta3
No installed versions of opentofu matched '^1.6.0-beta3$'. TOFUENV_AUTO_INSTALL is set to false, so exiting.
```
</details>

<details id="TOFUENV_CURL_OUTPUT"><summary><b>TOFUENV_CURL_OUTPUT</b></summary><br>

Integer (Default: 2)

Set the mechanism used for displaying download progress when downloading tofu versions from the remote server.

* 2: v1 Behaviour: Pass `-#` to curl
* 1: Use curl default
* 0: Pass `-s` to curl
</details>

<details id="TOFUENV_DEBUG"><summary><b>TOFUENV_DEBUG</b></summary><br>

Integer (Default: 0)

Set the debug level for tofuenv.

* 0: No debug output
* 1: Simple debug output
* 2: Extended debug output, with source file names and interactive debug shells on error
* 3: Debug level 2 + Bash execution tracing
</details>

<details id="TOFUENV_REMOTE"><summary><b>TOFUENV_REMOTE</b></summary><br>

String (Default: https://github.com/opentofu/opentofu/releases)

To install from a remote other than the default

```console
TOFUENV_REMOTE=https://example.jfrog.io/artifactory/opentofu
```
</details>

<details id="TOFUENV_REVERSE_REMOTE"><summary><b>TOFUENV_REVERSE_REMOTE</b></summary><br>

Integer (Default: 0)

When using a custom remote, such as Artifactory, instead of the OpenTofu servers,
the list of tofu versions returned by the curl of the remote directory may be inverted.
In this case the `latest` functionality will not work as expected because it expects the
versions to be listed in order of release date from newest to oldest. If your remote
is instead providing a list that is oldes-first, set `TOFUENV_REVERSE_REMOTE=1` and
functionality will be restored.

```console
TOFUENV_REVERSE_REMOTE=1 tofuenv list-remote
```
</details>

<details id="TOFUENV_SKIP_LIST_REMOTE"><summary><b>TOFUENV_SKIP_LIST_REMOTE</b></summary><br>

Integer (Default: 0)

Skip list remote versions in installation step. Can be useful for a custom remote, such as Artifactory.

Disabled: 0
Enable: any other value

```console
TOFUENV_SKIP_LIST_REMOTE=1 tofuenv install 1.6.0-rc1
```
</details>

<details id="TOFUENV_CONFIG_DIR"><summary><b>TOFUENV_CONFIG_DIR</b></summary><br>

Path (Default: `$TOFUENV_ROOT`)

The path to a directory where the local tofu versions and configuration files exist.

```console
TOFUENV_CONFIG_DIR="$XDG_CONFIG_HOME/tofuenv"
```
</details>

<details id="TOFUENV_TOFU_VERSION"><summary><b>TOFUENV_TOFU_VERSION</b></summary><br>

String (Default: "")

If not empty string, this variable overrides OpenTofu version, specified in [.opentofu-version files](#opentofu-version-file).
`latest` and `latest:<regex>` syntax are also supported.
[`tofuenv install`](#tofuenv-install-version) and [`tofuenv use`](#tofuenv-use-version) command also respects this variable.

e.g.

```console
TOFUENV_TOFU_VERSION=latest:^0.11. tofu --version
```
</details>

<details id="TOFUENV_NETRC_PATH"><summary><b>TOFUENV_NETRC_PATH</b></summary><br>

String (Default: "")

If not empty string, this variable specifies the credentials file used to access the remote location (useful if used in conjunction with TOFUENV_REMOTE).

e.g.

```console
TOFUENV_NETRC_PATH="$PWD/.netrc.tofuenv"
```
</details>

---

### Bashlog Logging Library

<details id="BASHLOG_COLOURS"><summary><b>BASHLOG_COLOURS</b></summary><br>

Integer (Default: 1)

To disable colouring of console output, set to 0.
</details>

<details id="BASHLOG_DATE_FORMAT"><summary><b>BASHLOG_DATE_FORMAT</b></summary><br>

String (Default: +%F %T)

The display format for the date as passed to the `date` binary to generate a datestamp used as a prefix to:

* `FILE` type log file lines.
* Each console output line when `BASHLOG_EXTRA=1`
</details>

<details id="BASHLOG_EXTRA"><summary><b>BASHLOG_EXTRA</b></summary><br>

Integer (Default: 0)

By default, console output from tofuenv does not print a date stamp or log severity.

To enable this functionality, making normal output equivalent to FILE log output, set to 1.
</details>

<details id="BASHLOG_FILE"><summary><b>BASHLOG_FILE</b></summary><br>

Integer (Default: 0)

Set to 1 to enable plain text logging to file (FILE type logging).

The default path for log files is defined by /tmp/$(basename $0).log
Each executable logs to its own file.

e.g.

```console
BASHLOG_FILE=1 tofuenv use latest
```

will log to `/tmp/tofuenv-use.log`
</details>

<details id="BASHLOG_FILE_PATH"><summary><b>BASHLOG_FILE_PATH</b></summary><br>

String (Default: /tmp/$(basename ${0}).log)

To specify a single file as the target for all FILE type logging regardless of the executing script.
</details>

<details id="BASHLOG_I_PROMISE_TO_BE_CAREFUL_CUSTOM_EVAL_PREFIX"><summary><b>BASHLOG_I_PROMISE_TO_BE_CAREFUL_CUSTOM_EVAL_PREFIX</b></summary><br>

String (Default: "")

*BE CAREFUL - MISUSE WILL DESTROY EVERYTHING YOU EVER LOVED*

This variable allows you to pass a string containing a command that will be executed using `eval` in order to produce a prefix to each console output line, and each FILE type log entry.

e.g.

```console
BASHLOG_I_PROMISE_TO_BE_CAREFUL_CUSTOM_EVAL_PREFIX='echo "${$$} "'
```
will prefix every log line with the calling process' PID.
</details>

<details id="BASHLOG_JSON"><summary><b>BASHLOG_JSON</b></summary><br>

Integer (Default: 0)

Set to 1 to enable JSON logging to file (JSON type logging).

The default path for log files is defined by /tmp/$(basename $0).log.json
Each executable logs to its own file.

e.g.

```console
BASHLOG_JSON=1 tofuenv use latest
```

will log in JSON format to `/tmp/tofuenv-use.log.json`

JSON log content:

`{"timestamp":"<date +%s>","level":"<log-level>","message":"<log-content>"}`
</details>

<details  id="BASHLOG_JSON_PATH"><summary><b>BASHLOG_JSON_PATH</b></summary><br>

String (Default: /tmp/$(basename ${0}).log.json)

To specify a single file as the target for all JSON type logging regardless of the executing script.
</details>

<details id="BASHLOG_SYSLOG"><summary><b>BASHLOG_SYSLOG</b></summary><br>

Integer (Default: 0)

To log to syslog using the `logger` binary, set this to 1.

The basic functionality is thus:

```console
local tag="${BASHLOG_SYSLOG_TAG:-$(basename "${0}")}";
local facility="${BASHLOG_SYSLOG_FACILITY:-local0}";
local pid="${$}";
logger --id="${pid}" -t "${tag}" -p "${facility}.${severity}" "${syslog_line}"
```
</details>

<details id="BASHLOG_SYSLOG_FACILITY"><summary><b>BASHLOG_SYSLOG_FACILITY</b></summary><br>

String (Default: local0)

The syslog facility to specify when using SYSLOG type logging.
</details>

<details id="BASHLOG_SYSLOG_TAG"><summary><b>BASHLOG_SYSLOG_TAG</b></summary><br>

String (Default: $(basename $0))

The syslog tag to specify when using SYSLOG type logging.

Defaults to the PID of the calling process.
</details>

---

### tofuenv use [version]

Switch a version to use

If no parameter is passed, the version to use is resolved automatically via [.opentofu-version files](#opentofu-version-file) or [TOFUENV_TOFU_VERSION environment variable](#TOFUENV_TOFU_VERSION) (TOFUENV_TOFU_VERSION takes precedence), defaulting to 'latest' if none are found.

`latest` is a syntax to use the latest installed stable version
NOTE: `latest` syntax will be available after first stable OpenTofu release
`latest:<regex>` is a syntax to use latest installed version matching regex (used by grep -e)
`min-required` will switch to the version minimally required by your tofu sources (see above `tofuenv install`)
`latest-allowed` will switch to the version maximally allowed by your tofu sources (see above `tofuenv install`).

```console
$ tofuenv use
$ tofuenv use min-required
$ tofuenv use 0.7.0
$ tofuenv use latest
$ tofuenv use latest:^0.8
$ tofuenv use latest-allowed
```

Note: `tofuenv use latest` or `tofuenv use latest:<regex>` will find the latest matching version that is already installed. If no matching versions are installed, and TOFUENV_AUTO_INSTALL is set to `true` (which is the default) the latest matching version in the remote repository will be installed and used.

### tofuenv uninstall &lt;version>

Uninstall a specific version of OpenTofu
`latest` is a syntax to uninstall latest version
`latest:<regex>` is a syntax to uninstall latest version matching regex (used by grep -e)

```console
$ tofuenv uninstall 0.7.0
$ tofuenv uninstall latest
$ tofuenv uninstall latest:^0.8
```

### tofuenv list

List installed versions

```console
$ tofuenv list
  1.6.0-alpha5
* 1.6.0-rc1 (set by /opt/.tofuenv/version)
```

### tofuenv list-remote

List installable versions

```console
$ tofuenv list-remote
1.6.0-rc1
1.6.0-beta5
1.6.0-beta4
1.6.0-beta3
1.6.0-beta2
1.6.0-beta1
1.6.0-alpha5
1.6.0-alpha4
1.6.0-alpha3
1.6.0-alpha2
1.6.0-alpha1
...
```

### tofuenv version-name
Prints the version of OpenTofu, used in the current directory.
The version is resolved automatically via [TOFUENV_TOFU_VERSION environment variable](#TOFUENV_TOFU_VERSION) or [.opentofu-version files](#opentofu-version-file), in that order of precedence, i.e. TOFUENV_TOFU_VERSION, then .opentofu-version.
```console
$ tofuenv version-name
1.6.0
```

### tofuenv pin
Writes the current active OpenTofu version to ./.opentofu-version file (creates if no file exists).
```console
$ tofuenv pin
Pinned version by writing "1.6.0" to /Users/anastasiiakozlova/coding/opensource/tofuenv/.opentofu-version
$ cat .opentofu-version
1.6.0
```

#### .opentofu-version file

If you put a `.opentofu-version` file on your project root, or in your home directory (automatically using `tofuenv pin` command or manually), tofuenv detects it and uses the version written in it. If the version is `latest` or `latest:<regex>`, the latest matching version currently installed will be selected.

Note, that [TOFUENV_TOFU_VERSION environment variable](#TOFUENV_TOFU_VERSION) can be used to override version, specified by `.opentofu-version` file.

```console
$ cat .opentofu-version
1.6.0-beta5

$ tofu version
OpenTofu v1.6.0-beta5
on darwin_amd64

$ echo 1.6.0-alpha5 > .opentofu-version

$ tofu version
OpenTofu v1.6.0-alpha5
on darwin_amd64

$ echo latest:^1.6 > .opentofu-version

$ tofu version
OpenTofu v1.6.0-rc1
on darwin_amd64

$ TOFUENV_TOFU_VERSION=1.6.0-alpha1 tofu --version
tofu v1.6.0-alpha1
on darwin_amd64
```

## Upgrading

```console
git --git-dir=~/.tofuenv/.git pull
```

## Uninstalling

```console
rm -rf /some/path/to/tofuenv
```

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

Check out our [contributing guide](CONTRIBUTING.md) to get started.

Don't forget to give the project a star! Thanks again!

## Community
Have questions or suggestions? Reach out to us via:

* [GitHub Issues](https://github.com/tofuutils/tofuenv/issues)
* User/Developer Group: Join github community to get update of Harbor's news, features, releases, or to provide suggestion and feedback.
* Slack: Join tofuutils's community for discussion and ask questions: OpenTofu, channel: #tofuutils

## Authors
 This project was made possible by the help of these awesome contributors:
<a href="https://github.com/tofuutils/tofuenv/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=tofuutils/tofuenv" />
</a>
<a href="https://star-history.com/#tofuutils/tofuenv&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=tofuutils/tofuenv&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=tofuutils/tofuenv&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=tofuutils/pre-commit-opentofu&type=Date" />
  </picture>
</a>

## LICENSE

- [tofuenv itself](https://github.com/tofuutils/tofuenv/blob/main/LICENSE)
- [tfenv](https://github.com/tfutils/tfenv/blob/master/LICENSE)
  - tofuenv uses tfenv's source code
- [rbenv](https://github.com/rbenv/rbenv/blob/master/LICENSE)
  - tfenv partially uses rbenv's source code
