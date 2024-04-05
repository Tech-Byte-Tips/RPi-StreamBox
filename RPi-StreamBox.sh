#!/bin/bash
##################################################################
#    App Name: RPi-StreamBox                                     #
#      Author: PREngineer (Jorge Pabón) - pianistapr@hotmail.com #
#              https://www.github.com/PREngineer                 #
#   Publisher: Jorge Pabón                                       #
#     License: Non-Commercial Use - Free of Charge               #
#              ------------------------------------------------- #
#              Commercial use - Reach out to author for          #
#              licensing fees.                                   #
##################################################################

################### VARIABLES ###################

# Location where we are executing
SCRIPTPATH=$(pwd)

# Color definition variables
BLACK='\e[0m'
CYAN='\e[36m'
YELLOW='\e[33m'
RED='\e[31m'
GREEN='\e[32m'
MAGENTA='\e[35m'

################### FUNCTIONS ###################

# This function is used to disable a Platform configuration
disablePlatform(){
  showHeader disablePlatform

  echo
  echo ' Available streaming platforms:'
  echo ' 1. YouTube'
  echo ' 2. Twitch'
  echo ' 3. Trovo'
  echo ' 4. Kick'
  echo ' 5. Facebook'
  echo ' 6. Instagram'
  echo ' 7. Cloudflare'
  echo -e $YELLOW
  read -p " Which streaming platform do you want to disable?: " PLATFORM
  while [ $PLATFORM != 1 ] && [ $PLATFORM != 2 ] && [ $PLATFORM != 3 ] && [ $PLATFORM != 4 ] && [ $PLATFORM != 5 ] && [ $PLATFORM != 6 ] && [ $PLATFORM != 7 ]
  do
    echo -e $RED "[!] - Invalid option provided!" $YELLOW
    read -p " Which streaming platform do you want to disable?: " PLATFORM
  done

  echo -e $MAGENTA
  echo " Disabling streaming platform ..."
  echo
  if [ $PLATFORM == 1 ]; then
    sed -i "/# YouTubeDetails/c\\      # YouTubeDetails" "/etc/nginx/nginx.conf"
    sed -i "/YouTube/c\\YouTube=No" "RPi-StreamBox.conf"
  fi
  if [ $PLATFORM == 2 ]; then
    sed -i "/# TwitchDetails/c\\      # TwitchDetails" "/etc/nginx/nginx.conf"
    sed -i "/Twitch/c\\Twitch=No" "RPi-StreamBox.conf"
  fi
  if [ $PLATFORM == 3 ]; then
    sed -i "/# TrovoDetails/c\\      # TrovoDetails" "/etc/nginx/nginx.conf"
    sed -i "/Trovo/c\\Trovo=No" "RPi-StreamBox.conf"
  fi
  if [ $PLATFORM == 4 ]; then
    sed -i "/# KickDetails/c\\      # KickDetails" "/etc/nginx/nginx.conf"
    sed -i "/Kick/c\\Kick=No" "RPi-StreamBox.conf"
  fi
  if [ $PLATFORM == 5 ]; then
    sed -i "/# FacebookDetails/c\\      # FacebookDetails" "/etc/nginx/nginx.conf"
    sed -i "/Facebook/c\\Facebook=No" "RPi-StreamBox.conf"
  fi
  if [ $PLATFORM == 6 ]; then
    sed -i "/# InstagramDetails/c\\      # InstagramDetails" "/etc/nginx/nginx.conf"
    sed -i "/Instagram/c\\Instagram=No" "RPi-StreamBox.conf"
  fi
  if [ $PLATFORM == 7 ]; then
    sed -i "/# CloudflareDetails/c\\      # CloudflareDetails" "/etc/nginx/nginx.conf"
    sed -i "/Cloudflare/c\\Cloudflare=No" "RPi-StreamBox.conf"
  fi
  
  echo -e $MAGENTA
  echo " Restarting Nginx ..."
  echo
  service nginx restart > /dev/null & showSpinner

  echo
  echo -e $GREEN "Platform has been disabled!"
  echo -e $YELLOW
  
  read -p " Do you need to disable another Platform ? [y/n] " CHECK
  if [ $CHECK == 'y' ] || [ $CHECK == 'Y' ]; then
    disablePlatform
  fi

  promptForEnter
  mainMenu
}

