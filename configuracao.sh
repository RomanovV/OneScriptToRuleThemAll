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
# chmod +755 configuracao.sh
# ou
# chmod a+x configuracao.sh
# sudo ./configuracao.sh
#
########################################

INSTALLED="/usr/bin"
TOR="$INSTALLED/tor"
CINNAMON="$INSTALLED/cinnamon"
KEEPASS="$INSTALLED/keepassxc"
THUNDER="$INSTALLED/thunderbird"

instalation=0
tor_browser_chk=0
tor_status_chk=0
cinnamon_config_chk=0

# Não implementado ainda
ARG1=$1

######### Func Definition ###########

###################################

deu_certo_config(){
  test=$1
  if [ $test == 1 ]
  then
    echo "$config_name foi configurada..."
  else
    echo "$config_name falhou em ser configurada..."
  fi
}


#####################################

checa_instalacao(){
  test_1=$1
  if [ -f $test_1 ]
  then
    echo "$prog_name foi instalado..."
  else
    echo "$prog_name falho em sem instalado..."
  fi

}

#####################################


echo "Iniciando o processo de configuração do Linux/Fedora..."
sleep 2

# Atualizando repositórios
sudo dnf update -y

# Instalando programas
echo "Instalando Tor, KeePassXC, Thunderbird, cinnamon..."
sudo dnf install tor keepassxc thunderbird cinnamon -y
sleep 2
# sanity checks : Checa se os programas foram instalados
if [ -f "$TOR" ] && [ -f "$CINNAMON" ] && [ -f "$KEEPASS" ] && [ -f "$THUNDER" ]
then
  instalation=1
else
  instalation=0
fi
sleep 2

if [ -f "$TOR" ]
then
  # Baixa, instala e configura o tor-browser
  echo "Instalando Tor Browser - o navegador do Tor..."
  wget https://www.torproject.org/dist/torbrowser/8.0.3/tor-browser-linux64-8.0.3_en-US.tar.xz
  tar -xvf tor-browser-linux64-8.0.3_en-US.tar.xz
  cd tor-browser_en-US/
  ./start-tor-browser.desktop --register-app
  sudo rm -f tor-browser-linux64-8.0.3_en-US.tar.xz
else
  echo "A instalação da Rede Tor falhou,
    pulando configuração e instalação do Tor Browser..."
fi
sleep 2

# Sanity Check : Ver se registrou de verdade
if [ -f "/home/$USER/.local/share/applications/start-tor-browser.desktop" ]
then
  tor_browser_chk=1
else
  tor_browser_chk=0
fi
sleep 2

# Se o serviço da rede tor não está sendo executado, executa ele
# Talvez não seja necessário, e se não for, não vai fazer nada
tor_status=`sudo systemctl status tor.service | grep Active:`
if [[ $tor_status == *"asdefkq"* ]]
then
  tor_status_chk=1
else
  tor_status_chk=0
fi

# Se o serviço do tor estiver desligado, liga ele
if [ tor_status_chk == 0 ]
then
  echo "Inicia o serviço do Tor, se for necessário..."
  sudo systemctl start tor.service
  sleep 2
fi

if [ -f "$CINNAMON" ]
then
  # seta o ambiente de desktop para o cinnamon
  echo "Configurando o ambiente de Desktop para o cinnamon..."
  sudo sed -i -- 's/gnome/cinnamon/g' /var/lib/AccountsService/users/$USER
else
  echo "O ambiente de desktop cinnamon não foi instalado,
    pulando a configuração..."
fi

# sanity check : testa se mudou mesmo
if sudo grep -xqFe "XSession=cinnamon" /var/lib/AccountsService/users/$USER
then
  cinnamon_config_chk=1
else
  cinnamon_config_chk=0
fi
sleep 2



prog_name="Tor"
checa_instalacao $TOR
sleep 2

prog_name="Cinnamon"
checa_instalacao $CINNAMON
sleep 2

prog_name="Thunderbird"
checa_instalacao $THUNDER
sleep 2

prog_name="O KeePassXC"
checa_instalacao $KEEPASS
sleep 2

config_name="O ambiente de Desktop Cinnamon"
deu_certo_config $cinnamon_config_chk
sleep 2

config_name="O Tor Browser"
deu_certo_config $tor_browser_chk
sleep 2

DATE=`date '+%d-%m-%Y %H:%M:%S'`

if [ $cinnamon_config_chk == 1 ] && [ $tor_browser_chk == 1 ]
  && [ $instalation == 1 ]; then
  echo "Tudo foi instalado com sucesso..."
  sleep 2
  echo "Aguarde que o computador vai reiniciar..."
  sleep 5
  sudo reboot
else
  log_file_name=log_script.$DATE
  echo "Log de erro: $DATE" > "$log_file_name"
  echo -e " Desktop status = $cinnamon_config_chk \n
    tor_browser_chk Status = $tor_browser_chk \n
      With Installation return of = $instalation" >> "$log_file_name"
fi
