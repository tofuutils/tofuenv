# tofuenv

[OpenTofu](https://opentofu.org/) version manager inspired by [tfenv](https://github.com/tfutils/tfenv)

## Important notice

Many people have asked about Terraform support, and we are finally ready to announce a successor for tfenv and tofuenv: [tenv](https://github.com/tofuutils/tenv) written in Golang. tenv is able to handle Terraform binaries as well as OpenTofu binaries. 

Please contribute to [tenv](https://github.com/tofuutils/tenv) and award us stars. The release date will be announced soon.

## Support

Currently tofuenv supports the following operating systems:

- macOS
  - 64bit
  - Arm (Apple Silicon)
- Linux
  - 64bit
  - Arm
- Windows (64bit) - only tested in git-bash - currently presumed failing due to symlink issues in git-bash

## Installation

### Automatic

Install via Homebrew

```console
brew tap tofuutils/tap
brew install tofuenv
```

Install via Arch User Repository (AUR)

```console
git clone https://aur.archlinux.org/tofuenv.git
cd tofuenv
makepkg -si
```

Install via Arch User Repository (AUR) via yay
   
```console
yay --sync tofuenv
```

### Manual (Linux and MacOS)

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

### Manual (Windows)
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

## Install dependencies

Install jq (required) and GnuPG (optional, in case you want to enable GPG verification during OpenTofu installation)
### MacOS 
```console
brew install jq gnupg grep
```

### Linux
```console
sudo apt-get update -y
sudo apt-get install -y jq gnupg
```

### Windows (git-bash)
Install jq package into git-bash default installation folder:
```console
curl -L -o /usr/bin/jq.exe https://github.com/jqlang/jq/releases/latest/download/jq-win64.exe
```

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

### Environment Variables

#### TOFUENV

##### `TOFUENV_GITHUB_TOKEN`

String (Default: "")

Specify GitHub token. Because of OpenTofu binares placed in the GitHub you may encounter with rate limit problem.
Using a personal access token dramatically increases rate limit.
[GitHub Rate limits for the REST API](https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api)

##### `TOFUENV_ARCH`

String (Default: `amd64`)

Specify architecture. Architecture other than the default amd64 can be specified with the `TOFUENV_ARCH` environment variable

Note: Default changes to `arm64` for versions that have arm64 builds available when `$(uname -m)` matches `aarch64* | arm64*`

```console
TOFUENV_ARCH=arm64 tofuenv install 0.7.9
```

##### `TOFUENV_AUTO_INSTALL`

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

##### `TOFUENV_CURL_OUTPUT`

Integer (Default: 2)

Set the mechanism used for displaying download progress when downloading tofu versions from the remote server.

* 2: v1 Behaviour: Pass `-#` to curl
* 1: Use curl default
* 0: Pass `-s` to curl

##### `TOFUENV_DEBUG`

Integer (Default: 0)

Set the debug level for tofuenv.

* 0: No debug output
* 1: Simple debug output
* 2: Extended debug output, with source file names and interactive debug shells on error
* 3: Debug level 2 + Bash execution tracing

##### `TOFUENV_REMOTE`

String (Default: https://github.com/opentofu/opentofu/releases)

To install from a remote other than the default

```console
TOFUENV_REMOTE=https://example.jfrog.io/artifactory/opentofu
```

##### `TOFUENV_REVERSE_REMOTE`

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

##### `TOFUENV_SKIP_LIST_REMOTE`

Integer (Default: 0)

Skip list remote versions in installation step. Can be useful for a custom remote, such as Artifactory.

Disabled: 0
Enable: any other value

```console
TOFUENV_SKIP_LIST_REMOTE=1 tofuenv install 1.6.0-rc1
```

##### `TOFUENV_CONFIG_DIR`

Path (Default: `$TOFUENV_ROOT`)

The path to a directory where the local tofu versions and configuration files exist.

```console
TOFUENV_CONFIG_DIR="$XDG_CONFIG_HOME/tofuenv"
```

##### `TOFUENV_TOFU_VERSION`

String (Default: "")

If not empty string, this variable overrides OpenTofu version, specified in [.opentofu-version files](#opentofu-version-file).
`latest` and `latest:<regex>` syntax are also supported.
[`tofuenv install`](#tofuenv-install-version) and [`tofuenv use`](#tofuenv-use-version) command also respects this variable.

e.g.

```console
TOFUENV_TOFU_VERSION=latest:^0.11. tofu --version
```

##### `TOFUENV_NETRC_PATH`

String (Default: "")

If not empty string, this variable specifies the credentials file used to access the remote location (useful if used in conjunction with TOFUENV_REMOTE).

e.g.

```console
TOFUENV_NETRC_PATH="$PWD/.netrc.tofuenv"
```


#### Bashlog Logging Library

##### `BASHLOG_COLOURS`

Integer (Default: 1)

To disable colouring of console output, set to 0.


##### `BASHLOG_DATE_FORMAT`

String (Default: +%F %T)

The display format for the date as passed to the `date` binary to generate a datestamp used as a prefix to:

* `FILE` type log file lines.
* Each console output line when `BASHLOG_EXTRA=1`

##### `BASHLOG_EXTRA`

Integer (Default: 0)

By default, console output from tofuenv does not print a date stamp or log severity.

To enable this functionality, making normal output equivalent to FILE log output, set to 1.

##### `BASHLOG_FILE`

Integer (Default: 0)

Set to 1 to enable plain text logging to file (FILE type logging).

The default path for log files is defined by /tmp/$(basename $0).log
Each executable logs to its own file.

e.g.

```console
BASHLOG_FILE=1 tofuenv use latest
```

will log to `/tmp/tofuenv-use.log`

##### `BASHLOG_FILE_PATH`

String (Default: /tmp/$(basename ${0}).log)

To specify a single file as the target for all FILE type logging regardless of the executing script.

##### `BASHLOG_I_PROMISE_TO_BE_CAREFUL_CUSTOM_EVAL_PREFIX`

String (Default: "")

*BE CAREFUL - MISUSE WILL DESTROY EVERYTHING YOU EVER LOVED*

This variable allows you to pass a string containing a command that will be executed using `eval` in order to produce a prefix to each console output line, and each FILE type log entry.

e.g.

```console
BASHLOG_I_PROMISE_TO_BE_CAREFUL_CUSTOM_EVAL_PREFIX='echo "${$$} "'
```
will prefix every log line with the calling process' PID.

##### `BASHLOG_JSON`

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

##### `BASHLOG_JSON_PATH`

String (Default: /tmp/$(basename ${0}).log.json)

To specify a single file as the target for all JSON type logging regardless of the executing script.

##### `BASHLOG_SYSLOG`

Integer (Default: 0)

To log to syslog using the `logger` binary, set this to 1.

The basic functionality is thus:

```console
local tag="${BASHLOG_SYSLOG_TAG:-$(basename "${0}")}";
local facility="${BASHLOG_SYSLOG_FACILITY:-local0}";
local pid="${$}";
logger --id="${pid}" -t "${tag}" -p "${facility}.${severity}" "${syslog_line}"
```

##### `BASHLOG_SYSLOG_FACILITY`

String (Default: local0)

The syslog facility to specify when using SYSLOG type logging.

##### `BASHLOG_SYSLOG_TAG`

String (Default: $(basename $0))

The syslog tag to specify when using SYSLOG type logging.

Defaults to the PID of the calling process.



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

## LICENSE

- [tofuenv itself](https://github.com/tofuutils/tofuenv/blob/main/LICENSE)
- [tfenv](https://github.com/tfutils/tfenv/blob/master/LICENSE)
  - tofuenv uses tfenv's source code
- [rbenv](https://github.com/rbenv/rbenv/blob/master/LICENSE)
  - tfenv partially uses rbenv's source code
