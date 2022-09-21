#!/bin/bash
: '
.assets/provision/install_k3d.sh
'

APP='k3d'
while [[ -z $REL ]]; do
  REL=$(curl -sk https://api.github.com/repos/k3d-io/k3d/releases/latest | grep -Po '"tag_name": *"v\K.*?(?=")')
done

if type $APP &>/dev/null; then
  VER=$(k3d --version | grep -Po '(?<=v)[\d\.]+$')
  if [ $REL = $VER ]; then
    echo "The latest $APP v$VER is already installed!"
    exit 0
  fi
fi

echo "Install $APP v$REL"
while [[ $(k3d --version | grep -Po '(?<=v)[\d\.]+$') != $REL ]]; do
  curl -sk 'https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh' | bash
done
