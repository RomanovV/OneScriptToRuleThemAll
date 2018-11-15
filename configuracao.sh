#!/bin/bash
# ONE SCRIPT TO RULE'EM ALL
# ONE SCRIP TO BIND THEM
# AND IN THE DARKNESS FIND THEM
#
########################################
#
# para baixar e executar esse SCRIPT
# wget https://github.com/RomanovV/OneScriptToRuleThemAll/archive/v1.1.tar.gz
# tar -xvf v1.1.tar.gz
# cd OneScriptToRuleThemAll-1.1/
# chmod +700 configuracao.sh
# sudo ./configuracao.sh
#
########################################

INSTALLED="/usr/bin"
TOR="$INSTALLED/tor"
CINNAMON="$INSTALLED/cinnamon"
KEEPASS="$INSTALLED/keepassxc"
THUNDER="$INSTALLED/thunderbird"

Instalation=0
Register=0
Change_Desktop=0

# Não implementado ainda
ARG1=$1

echo "Iniciando o processo de configuração do Linux/Fedora"

echo "Instalando Tor, KeePassXC, Thunderbird, cinnamon"
sudo dnf install tor keepassxc thunderbird cinnamon -y

# sanity checks : Checa se os programas foram instalados
if [ -f "$TOR" ] && [ -f "$CINNAMON" ] && [ -f "$KEEPASS" ] && [ -f "$THUNDER" ]
then
  Instalation=1
  echo "$Instalation"
else
  Instalation=0
  echo "$Instalation"
fi

# Baixa, instala e configura o tor-browser
echo "Instalando Tor Browser - o navegador do Tor"
sudo wget https://www.torproject.org/dist/torbrowser/8.0.3/tor-browser-linux64-8.0.3_en-US.tar.xz
tar -xvf tor-browser-linux64-8.0.3_en-US.tar.xz
cd tor-browser_en-US/
sudo ./start-tor-browser.desktop --register-app
sudo rm ~/tor-browser-linux64-8.0.3_en-US.tar.xz

# Sanity Check : Ver se registrou de verdade
if [ -f "/home/$USER/.local/share/applications/start-tor-browser.desktop" ]
then
  Register=1
  echo "$Register"
else
  Register=0
  echo "$Register"
fi


# Eu não sei se isso é necessário, mas não faz mal nenhum colocar
echo "Inicia o serviço do Tor"
sudo systemctl start tor.service

# seta o ambiente de desktop para o cinnamon
echo "Seta o ambiente de Desktop para o cinnamon"
sudo sed -i -- 's/gnome/cinnamon/g' /var/lib/AccountsService/users/$USER

# sanity check : testa se mudou mesmo
if sudo grep -xqFe "XSession=cinnamon" /var/lib/AccountsService/users/$USER
then
  Change_Desktop=1
  echo "$Change_Desktop"
else
  Change_Desktop=0
  echo "$Change_Desktop"
fi

echo "Mudou o Desktop = $Change_Desktop, Instalou os programas = $Instalation, Registrou o Tor Browser no Desktop = $Register"
