#!/bin/bash
: '
sudo .assets/provision/install_exa.sh
'

APP='exa'
while [[ -z $REL ]]; do
  REL=$(curl -sk https://api.github.com/repos/ogham/exa/releases/latest | grep -Po '"tag_name": *"v\K.*?(?=")')
done

if type $APP &>/dev/null; then
  VER=$(exa --version | grep -Po '(?<=^v)[\d\.]+')
  if [ $REL = $VER ]; then
    echo "$APP v$VER is already latest"
    exit 0
  fi
fi

echo "Install $APP v$REL"
# determine system id
SYS_ID=$(grep -oPm1 '^ID(_LIKE)?=.*\K(arch|fedora|debian|ubuntu|opensuse)' /etc/os-release)

INSTALLED=false
case $SYS_ID in
arch)
  pacman -Sy --needed --noconfirm exa && INSTALLED=true
  ;;
fedora)
  dnf install -y exa && INSTALLED=true
  ;;
debian | ubuntu)
  apt install -y exa && INSTALLED=true
  ;;
opensuse)
  zypper in -y exa && INSTALLED=true
  ;;
esac
$INSTALLED && exit 0

# install from binary if above didn't work
while [[ ! -f exa-linux-x86_64.zip ]]; do
  curl -Lsk -o exa-linux-x86_64.zip "https://github.com/ogham/exa/releases/download/v${REL}/exa-linux-x86_64-v${REL}.zip"
done
unzip exa-linux-x86_64.zip
\mv -f bin/exa /usr/bin/exa
\mv -f man/* $(manpath | cut -d : -f 1)/man1
\mv -f completions/exa.bash /etc/bash_completion.d
rm -fr bin completions man exa-linux-x86_64.zip
