#!/bin/bash
set -euo pipefail  # Безопасный режим

# === Настройки ===
LOG_FILE="setup_zsh_$(date +%F).log"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# === Логирование ===
exec > >(tee -a "$LOG_FILE") 2>&1
echo -e "${GREEN}[$(date)] Начало выполнения скрипта${NC}"

# === Проверка sudo ===
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Ошибка: Запустите скрипт с sudo.${NC}"
  exit 1
fi

# === Определение дистрибутива ===
detect_distro() {
    if grep -q 'Alpine' /etc/os-release 2>/dev/null; then
        distro="Alpine"
    elif [ -f /etc/arch-release ]; then
        distro="Arch Linux"
    elif [ -f /etc/debian_version ]; then
        distro="Debian"
    elif [ -f /etc/redhat-release ]; then
        distro="Red Hat"
    elif [ -f /etc/centos-release ]; then
        distro="CentOS"
    elif [ -f /etc/fedora-release ]; then
        distro="Fedora"
    elif [ -f /etc/SUSE-brand ]; then
        distro="openSUSE"
    elif [ -f /etc/oracle-release ]; then
        distro="Oracle Linux"
    elif grep -q 'Ubuntu' /etc/os-release 2>/dev/null; then
        distro="Ubuntu"
    elif grep -q 'Linux Mint' /etc/os-release 2>/dev/null; then
        distro="Linux Mint"
    else
        echo -e "${RED}Не удалось определить дистрибутив${NC}"
        exit 1
    fi
    echo -e "${GREEN}[+] Определен дистрибутив: $distro${NC}"
}

# === Обновление системы ===
update_system() {
    echo -e "${YELLOW}[?] Обновить систему? [Y/n]${NC}"
    read -r answer
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
            echo -e "${RED}[-] Неизвестный дистрибутив. Пропущено обновление системы.${NC}"
            return 1 ;;
    esac
    echo -e "${GREEN}[+] Система обновлена${NC}"
}

# === Установка пакетов ===
install_packages() {
    echo -e "${GREEN}[+] Установка Zsh и других утилит...${NC}"
    case "$distro" in
        Debian|Ubuntu|Linux\ Mint)
            apt install -y zsh mc wget curl telnet nano neofetch ;;
        CentOS|Oracle\ Linux|Red\ Hat)
            yum install -y zsh mc wget curl telnet nano neofetch ;;
        Fedora)
            dnf install -y zsh mc wget curl telnet nano neofetch ;;
        openSUSE)
            zypper install -y zsh mc wget curl telnet nano neofetch ;;
        Arch*)
            pacman -S --noconfirm zsh mc wget curl telnet nano neofetch ;;
        Alpine)
            apk add zsh mc wget curl telnet nano neofetch ;;
        *)
            echo -e "${RED}[-] Неизвестный дистрибутив. Пропущена установка пакетов.${NC}"
            return 1 ;;
    esac
    echo -e "${GREEN}[+] Установлены пакеты: Zsh, mc, wget и др.${NC}"
}

# === Настройка локалей ===
setup_locales() {
    echo -e "${YELLOW}[?] Настроить локали ru_RU.UTF-8 и en_US.UTF-8? [Y/n]${NC}"
    read -r answer
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

# === Установка Oh My Zsh ===
install_ohmyzsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo -e "${YELLOW}[i] Oh My Zsh уже установлен${NC}"
        return
    fi

    echo -e "${GREEN}[+] Установка Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo -e "${GREEN}[+] Oh My Zsh установлен${NC}"
}

# === Настройка .zshrc ===
configure_zshrc() {
    echo -e "${YELLOW}[?] Использовать внешний .zshrc из GitHub? [Y/n]${NC}"
    read -r answer
    [[ "$answer" =~ ^([yY]$|) ]] || return

    if [ -f ~/.zshrc ]; then
        cp ~/.zshrc ~/.zshrc.bak
        echo -e "${YELLOW}[i] Создан резервный файл: ~/.zshrc.bak${NC}"
    fi

    curl -fsSL -o ~/.zshrc https://raw.githubusercontent.com/fenixvd/dotfiles/master/.zshrc
    echo -e "${GREEN}[+] Конфиг .zshrc загружен${NC}"
}

# === Смена оболочки по умолчанию ===
change_shell() {
    if [ -x /usr/bin/zsh ] || [ -x /bin/zsh ]; then
        chsh -s "$(command -v zsh)"
        echo -e "${GREEN}[+] Zsh установлен как оболочка по умолчанию${NC}"
    else
        echo -e "${RED}[-] Zsh не найден в /usr/bin или /bin. Пропущена смена оболочки.${NC}"
    fi
}

# === Точка входа ===
main() {
    detect_distro
    update_system
    install_packages
    setup_locales
    install_ohmyzsh
    configure_zshrc
    change_shell

    echo -e "${GREEN}\n✅ Установка завершена! Перезапустите терминал или введите 'zsh'.${NC}"
}

# === Запуск только если это основной скрипт ===
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
