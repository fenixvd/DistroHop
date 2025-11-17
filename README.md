# DistroHop

**Автоматизированная установка Zsh, Oh My Zsh и утилит для вашего Linux-дистрибутива.

---

## Особенности

- Поддержка популярных дистрибутивов: Debian, Ubuntu, Linux Mint, Fedora, CentOS, Arch Linux, openSUSE, Alpine, Oracle Linux.
- Все конфиги и .oh-my-zsh устанавливаются для пользователя, вызвавшего `sudo`, а не для root.
- Безопасный режим исполнения (`set -euo pipefail`).
- Автоматическое определение дистрибутива.
- Установка: Zsh, Oh My Zsh, mc, wget, curl, telnet, nano, fastfetch.
- Загрузка кастомного `.zshrc` из [fenixvd/dotfiles](https://github.com/fenixvd/dotfiles).
- Смена shell на Zsh для вашего пользователя.
- CLI-флаги для автоматизации: `--yes`, `--no-prompt`, `--only-zsh`.
- Логирование в файл (`setup_zsh_<DATE>.log`).

---

## Использование

1. Клонируйте репозиторий:
   ```sh
   git clone https://github.com/fenixvd/DistroHop.git
   cd DistroHop/
   chmod +x install.sh
   sudo ./install.sh
