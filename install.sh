#!/bin/bash
set -euo pipefail

# === Переменные ===
LOG_FILE="setup_zsh_$(date +%F).log"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'
AUTO_YES=false
NO_PROMPT=false
ONLY_ZSH=false

# --- Получение пользователя и его HOME ---
if [ "$EUID" -eq 0 ]; then
  TARGET_USER="${SUDO_USER:-root}"
else
  TARGET_USER="$USER"
fi

TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"

# === ПАРСИНГ ФЛАГОВ ===
while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes) AUTO_YES=true ;;
    --no-prompt) NO_PROMPT=true ;;
    --only-zsh) ONLY_ZSH=true ;;
    *) ;;
  esac
  shift
done

# === Логирование ===
exec > >(tee -a "$LOG_FILE") 2>&1
echo -e "${GREEN}[$(date)] Старт скрипта установки${NC}"

# === Проверка sudo ===
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Ошибка: Запустите скрипт с sudo.${NC}"
  exit 1
fi

if [ "$TARGET_USER" = "root" ]; then
  echo -e "${YELLOW}[!] Скрипт выполняется для root. Все конфиги будут в /root.${NC}"
else
  echo -e "${YELLOW}[!] Скрипт выполняется для пользователя: $TARGET_USER. Конфиги пишутся в $TARGET_HOME.${NC}"
fi

# === Проверка наличия утилит ===
need_cmd() {
  command -v "$1" >/dev/null || { echo -e "${RED}Требуется утилита '$1', но она не найдена.${NC}"; exit 1; }
}
for cmd in curl tee chsh; do need_cmd "$cmd"; done

# === Определение дистрибутива ===
detect_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
      alpine) distro="Alpine" ;;
      arch) distro="Arch Linux" ;;
      debian) distro="Debian" ;;
      ubuntu) distro="Ubuntu" ;;
      centos) distro="CentOS" ;;
      fedora) distro="Fedora" ;;
      opensuse*|suse) distro="openSUSE" ;;
      oracle) distro="Oracle Linux" ;;
      linuxmint) distro="Linux Mint" ;;
      *) distro="$ID" ;;
    esac
  else
    echo -e "${RED}Не удалось определить дистрибутив${NC}"
    exit 1
  fi
  echo -e "${GREEN}[+] Дистрибутив: $distro${NC}"
}

# === Обновление системы ===
update_system() {
  if $NO_PROMPT || $AUTO_YES; then answer="y"; else
    echo -e "${YELLOW}[?] Обновить систему? [Y/n]${NC}"
    read -r answer
  fi
  [[ "$answer" =~ ^([yY]$|) ]] || return

  case "$distro" in
    Debian|Ubuntu|Linux\ Mint)
      apt update && apt upgrade -y ;;
    CentOS|Oracle\ Linux|Red\ Hat)
      yum update -y ;;
    Fedora)
      dnf update -y ;;
    openSUSE)
      zypper update -y ;;
    Arch*)
      pacman -Syu --noconfirm ;;
    Alpine)
      apk update && apk upgrade ;;
    *)
      echo -e "${RED}[-] Неизвестный дистрибутив. Пропущено обновление.${NC}"
      return 1 ;;
  esac
  echo -e "${GREEN}[+] Система обновлена${NC}"
}

# === Установка только Zsh и Oh My Zsh ===
install_minimal_zsh() {
  echo -e "${GREEN}[+] Минимальная установка Zsh...${NC}"
  case "$distro" in
    Debian|Ubuntu|Linux\ Mint)
      apt install -y zsh ;;
    CentOS|Oracle\ Linux|Red\ Hat)
      yum install -y zsh ;;
    Fedora)
      dnf install -y zsh ;;
    openSUSE)
      zypper install -y zsh ;;
    Arch*)
      pacman -S --noconfirm zsh ;;
    Alpine)
      apk add zsh ;;
    *)
      echo -e "${RED}[-] Неизвестный дистрибутив. Пропущена установка.${NC}"
      return 1 ;;
  esac
  echo -e "${GREEN}[+] Zsh установлен${NC}"
}

# === Установка пакетов (замена neofetch на fastfetch) ===
install_packages() {
  echo -e "${GREEN}[+] Установка Zsh и утилит...${NC}"
  case "$distro" in
    Debian|Ubuntu|Linux\ Mint)
      apt install -y zsh mc wget curl telnet nano fastfetch ;;
    CentOS|Oracle\ Linux|Red\ Hat)
      yum install -y zsh mc wget curl telnet nano fastfetch ;;
    Fedora)
      dnf install -y zsh mc wget curl telnet nano fastfetch ;;
    openSUSE)
      zypper install -y zsh mc wget curl telnet nano fastfetch ;;
    Arch*)
      pacman -S --noconfirm zsh mc wget curl telnet nano fastfetch ;;
    Alpine)
      apk add zsh mc wget curl telnet nano fastfetch ;;
    *)
      echo -e "${RED}[-] Неизвестный дистрибутив. Пропущена установка.${NC}"
      return 1 ;;
  esac
  echo -e "${GREEN}[+] Пакеты установлены${NC}"
}