# This function is used to install Rpi-StreamBox
install(){
  showHeader install

  ################### Part 1 - Update and install dependencies ###################
  echo
  echo -e $MAGENTA "Updating list of packages ..." $BLACK
  echo
  apt-get update -y > /dev/null & showSpinner
  if [ $? -ne 0 ]; then
    echo
    echo -e $RED "[!] An error occurred while updating the package indexes!" $BLACK
    exit 1
  fi

  echo
  echo -e $MAGENTA "Upgrading packages ..." $BLACK
  echo
  apt-get upgrade -y > /dev/null & showSpinner
  if [ $? -ne 0 ]; then
    echo
    echo -e $RED "[!] An error occurred while upgrading the packages!" $BLACK
    exit 1
  fi

  echo
  echo -e $MAGENTA "Upgrading system ..." $BLACK
  echo
  apt-get dist-upgrade -y > /dev/null & showSpinner
  if [ $? -ne 0 ]; then
    echo
    echo -e $RED "[!] An error occurred while upgrading the system!" $BLACK
    exit 1
  fi

  ################### Part 3 - Download and Install Nginx ###################

  echo
  echo -e $MAGENTA "Installing Nginx dependencies ..." $BLACK
  echo
  apt-get install -y git build-essential ffmpeg libpcre3 libpcre3-dev libssl-dev zlib1g-dev stunnel4 > /dev/null & showSpinner

  echo
  echo -e $MAGENTA "Grabbing latest Nginx RTMP module ..." $BLACK
  echo
  git clone https://github.com/sergey-dryabzhinsky/nginx-rtmp-module.git

  echo -e $YELLOW
  echo ' Visit the following URL to determine the nginx version that you want to install:'
  echo '   https://nginx.org/download/'

  read -p " Which version do you want to install? [ e.g. nginx-1.23.4 ] : " VERSION

  showHeader install

  echo
  echo -e $MAGENTA "Downloading $VERSION source files ..." $BLACK
  echo
  wget -q http://nginx.org/download/$VERSION.tar.gz > /dev/null & showSpinner

  echo
  echo -e $MAGENTA "Extracting Nginx source files ..." $BLACK
  echo
  tar -xf $VERSION.tar.gz > /dev/null & showSpinner
  cd $VERSION

  echo
  echo -e $MAGENTA "Configuring Nginx for compilation ..." $BLACK
  echo
  ./configure --prefix=/usr/share/nginx \
              --sbin-path=/usr/sbin/nginx \
              --modules-path=/usr/lib/nginx/modules \
              --add-module=../nginx-rtmp-module \
              --conf-path=/etc/nginx/nginx.conf \
              --error-log-path=/var/log/nginx/error.log \
              --http-log-path=/var/log/nginx/access.log \
              --pid-path=/run/nginx.pid \
              --lock-path=/var/lock/nginx.lock \
              --user=www-data \
              --group=www-data \
              --http-client-body-temp-path=/var/lib/nginx/body \
              --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
              --http-proxy-temp-path=/var/lib/nginx/proxy \
              --http-scgi-temp-path=/var/lib/nginx/scgi \
              --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
              --with-compat \
              --with-file-aio \
              --with-threads \
              --with-http_addition_module \
              --with-http_auth_request_module \
              --with-http_dav_module \
              --with-http_flv_module \
              --with-http_gunzip_module \
              --with-http_gzip_static_module \
              --with-http_mp4_module \
              --with-http_random_index_module \
              --with-http_realip_module \
              --with-http_slice_module \
              --with-http_ssl_module \
              --with-http_sub_module \
              --with-http_stub_status_module \
              --with-http_v2_module \
              --with-http_secure_link_module \
              --with-mail \
              --with-mail_ssl_module \
              --with-stream \
              --with-stream_realip_module \
              --with-stream_ssl_module \
              --with-stream_ssl_preread_module > /dev/null & showSpinner

  echo
  echo -e $MAGENTA "Compiling Nginx ..." $BLACK
  echo
  make -j 1 > /dev/null & showSpinner

  echo
  echo -e $MAGENTA "Install Nginx ..." $BLACK
  echo
  make install > /dev/null & showSpinner

  echo
  echo -e $MAGENTA "Removing unused packages and cleaning up downloads ..." $BLACK
  echo
  apt-get autoremove -y > /dev/null & showSpinner
  rm -R $SCRIPTPATH/nginx*

  echo
  echo -e $MAGENTA "Creating Nginx service definition ..." $BLACK
  echo
  echo '[Unit]' > /etc/systemd/system/nginx.service
  echo 'Description=A high performance web server and a reverse proxy server' >> /etc/systemd/system/nginx.service
  echo 'After=network.target' >> /etc/systemd/system/nginx.service
  echo ''>> /etc/systemd/system/nginx.service
  echo '[Service]' >> /etc/systemd/system/nginx.service
  echo 'Type=forking' >> /etc/systemd/system/nginx.service
  echo 'PIDFile=/run/nginx.pid' >> /etc/systemd/system/nginx.service
  echo "ExecStartPre=/usr/sbin/nginx -t -q -g 'daemon on; master_process on;'" >> /etc/systemd/system/nginx.service
  echo "ExecStart=/usr/sbin/nginx -g 'daemon on; master_process on;'" >> /etc/systemd/system/nginx.service
  echo "ExecReload=/usr/sbin/nginx -g 'daemon on; master_process on;' -s reload" >> /etc/systemd/system/nginx.service
  echo 'ExecStop=-/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile /run/nginx.pid' >> /etc/systemd/system/nginx.service
  echo 'TimeoutStopSec=5' >> /etc/systemd/system/nginx.service
  echo 'KillMode=mixed' >> /etc/systemd/system/nginx.service
  echo ''>> /etc/systemd/system/nginx.service
  echo '[Install]' >> /etc/systemd/system/nginx.service
  echo 'WantedBy=multi-user.target' >> /etc/systemd/system/nginx.service
  
  echo
  echo -e $MAGENTA "Set Nginx service to autostart ..." $BLACK
  echo
  systemctl enable nginx.service > /dev/null & showSpinner

  showHeader install

  ################### Part 4 - Creating Basic Config Files ###################

  echo -e $MAGENTA
  echo " Creating Nginx Configuration file /etc/nginx/nginx.conf ..."
  echo
  if [ ! -d /etc/nginx ]; then
    mkdir /etc/nginx
  fi
  echo 'worker_processes 2;' > /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf

  echo 'rtmp_auto_push on;' >> /etc/nginx/nginx.conf
  echo 'rtmp_auto_push_reconnect 1s;' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf

  echo 'events {' >> /etc/nginx/nginx.conf
  echo '  worker_connections  8192;' >> /etc/nginx/nginx.conf
  echo '}' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf
  
  echo 'rtmp {' >> /etc/nginx/nginx.conf
  echo '  server {' >> /etc/nginx/nginx.conf
  echo '    listen 1935;' >> /etc/nginx/nginx.conf
  echo '    chunk_size 4096;' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf
  
  echo '    # All Platforms' >> /etc/nginx/nginx.conf
  echo '    application all {' >> /etc/nginx/nginx.conf
  echo '      live on;' >> /etc/nginx/nginx.conf
  echo '      record off;' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf
  echo '      # YouTubeDetails' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf
  echo '      # TwitchDetails' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf
  echo '      # TrovoDetails' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf
  echo '      # KickDetails' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf
  echo '      # FacebookDetails' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf
  echo '      # InstagramDetails' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf
  echo '      # CloudflareDetails' >> /etc/nginx/nginx.conf
  echo '    }' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf

  echo '    # YouTube Only' >> /etc/nginx/nginx.conf
  echo '    application youtube {' >> /etc/nginx/nginx.conf
  echo '      live on;' >> /etc/nginx/nginx.conf
  echo '      record off;' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf
  echo '      # YouTubeDetails' >> /etc/nginx/nginx.conf
  echo '    }' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf

  echo '    # Twitch Only' >> /etc/nginx/nginx.conf
  echo '    application twitch {' >> /etc/nginx/nginx.conf
  echo '      live on;' >> /etc/nginx/nginx.conf
  echo '      record off;' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf
  echo '      # TwitchDetails' >> /etc/nginx/nginx.conf
  echo '    }' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf

  echo '    # Trovo Only' >> /etc/nginx/nginx.conf
  echo '    application trovo {' >> /etc/nginx/nginx.conf
  echo '      live on;' >> /etc/nginx/nginx.conf
  echo '      record off;' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf
  echo '      # TrovoDetails' >> /etc/nginx/nginx.conf
  echo '    }' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf

  echo '    # Kick Only' >> /etc/nginx/nginx.conf
  echo '    application kick {' >> /etc/nginx/nginx.conf
  echo '      live on;' >> /etc/nginx/nginx.conf
  echo '      record off;' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf
  echo '      # KickDetails' >> /etc/nginx/nginx.conf
  echo '    }' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf

  echo '    # Facebook Only' >> /etc/nginx/nginx.conf
  echo '    application facebook {' >> /etc/nginx/nginx.conf
  echo '      live on;' >> /etc/nginx/nginx.conf
  echo '      record off;' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf
  echo '      # FacebookDetails' >> /etc/nginx/nginx.conf
  echo '    }' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf

  echo '    # Instagram Only' >> /etc/nginx/nginx.conf
  echo '    application instagram {' >> /etc/nginx/nginx.conf
  echo '      live on;' >> /etc/nginx/nginx.conf
  echo '      record off;' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf
  echo '      # InstagramDetails' >> /etc/nginx/nginx.conf
  echo '    }' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf

  echo '    # Cloudflare Only' >> /etc/nginx/nginx.conf
  echo '    application cloudflare {' >> /etc/nginx/nginx.conf
  echo '      live on;' >> /etc/nginx/nginx.conf
  echo '      record off;' >> /etc/nginx/nginx.conf
  echo '' >> /etc/nginx/nginx.conf
  echo '      # CloudflareDetails' >> /etc/nginx/nginx.conf
  echo '    }' >> /etc/nginx/nginx.conf
  echo '  }' >> /etc/nginx/nginx.conf
  echo '}' >> /etc/nginx/nginx.conf
  
  echo -e $MAGENTA
  echo " Creating stunnel4 (Secure Tunnel) Configuration file /etc/default/stunnel4 ..."
  echo
  echo '# /etc/default/stunnel' > /etc/default/stunnel4
  echo '# Julien LEMOINE <speedblue@debian.org>' >> /etc/default/stunnel4
  echo '# September 2003' >> /etc/default/stunnel4
  echo '' >> /etc/default/stunnel4
  echo 'FILES="/etc/stunnel/*.conf"' >> /etc/default/stunnel4
  echo 'OPTIONS=""' >> /etc/default/stunnel4
  echo '' >> /etc/default/stunnel4
  echo '# Change to one to enable ppp restart scripts' >> /etc/default/stunnel4
  echo 'PPP_RESTART=0' >> /etc/default/stunnel4
  echo '' >> /etc/default/stunnel4
  echo '# Change to enable the setting of limits on the stunnel instances' >> /etc/default/stunnel4
  echo '# For example, to set a large limit on file descriptors (to enable' >> /etc/default/stunnel4
  echo '# more simultaneous client connections), set RLIMITS="-n 4096"' >> /etc/default/stunnel4
  echo '# More than one resource limit may be modified at the same time,' >> /etc/default/stunnel4
  echo '# e.g. RLIMITS="-n 4096 -d unlimited"' >> /etc/default/stunnel4
  echo 'RLIMITS=""' >> /etc/default/stunnel4
  echo '' >> /etc/default/stunnel4
  echo '# Enable the Secure Tunnel' >> /etc/default/stunnel4
  echo 'ENABLE=1' >> /etc/default/stunnel4
  
  echo -e $MAGENTA
  echo " Creating stunnel4 (Secure Tunnel 4) Configuration file /etc/stunnel/stunnel.conf ..."
  echo
  echo 'setuid = stunnel4' > /etc/stunnel/stunnel.conf
  echo 'setgid = stunnel4' >> /etc/stunnel/stunnel.conf
  echo 'pid=/tmp/stunnel.pid' >> /etc/stunnel/stunnel.conf
  echo 'output = /var/log/stunnel4/stunnel.log' >> /etc/stunnel/stunnel.conf
  echo 'include = /etc/stunnel/conf.d' >> /etc/stunnel/stunnel.conf

  echo -e $MAGENTA
  echo " Creating stunnel4 conf.d directory /etc/stunnel/conf.d ..."
  echo
  if [ ! -d /etc/stunnel/conf.d ]; then
    mkdir /etc/stunnel/conf.d
  fi

  echo -e $MAGENTA
  echo " Creating stunnel4 Facebook Configuration file /etc/stunnel/conf.d/facebook.conf ..."
  echo
  echo '[facebook]' > /etc/stunnel/conf.d/facebook.conf
  echo 'client=yes' >> /etc/stunnel/conf.d/facebook.conf
  echo 'accept=127.0.0.1:19350' >> /etc/stunnel/conf.d/facebook.conf
  echo 'connect=live-api-s.facebook.com:443' >> /etc/stunnel/conf.d/facebook.conf
  echo 'PSKsecrets=/etc/stunnel/psk-secret.txt' >> /etc/stunnel/conf.d/facebook.conf
  
  echo -e $MAGENTA
  echo " Creating stunnel4 Instagram Configuration file /etc/stunnel/conf.d/instagram.conf ..."
  echo
  echo '[instagram]' > /etc/stunnel/conf.d/instagram.conf
  echo 'client=yes' >> /etc/stunnel/conf.d/instagram.conf
  echo 'accept=127.0.0.1:19351' >> /etc/stunnel/conf.d/instagram.conf
  echo 'connect=live-upload.instagram.com:443' >> /etc/stunnel/conf.d/instagram.conf
  echo 'PSKsecrets=/etc/stunnel/psk-secret.txt' >> /etc/stunnel/conf.d/instagram.conf
  
  echo -e $MAGENTA
  echo " Creating stunnel4 Cloudflare Configuration file /etc/stunnel/conf.d/cloudflare.conf ..."
  echo
  echo '[cloudflare]' > /etc/stunnel/conf.d/cloudflare.conf
  echo 'client=yes' >> /etc/stunnel/conf.d/cloudflare.conf
  echo 'accept=127.0.0.1:19352' >> /etc/stunnel/conf.d/cloudflare.conf
  echo 'connect=live.cloudflare.com:443' >> /etc/stunnel/conf.d/cloudflare.conf
  echo 'PSKsecrets=/etc/stunnel/psk-secret.txt' >> /etc/stunnel/conf.d/cloudflare.conf
  
  echo -e $MAGENTA
  echo " Creating stunnel4 Kick Configuration file /etc/stunnel/conf.d/kick.conf ..."
  echo
  echo '[kick]' > /etc/stunnel/conf.d/kick.conf
  echo 'client=yes' >> /etc/stunnel/conf.d/kick.conf
  echo 'accept=127.0.0.1:19353' >> /etc/stunnel/conf.d/kick.conf
  echo 'connect=fa723fc1b171.global-contribute.live-video.net:443' >> /etc/stunnel/conf.d/kick.conf
  echo 'PSKsecrets=/etc/stunnel/psk-secret.txt' >> /etc/stunnel/conf.d/kick.conf

  echo -e $MAGENTA
  echo " Creating stunnel4 YouTube Configuration file /etc/stunnel/conf.d/youtube.conf ..."
  echo
  echo '[youtube]' > /etc/stunnel/conf.d/youtube.conf
  echo 'client=yes' >> /etc/stunnel/conf.d/youtube.conf
  echo 'accept=127.0.0.1:19354' >> /etc/stunnel/conf.d/youtube.conf
  echo 'connect=a.rtmps.youtube.com:443' >> /etc/stunnel/conf.d/youtube.conf
  echo 'PSKsecrets=/etc/stunnel/psk-secret.txt' >> /etc/stunnel/conf.d/youtube.conf

  #########################################################################
  # As of 2023-04-09, Twitch and Trovo don't have RTMPS ingest servers :( #
  #########################################################################

  echo -e $MAGENTA
  echo " Creating stunnel4 Twitch Configuration file /etc/stunnel/conf.d/twitch.conf ..."
  echo
  echo '[twitch]' > /etc/stunnel/conf.d/twitch.conf
  echo 'client=yes' >> /etc/stunnel/conf.d/twitch.conf
  echo 'accept=127.0.0.1:19355' >> /etc/stunnel/conf.d/twitch.conf
  echo 'connect=iad05.contribute.live-video.net:443' >> /etc/stunnel/conf.d/twitch.conf
  echo 'PSKsecrets=/etc/stunnel/psk-secret.txt' >> /etc/stunnel/conf.d/twitch.conf

  echo -e $MAGENTA
  echo " Creating stunnel4 Trovo Configuration file /etc/stunnel/conf.d/trovo.conf ..."
  echo
  echo '[trovo]' > /etc/stunnel/conf.d/trovo.conf
  echo 'client=yes' >> /etc/stunnel/conf.d/trovo.conf
  echo 'accept=127.0.0.1:19356' >> /etc/stunnel/conf.d/trovo.conf
  echo 'connect=livepush.trovo.live:443' >> /etc/stunnel/conf.d/trovo.conf
  echo 'PSKsecrets=/etc/stunnel/psk-secret.txt' >> /etc/stunnel/conf.d/trovo.conf

  read -p " Provide a secret username for the connections: " USER
  echo
  read -s -p " Provide a secret password for the connections [Must be pretty long or stunnel will not run] : " PASS
  echo -e $MAGENTA
  echo " Creating psk-secret.txt file for the connections ..."
  echo
  echo "$USER:$PASS" > /etc/stunnel/psk-secret.txt
  chmod 0400 /etc/stunnel/psk-secret.txt

  echo -e $MAGENTA
  echo " Creating RPi-Streambox platform status file $SCRIPTPATH/RPi-StreamBox.conf ..."
  echo
  echo 'YouTube=No' > $SCRIPTPATH/RPi-StreamBox.conf
  echo 'Twitch=No' >> $SCRIPTPATH/RPi-StreamBox.conf
  echo 'Trovo=No' >> $SCRIPTPATH/RPi-StreamBox.conf
  echo 'Kick=No' >> $SCRIPTPATH/RPi-StreamBox.conf
  echo 'Facebook=No' >> $SCRIPTPATH/RPi-StreamBox.conf
  echo 'Instagram=No' >> $SCRIPTPATH/RPi-StreamBox.conf
  echo 'Cloudflare=No' >> $SCRIPTPATH/RPi-StreamBox.conf

  echo
  echo -e $MAGENTA "Making sure Nginx and Stunnel start on boot ..." $BLACK
  echo
  systemctl enable nginx
  systemctl enable stunnel4
  
  echo
  echo -e $MAGENTA "Starting Nginx ..." $BLACK
  echo
  service nginx start > /dev/null & showSpinner

  echo -e $GREEN
  echo " Installation completed!"
  echo -e $RED
  echo ' Now, you need to configure the platforms to use.'
  echo
  
  promptForEnter
  mainMenu
}

