#!/bin/bash

# Определение дистрибутива и установка софта
if [ -e /etc/debian_version ]; then
  # Установка софта для Debian/Ubuntu/Mint
  if [ -e /usr/bin/apt-get ]; then
    sudo apt-get install zsh mc wget curl telnet nano neofetch -y
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
    sudo zypper install zsh mc wget curl telnet neofetch -y
  fi
fi

# Установка английской локали
sudo sed -i 's/^#\s*\(en_US.UTF-8\)/\1/' /etc/locale.gen
sudo locale-gen
sleep 5s

# Установка ohmyzsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
sleep 5s

# Скачивание и замена файла .zshrc
curl -o ~/.zshrc https://raw.githubusercontent.com/fenixvd/dotfiles/master/.zshrc
sleep 5s

# Настройка zsh
exec zsh

# Установка zsh оболочкой по умолчанию
if [ -e /bin/zsh ]; then
  chsh -s /bin/zsh
fi

echo "Софт установлен, а так же установлен zsh как стандартный шелл."
