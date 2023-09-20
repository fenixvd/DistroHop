#!/bin/bash

# Определение дистрибутива
distro=""
if [ -f /etc/debian_version ]; then
    distro="Debian"
elif [ -f /etc/centos-release ]; then
    distro="CentOS"
elif [ -f /etc/redhat-release ]; then
    distro="Red Hat"
elif [ -f /etc/fedora-release ]; then
    distro="Fedora"
elif [ -f /etc/oracle-release ]; then
    distro="Oracle Linux"
elif [ -f /etc/SuSE-release ]; then
    distro="openSUSE"
elif [ -f /etc/arch-release ]; then
    distro="Arch Linux"
else
    echo "Не удалось определить дистрибутив"
    exit 1
fi

echo "Определен дистрибутив: $distro"

# Обновление пакетов в зависимости от дистрибутива
if [ "$distro" == "Debian" ] || [ "$distro" == "Ubuntu" ] || [ "$distro" == "Linux Mint" ]; then
    apt update
    apt upgrade -y
elif [ "$distro" == "CentOS" ] || [ "$distro" == "Oracle Linux" ] || [ "$distro" == "Red Hat" ]; then
    yum update -y
elif [ "$distro" == "Fedora" ]; then
    dnf update -y
elif [ "$distro" == "openSUSE" ]; then
    zypper update -y
elif [ "$distro" == "Arch Linux" ]; then
    pacman -Syu --noconfirm
else
    echo "Не удалось обновить пакеты"
    exit 1
fi

echo "Обновлены пакеты для дистрибутива: $distro"

# Установка Zsh и остальной софт в зависимости от дистрибутива
if [ "$distro" == "Debian" ] || [ "$distro" == "Ubuntu" ] || [ "$distro" == "Linux Mint" ]; then
    apt install -y zsh mc wget curl telnet nano neofetch
elif [ "$distro" == "CentOS" ] || [ "$distro" == "Oracle Linux" ] || [ "$distro" == "Red Hat" ]; then
    yum install -y zsh mc wget curl telnet nano neofetch
elif [ "$distro" == "Fedora" ]; then
    dnf install -y zsh mc wget curl telnet nano neofetch
elif [ "$distro" == "openSUSE" ]; then
    zypper install -y zsh mc wget curl telnet nano neofetch
elif [ "$distro" == "Arch Linux" ]; then
    pacman -S --noconfirm zsh mc wget curl telnet nano neofetch
else
    echo "Не удалось установить Zsh"
    exit 1
fi

echo "Установлен Zsh для дистрибутива: $distro"


# Выбор локали в зависимости от дистрибутива
locale=""
if [ "$distro" == "Debian" ] || [ "$distro" == "Ubuntu" ] || [ "$distro" == "Linux Mint" ]; then
    locale-gen ru_RU.UTF-8
    locale-gen en_US.UTF-8
    dpkg-reconfigure locales
    locale="ru_RU.UTF-8"
elif [ "$distro" == "CentOS" ] || [ "$distro" == "Oracle Linux" ] || [ "$distro" == "Red Hat" ]; then
    echo "LANG=ru_RU.UTF-8" > /etc/locale.conf
    echo "LANG=en_US.UTF-8" >> /etc/locale.conf
    localectl set-locale LANG=ru_RU.UTF-8
    localectl set-locale LANG=en_US.UTF-8
    locale="ru_RU.UTF-8"
elif [ "$distro" == "Fedora" ]; then
    echo "LANG=ru_RU.UTF-8" > /etc/locale.conf
    echo "LANG=en_US.UTF-8" >> /etc/locale.conf
    localectl set-locale LANG=ru_RU.UTF-8
    localectl set-locale LANG=en_US.UTF-8
    locale="ru_RU.UTF-8"
elif [ "$distro" == "openSUSE" ]; then
    echo 'LC_ALL="ru_RU.UTF-8"' > /etc/default/locale
    echo 'LC_ALL="en_US.UTF-8"' >> /etc/default/locale
    locale="ru_RU.UTF-8"
elif [ "$distro" == "Arch Linux" ]; then
    echo "LANG=ru_RU.UTF-8" > /etc/locale.conf
    echo "LANG=en_US.UTF-8" >> /etc/locale.conf
    locale-gen
    localectl set-locale LANG=ru_RU.UTF-8
    localectl set-locale LANG=en_US.UTF-8
    locale="ru_RU.UTF-8"
else
    echo "Не удалось выбрать локаль"
    exit 1
fi

# Установка ohmyzsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Скачивание и замена файла .zshrc
curl -o ~/.zshrc https://raw.githubusercontent.com/fenixvd/dotfiles/master/.zshrc

# Настройка zsh
exec zsh

# Установка zsh оболочкой по умолчанию
if [ -e /bin/zsh ]; then
  chsh -s /bin/zsh
fi

echo "Софт установлен, а так же установлен zsh как стандартный шелл."