# This function is used to display the menu
mainMenu(){
  # Clean the screen
  showHeader

  echo
  echo -e $CYAN"Welcome to Rpi-StreamBox!"
  echo
  echo -e " ----------------------------------------- What do you want to do? -----------------------------------------"
  echo -e " 1) Install RPi-StreamBox"
  echo -e " 2) Uninstall RPi-StreamBox"
  echo -e " 3) Update Platform Details (URL & Key)"
  echo -e " 4) View Enabled Platforms"
  echo -e " 5) Disable Platform"
  echo -e " --------------------------------------------- Done For Now ------------------------------------------------"
  echo -e "q) Quit"
  echo

  echo -e $YELLOW
  read -p "What would you like to do? : " CHOICE
  echo -e $BLACK

  case $CHOICE in
    1)
      install
      ;;
    2)
      uninstall
      ;;
    3)
      updatePlatform
      ;;
    4)
      viewPlatforms
      ;;
    5)
      disablePlatform
      ;;
    q | Q)
      clear
      exit 0
      ;;
    *)
      mainMenu
    ;;
  esac
}

# This function prompts for enter to continue
promptForEnter(){
  echo -e $YELLOW
  read -p " Press [Enter] to continue: "
}

# This function clears the screen and shows the header
showHeader(){
  # Clean the screen
  clear

  # Display the Title Information
  echo
  echo -e $CYAN
  echo '╔═════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗'
  echo '║   8888888b.           d8b        .d8888b.  888                                           888888b.                       ║'
  echo '║   888   Y88b          Y8P       d88P  Y88b 888                                           888  "88b                      ║'
  echo '║   888    888                    Y88b.      888                                           888  .88P                      ║'
  echo '║   888   d88P 88888b.  888        "Y888b.   888888 888d888 .d88b.   8888b.  88888b.d88b.  8888888K.   .d88b.  888  888   ║'
  echo '║   8888888P"  888 "88b 888           "Y88b. 888    888P"  d8P  Y8b     "88b 888 "888 "88b 888  "Y88b d88""88b `Y8bd8P    ║'
  echo '║   888 T88b   888  888 888 888888      "888 888    888    88888888 .d888888 888  888  888 888    888 888  888   X88K     ║'
  echo '║   888  T88b  888 d88P 888       Y88b  d88P Y88b.  888    Y8b.     888  888 888  888  888 888   d88P Y88..88P .d8""8b.   ║'
  echo '║   888   T88b 88888P"  888        "Y8888P"   "Y888 888     "Y8888  "Y888888 888  888  888 8888888P"   "Y88P"  888  888   ║'
  echo '║              888                                                                                                        ║'
  echo '║              888                                                                                                        ║'
  echo '║              888                                                                                                        ║'
       
  case $1 in
    "install")
      echo "║───────────────────────────────────────────────────────────────────────────────────────────────────────────────Installer─║"
      ;;

    "uninstall")
      echo "║────────────────────────────────────────────────────────────────────────────────────────────────────────────Un-Installer─║"
      ;;

    "updatePlatform")
      echo "║───────────────────────────────────────────────────────────────────────────────────────────────Update Streaming Platform─║"
      ;;

    "viewPlatforms")
      echo "║────────────────────────────────────────────────────────────────────────────────────────View Enabled Streaming Platforms─║"
      ;;

    "disablePlatform")
      echo "║──────────────────────────────────────────────────────────────────────────────────────────────Disable Streaming Platform─║"
      ;;
    
    *)
      echo "║───────────────────────────────────────────────────────────────────────────────────────────────────────────────Main Menu─║"
    ;;
  esac

  echo -e "║                                        $RED(+) $RED(+) $RED(+)  SHHH! WE ARE LIVE!  $RED(+) $RED(+) $RED(+)          $CYAN                           ║"
  echo '╚═════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝'
  echo '                                                                              Brought to you by Jorge Pabon (PREngineer)   '
  echo
}