# === Настройка локалей ===
setup_locales() {
  need_cmd locale-gen || true
  if $NO_PROMPT || $AUTO_YES; then answer="y"; else
    echo -e "${YELLOW}[?] Настроить локали ru_RU.UTF-8 и en_US.UTF-8? [Y/n]${NC}"
    read -r answer
  fi
  [[ "$answer" =~ ^([yY]$|) ]] || return

  case "$distro" in
    Debian|Ubuntu|Linux\ Mint)
      locale-gen ru_RU.UTF-8 en_US.UTF-8 ;;
    CentOS|Oracle\ Linux|Red\ Hat|Fedora)
      echo "LANG=en_US.UTF-8" > /etc/locale.conf
      localectl set-locale LANG=ru_RU.UTF-8 ;;
    openSUSE)
      echo 'LC_ALL="ru_RU.UTF-8"' > /etc/default/locale
      echo 'LC_ALL="en_US.UTF-8"' >> /etc/default/locale ;;
    Arch*)
      echo "LANG=en_US.UTF-8" > /etc/locale.conf
      locale-gen
      localectl set-locale LANG=ru_RU.UTF-8 ;;
    Alpine)
      setup-timezone -z Europe/Moscow
      echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
      echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
      locale-gen ;;
    *)
      echo -e "${RED}[-] Неизвестный дистрибутив. Пропущена настройка локалей.${NC}"
      return 1 ;;
  esac
  echo -e "${GREEN}[+] Локали настроены${NC}"
}

# === Установка Oh My Zsh для правильного пользователя ===
install_ohmyzsh() {
  if [ -d "$TARGET_HOME/.oh-my-zsh" ]; then
    echo -e "${YELLOW}[i] Oh My Zsh уже установлен для $TARGET_USER${NC}"
    return
  fi

  echo -e "${GREEN}[+] Установка Oh My Zsh для $TARGET_USER...${NC}"
  sudo -u "$TARGET_USER" HOME="$TARGET_HOME" sh -c \
    "curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh -s -- --unattended" \
    || { echo -e "${RED}Ошибка установки Oh My Zsh.${NC}"; return 1; }
  echo -e "${GREEN}[+] Oh My Zsh установлен для $TARGET_USER${NC}"
}

# === Настройка .zshrc для правильного пользователя ===
configure_zshrc() {
  if $NO_PROMPT || $AUTO_YES; then answer="y"; else
    echo -e "${YELLOW}[?] Использовать внешний .zshrc из GitHub? [Y/n]${NC}"
    read -r answer
  fi
  [[ "$answer" =~ ^([yY]$|) ]] || return

  if [ -f "$TARGET_HOME/.zshrc" ]; then
    cp "$TARGET_HOME/.zshrc" "$TARGET_HOME/.zshrc.bak"
    echo -e "${YELLOW}[i] Создан резерв: $TARGET_HOME/.zshrc.bak${NC}"
  fi

  if ! sudo -u "$TARGET_USER" curl -fsSL -o "$TARGET_HOME/.zshrc" https://raw.githubusercontent.com/fenixvd/dotfiles/master/.zshrc; then
    echo -e "${RED}Ошибка загрузки .zshrc. Восстановление из .zshrc.bak.${NC}"
    [ -f "$TARGET_HOME/.zshrc.bak" ] && mv "$TARGET_HOME/.zshrc.bak" "$TARGET_HOME/.zshrc"
    return 1
  fi
  echo -e "${GREEN}[+] Конфиг .zshrc загружен в $TARGET_HOME/.zshrc${NC}"
}

# === Смена оболочки по умолчанию для правильного пользователя ===
change_shell() {
  local zsh_path
  zsh_path="$(command -v zsh)"
  if [ -x "$zsh_path" ]; then
    chsh -s "$zsh_path" "$TARGET_USER"
    echo -e "${GREEN}[+] Zsh установлен как оболочка по умолчанию для $TARGET_USER${NC}"
  else
    echo -e "${RED}[-] Zsh не найден. Пропущена смена оболочки.${NC}"
  fi
}

# === Точка входа ===
main() {
  detect_distro
  if $ONLY_ZSH; then
    install_minimal_zsh
    install_ohmyzsh
    configure_zshrc
    change_shell
  else
    update_system
    install_packages
    setup_locales
    install_ohmyzsh
    configure_zshrc
    change_shell
  fi

  echo -e "${GREEN}\n✅ Установка завершена для $TARGET_USER! Перезапустите терминал или введите 'zsh'.${NC}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main
fi
