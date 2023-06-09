#!/bin/bash

# Определение дистрибутива и установка софта
if [ -e /etc/debian_version ]; then
  # Установка софта для Debian/Ubuntu/Mint
  if [ -e /usr/bin/apt-get ]; then
    sudo apt-get install zsh mc wget curl telnet nano neofetch -y
  fi
   # Установка для Alt Linux
  elif [ -e /etc/os-release ]; then
  # Установка софта для Alt Linux
  if [ -e /usr/bin/epm ]; then
   epmi zsh mc wget curl telnet nano neofetch -y
  fi
elif [ -e /etc/redhat-release ]; then
  # Установка софта для CentOS/Oracle Linux/Red Hat
  if [ -e /usr/bin/yum ]; then
    sudo yum install zsh mc wget curl telnet nano neofetch -y
    fi
  # Установка софта для Fedora
  if [ -e /usr/bin/dnf ]; then
    sudo dnf install zsh mc wget curl telnet nano neofetch  -y
  fi
  # Установка софта для OpenSUSE
  if [ -e /usr/bin/zypper ]; then
    sudo zypper install zsh mc wget curl telnet nano neofetch -y
  fi
  elif [ -f /etc/arch-release ]; then
    DISTRIBUTION="arch"
    sudo pacman -S zsh mc wget curl telnet nano neofetch
else
    echo "Дистрибутив не поддерживается."
    exit 1
fi

# Выбор и установка локали
echo "Выберите локаль:"
echo "1) en_US.UTF-8"
echo "2) ru_RU.UTF-8"

read -p "Выберите локаль: " choice
case $choice in
    1) sudo update-locale LANG=en_US.UTF-8;;
    2) sudo update-locale LANG=ru_RU.UTF-8;;
esac
echo "Локаль $choice установлена"

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