# Helper function to show progress
showSpinner(){
  # Grab the process id of the previous command
  pid=$!

  # Characters of the spinner
  spin='-\|/'

  i=0

  # Run until it stops
  while [ -d /proc/$pid ]
  do
    i=$(( (i+1) %4 ))
    printf "\r${spin:$i:1}"
    sleep .2
  done
}

# This function is used to uninstall Rpi-StreamBox
uninstall(){
  showHeader uninstall

  echo -e $MAGENTA
  echo " Stopping the Nginx service ..."
  echo
  service nginx stop > /dev/null & showSpinner
  
  echo -e $MAGENTA
  echo " Removing Nginx service ..."
  echo
  systemctl disable nginx.service > /dev/null & showSpinner
  rm /etc/systemd/system/nginx.service > /dev/null & showSpinner

  echo -e $MAGENTA
  echo " Uninstalling Nginx ..."
  echo
  if [ -d /etc/nginx ]; then
    rm -R /etc/nginx > /dev/null & showSpinner
  fi

  echo
  echo -e $MAGENTA "Uninstalling dependencies ..." $BLACK
  echo
  apt-get purge -y stunnel4 > /dev/null & showSpinner
  
  echo
  echo -e $MAGENTA "Removing unused packages ..." $BLACK
  echo
  apt-get autoremove -y > /dev/null & showSpinner

  echo
  echo -e $MAGENTA "Removing leftover files ..." $BLACK
  echo
  if [ -d /usr/share/nginx ]; then
    rm -R /usr/share/nginx > /dev/null & showSpinner
  fi
  if [ -f /usr/sbin/nginx ]; then
    rm -R /usr/sbin/nginx > /dev/null & showSpinner
  fi
  if [ -d /usr/lib/nginx ]; then
    rm -R /usr/lib/nginx > /dev/null & showSpinner
  fi
  if [ -d /var/log/nginx ]; then
    rm -R /var/log/nginx > /dev/null & showSpinner
  fi
  if [ -f /run/nginx.pid ]; then
    rm -R /run/nginx.pid > /dev/null & showSpinner
  fi
  if [ -d /var/lock/nginx ]; then
    rm -R /var/lock/nginx > /dev/null & showSpinner
  fi
  if [ -d /etc/stunnel ]; then
    rm -R /etc/stunnel > /dev/null & showSpinner
  fi

  rm -R $SCRIPTPATH/nginx*
  rm $SCRIPTPATH/RPi-StreamBox.conf

  echo
  echo -e $GREEN "Uninstall complete!" $BLACK
  echo
  
  promptForEnter
  mainMenu
}

