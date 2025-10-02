# NAME
**install.sh** — script for automated installation of Zsh, Oh My Zsh, and a set of utilities (mc, wget, curl, telnet, nano, fastfetch) with support for popular Linux distributions.

# SYNOPSIS
`sudo ./install.sh [OPTIONS]`

# DESCRIPTION
This script sets up a modern shell environment for a selected Linux user. It automatically detects the distribution, installs required packages, configures locales, downloads .zshrc, installs Oh My Zsh, and sets Zsh as the default shell.

**Key Features:**
- All user files (.zshrc, .oh-my-zsh, etc.) are installed for the user who invoked `sudo`, not for root.
- Supports most popular Linux distributions.
- Safe execution mode (`set -euo pipefail`).
- Supports interactive mode and automation via flags.

# OPTIONS
- `-y`, `--yes`  
  Automatically answer "yes" to all prompts (useful for automation).

- `--no-prompt`
  Disable all interactive prompts. The script runs with default actions.

- `--only-zsh`
  Install only Zsh and Oh My Zsh (without mc, wget, curl, telnet, nano, fastfetch, and locale setup).

# USAGE
**Standard installation:**
```sh
sudo ./install.sh
```
**Automated installation without prompts:**
```sh
sudo ./install.sh --yes
```
**Install only Zsh and Oh My Zsh:**
```sh
sudo ./install.sh --only-zsh
```

# EXAMPLES
- Install for current user via sudo:
  ```sh
  sudo ./install.sh
  ```
- Automated installation with no prompts:
  ```sh
  sudo ./install.sh --no-prompt
  ```
- Only install the Zsh shell:
  ```sh
  sudo ./install.sh --only-zsh
  ```

# ENVIRONMENT
- `$SUDO_USER` — original user; configs will be installed for this user.
- `$HOME` — user's home directory, detected automatically for `$SUDO_USER`.

# FILES
- `${HOME}/.zshrc` — main Zsh config.
- `${HOME}/.oh-my-zsh` — Oh My Zsh framework directory.
- `setup_zsh_<DATE>.log` — script log file.

# SUPPORTED DISTROS
Debian, Ubuntu, Linux Mint, CentOS, Red Hat, Fedora, openSUSE, Arch Linux, Alpine, Oracle Linux.

# SEE ALSO
- [Zsh](https://www.zsh.org/)
- [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh)
- [fastfetch](https://github.com/fastfetch-cli/fastfetch)

# AUTHOR
fenixvd <fenixvd@github.com>

# BUGS
The fastfetch package may be missing in some distros — check repository availability or install manually if needed.  
The script does not support macOS and WSL.

# LICENSE
MIT