# This function updates the configuration of a Platform
updatePlatform(){
  showHeader updatePlatform

  echo
  echo ' Available streaming platforms:'
  echo ' 1. YouTube'
  echo ' 2. Twitch'
  echo ' 3. Trovo'
  echo ' 4. Kick'
  echo ' 5. Facebook'
  echo ' 6. Instagram'
  echo ' 7. Cloudflare'
  echo -e $YELLOW
  read -p " Which streaming platform do you want to update?: " PLATFORM
  while [ $PLATFORM != 1 ] && [ $PLATFORM != 2 ] && [ $PLATFORM != 3 ] && [ $PLATFORM != 4 ] && [ $PLATFORM != 5 ] && [ $PLATFORM != 6 ] && [ $PLATFORM != 7 ]
  do
    echo -e $RED "[!] - Invalid option provided!" $YELLOW
    read -p " Which streaming platform do you want to update?: " PLATFORM
  done

  # Prompt for URLs
  if [ $PLATFORM == 1 ]; then
    read -p " Please provide the YouTube Streaming URL [ e.g. rtmp://a.rtmp.youtube.com/live2/ ]: " URL
  fi
  if [ $PLATFORM == 2 ]; then
    read -p " Please provide the Twitch Streaming URL [ e.g. rtmp://iad03.contribute.live-video.net/app/ ]: " URL
  fi
  if [ $PLATFORM == 3 ]; then
    read -p " Please provide the Trovo Streaming URL [ e.g. rtmp://livepush.trovo.live/live/ ]: " URL
  fi
  if [ $PLATFORM == 4 ]; then
    read -p " Please provide the Kick Streaming URL [ e.g. rtmps://fa723fc1b171.global-contribute.live-video.net/app/ ]: " URL
  fi
  if [ $PLATFORM == 5 ]; then
    read -p " Please provide the Facebook Streaming URL [ e.g. rtmps://live-api-s.facebook.com/rtmp/ ]: " URL
  fi
  if [ $PLATFORM == 6 ]; then
    read -p " Please provide the Instagram Streaming URL [ e.g. rtmps://live-upload.instagram.com/rtmp/ ]: " URL
  fi
  if [ $PLATFORM == 7 ]; then
    read -p " Please provide the Cloudflare Streaming URL [ e.g. rtmps://live.cloudflare.com/live/ ]: " URL
  fi

  # Prompt for Tunnel or not
  echo -e $RED
  echo '-------------------------------------------------------------------------'
  echo ' NOTE: As of 2023/04/09 Twitch and Trovo do not support Secure RTMP.'
  echo ' If, by the time you use this, they make it available; please submit'
  echo ' an issue in Github so that I can fix it.  Please, provide the new'
  echo ' secure URL in the issue.'
  echo '-------------------------------------------------------------------------'
  echo -e $YELLOW
  read -p " Is this a secure URL (RTMPS)? : [ y/n ] " SECURE
  while [ $SECURE != 'y' ] && [ $SECURE != 'Y' ] && [ $SECURE != 'n' ] && [ $SECURE != 'N' ]
  do
    echo -e $RED "[!] - Invalid option provided!" $YELLOW
    read -p " Is this a secure URL (RTMPS)? [ y/n ] :" SECURE
    echo
  done
  
  # Prompt for Keys
  if [ $PLATFORM == 1 ]; then
    read -p " Please provide the YouTube Stream Key: " KEY
  fi
  if [ $PLATFORM == 2 ]; then
    read -p " Please provide the Twitch Stream Key: " KEY
  fi
  if [ $PLATFORM == 3 ]; then
    read -p " Please provide the Trovo Stream Key: " KEY
  fi
  if [ $PLATFORM == 4 ]; then
    read -p " Please provide the Kick Stream Key: " KEY
  fi
  if [ $PLATFORM == 5 ]; then
    read -p " Please provide the Facebook Stream Key: " KEY
  fi
  if [ $PLATFORM == 6 ]; then
    read -p " Please provide the Instagram Stream Key: " KEY
  fi
  if [ $PLATFORM == 7 ]; then
    read -p " Please provide the Cloudflare Stream Key: " KEY
  fi

  echo -e $MAGENTA
  echo " Updating configuration ..."
  echo
  # YouTube
  if [ $PLATFORM == 1 ]; then
    if [ $SECURE == 'n' ] || [ $SECURE == 'N' ]; then
      echo -e $YELLOW " - Pointing Nginx to YouTube's RTMP URL:"
      echo "    $URL$KEY"
      sed -i "/# YouTubeDetails/c\\      push $URL$KEY; # YouTubeDetails" "/etc/nginx/nginx.conf"
    else
      NGINXURL=rtmp://127.0.0.1:19354/live2/
      echo -e $YELLOW ' - Pointing Nginx to the local Secure Tunnel here:'
      echo "    $NGINXURL"
      echo
      sed -i "/# YouTubeDetails/c\\      push $NGINXURL$KEY; # YouTubeDetails" "/etc/nginx/nginx.conf"
      STUNNELURL=$(echo $URL | awk -F "/" '{print $3}')
      echo -e $YELLOW ' - Pointing Secure Tunnel to YouTube here:'
      echo "    $STUNNELURL:443"
      sed -i "/connect=/c\\connect=$STUNNELURL:443" "/etc/stunnel/conf.d/youtube.conf"
    fi
    sed -i "/YouTube/c\\YouTube=Yes" $SCRIPTPATH/RPi-StreamBox.conf
  fi
  # Twitch
  if [ $PLATFORM == 2 ]; then
    if [ $SECURE == 'n' ] || [ $SECURE == 'N' ]; then
      echo -e $YELLOW " - Pointing Nginx to Twitch's RTMP URL:"
      echo "    $URL$KEY"
      sed -i "/# TwitchDetails/c\\      push $URL$KEY; # TwitchDetails" "/etc/nginx/nginx.conf"
    else
      NGINXURL=rtmp://127.0.0.1:19355/app/
      echo -e $YELLOW ' - Pointing Nginx to the local Secure Tunnel here:'
      echo "    $NGINXURL"
      echo
      sed -i "/# TwitchDetails/c\\      push $NGINXURL$KEY; # TwitchDetails" "/etc/nginx/nginx.conf"
      STUNNELURL=$(echo $URL | awk -F "/" '{print $3}')
      echo -e $YELLOW ' - Pointing Secure Tunnel to Twitch here:'
      echo "    $STUNNELURL:443"
      sed -i "/connect=/c\\connect=$STUNNELURL:443" "/etc/stunnel/conf.d/twitch.conf"
    fi
    sed -i "/Twitch/c\\Twitch=Yes" $SCRIPTPATH/RPi-StreamBox.conf
  fi
  # Trovo
  if [ $PLATFORM == 3 ]; then
    if [ $SECURE == 'n' ] || [ $SECURE == 'N' ]; then
      echo -e $YELLOW " - Pointing Nginx to Trovo's RTMP URL:"
      echo "    $URL$KEY"
      sed -i "/# TrovoDetails/c\\      push $URL$KEY; # TrovoDetails" "/etc/nginx/nginx.conf"
    else
      NGINXURL=rtmp://127.0.0.1:19356/live/
      echo -e $YELLOW ' - Pointing Nginx to the local Secure Tunnel here:'
      echo "    $NGINXURL"
      echo
      sed -i "/# TrovoDetails/c\\      push $NGINXURL$KEY; # TrovoDetails" "/etc/nginx/nginx.conf"
      STUNNELURL=$(echo $URL | awk -F "/" '{print $3}')
      echo -e $YELLOW ' - Pointing Secure Tunnel to Trovo here:'
      echo "    $STUNNELURL:443"
      sed -i "/connect=/c\\connect=$STUNNELURL:443" "/etc/stunnel/conf.d/trovo.conf"
    fi
    sed -i "/Trovo/c\\Trovo=Yes" $SCRIPTPATH/RPi-StreamBox.conf
  fi
  # Kick
  if [ $PLATFORM == 4 ]; then
    if [ $SECURE == 'n' ] || [ $SECURE == 'N' ]; then
      echo -e $YELLOW " - Pointing Nginx to Kick's RTMP URL:"
      echo "    $URL$KEY"
      sed -i "/# KickDetails/c\\      push $URL$KEY; # KickDetails" "/etc/nginx/nginx.conf"
    else
      NGINXURL=rtmp://127.0.0.1:19353/app/
      echo -e $YELLOW ' - Pointing Nginx to the local Secure Tunnel here:'
      echo "    $NGINXURL"
      echo
      sed -i "/# KickDetails/c\\      push $NGINXURL$KEY; # KickDetails" "/etc/nginx/nginx.conf"
      STUNNELURL=$(echo $URL | awk -F "/" '{print $3}')
      echo -e $YELLOW ' - Pointing Secure Tunnel to Kick here:'
      echo "    $STUNNELURL:443"
      sed -i "/connect=/c\\connect=$STUNNELURL:443" "/etc/stunnel/conf.d/kick.conf"
    fi
    sed -i "/Kick/c\\Kick=Yes" $SCRIPTPATH/RPi-StreamBox.conf
  fi
  # Facebook
  if [ $PLATFORM == 5 ]; then
    if [ $SECURE == 'n' ] || [ $SECURE == 'N' ]; then
      echo -e $YELLOW " - Pointing Nginx to Facebook's RTMP URL:"
      echo "    $URL$KEY"
      sed -i "/# FacebookDetails/c\\      push $URL$KEY; # FacebookDetails" "/etc/nginx/nginx.conf"
    else
      NGINXURL=rtmp://127.0.0.1:19350/rtmp/
      echo -e $YELLOW ' - Pointing Nginx to the local Secure Tunnel here:'
      echo "    $NGINXURL"
      echo
      sed -i "/# FacebookDetails/c\\      push $NGINXURL$KEY; # FacebookDetails" "/etc/nginx/nginx.conf"
      STUNNELURL=$(echo $URL | awk -F "/" '{print $3}')
      echo -e $YELLOW ' - Pointing Secure Tunnel to Facebook here:'
      echo "    $STUNNELURL:443"
      sed -i "/connect=/c\\connect=$STUNNELURL:443" "/etc/stunnel/conf.d/facebook.conf"
    fi
    sed -i "/Facebook/c\\Facebook=Yes" $SCRIPTPATH/RPi-StreamBox.conf
  fi
  # Instagram
  if [ $PLATFORM == 6 ]; then
    if [ $SECURE == 'n' ] || [ $SECURE == 'N' ]; then
      echo -e $YELLOW " - Pointing Nginx to Instagram's RTMP URL:"
      echo "    $URL$KEY"
      sed -i "/# InstagramDetails/c\\      push $URL$KEY; # InstagramDetails" "/etc/nginx/nginx.conf"
    else
      NGINXURL=rtmp://127.0.0.1:19351/rtmp/
      echo -e $YELLOW ' - Pointing Nginx to the local Secure Tunnel here:'
      echo "    $NGINXURL"
      echo
      sed -i "/# InstagramDetails/c\\      push $NGINXURL$KEY; # InstagramDetails" "/etc/nginx/nginx.conf"
      STUNNELURL=$(echo $URL | awk -F "/" '{print $3}')
      echo -e $YELLOW ' - Pointing Secure Tunnel to Instagram here:'
      echo "    $STUNNELURL:443"
      sed -i "/connect=/c\\connect=$STUNNELURL:443" "/etc/stunnel/conf.d/instagram.conf"
    fi
    sed -i "/Instagram/c\\Instagram=Yes" $SCRIPTPATH/RPi-StreamBox.conf
  fi
  # Cloudflare
  if [ $PLATFORM == 7 ]; then
    if [ $SECURE == 'n' ] || [ $SECURE == 'N' ]; then
      echo -e $YELLOW " - Pointing Nginx to Cloudflare's RTMP URL:"
      echo "    $URL$KEY"
      sed -i "/# CloudflareDetails/c\\      push $URL$KEY; # CloudflareDetails" "/etc/nginx/nginx.conf"
    else
      NGINXURL=rtmp://127.0.0.1:19351/rtmp/
      echo -e $YELLOW ' - Pointing Nginx to the local Secure Tunnel here:'
      echo "    $NGINXURL"
      echo
      sed -i "/# CloudflareDetails/c\\      push $NGINXURL$KEY; # CloudflareDetails" "/etc/nginx/nginx.conf"
      STUNNELURL=$(echo $URL | awk -F "/" '{print $3}')
      echo -e $YELLOW ' - Pointing Secure Tunnel to Cloudflare here:'
      echo "    $STUNNELURL:443"
      sed -i "/connect=/c\\connect=$STUNNELURL:443" "/etc/stunnel/conf.d/cloudflare.conf"
    fi
    sed -i "/Cloudflare/c\\Cloudflare=Yes" $SCRIPTPATH/RPi-StreamBox.conf
  fi
  
  echo -e $MAGENTA
  echo " Restarting stunnel and Nginx ..."
  echo
  service stunnel4 restart > /dev/null & showSpinner
  service nginx restart > /dev/null & showSpinner

  echo
  echo -e $GREEN "Platform has been updated!"
  echo -e $YELLOW
  
  read -p " Do you need to update another Platform ? [y/n] " CHECK
  if [ $CHECK == 'y' ] || [ $CHECK == 'Y' ]; then
    updatePlatform
  fi

  promptForEnter
  mainMenu
}

# This function is used to view the enabled Platforms
viewPlatforms(){
  showHeader viewPlatforms

  echo -e $CYAN
  echo ' The current status of Streaming Platform configurations is as follows:'
  echo

  cat RPi-StreamBox.conf | sed 's/=/: /g'

  promptForEnter
  mainMenu
}

################### EXECUTION ###################

# Validate that this script is run as root
if [ $(id -u) -ne 0 ]; then
  echo -e $RED "[!] Error: You must run RPi-StreamBox as root user, like this: sudo $SCRIPTPATH/RPi-StreamBox.sh or sudo $0" $BLACK
  echo
  exit 1
fi

# Start with the main menu
mainMenu

exit 0
