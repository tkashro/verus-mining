#!/bin/sh

# Check if the architecture indicates 64-bit
arch=$(uname -m)
if [[ "$arch" == *64* ]]; then
    echo "System Architecture: $arch"
else
    echo "The system architecture is NOT 64-bit. Aborting."
    exit 1
fi

# Setup
pkg update -y
pkg upgrade -y
pkg install libjansson wget nano git screen jq openssh iproute2 -y

if [ ! -d ~/.ssh ]
then
  mkdir ~/.ssh
  chmod 0700 ~/.ssh
  cat << EOF > ~/.ssh/authorized_keys
ssh-rsa KEY_HERE>
EOF
  chmod 0600 ~/.ssh/authorized_keys
fi

# Create ccminer directory
if [ ! -d ~/ccminer ]
then
  mkdir ~/ccminer
fi
cd ~/ccminer

GITHUB_RELEASE_JSON=$(curl --silent "https://api.github.com/repos/tkashro/verus-mining/releases?per_page=1" | jq -c '[.[] | del (.body)]')
GITHUB_DOWNLOAD_URL=$(echo $GITHUB_RELEASE_JSON | jq -r ".[0].assets[0].browser_download_url")
GITHUB_DOWNLOAD_NAME=$(echo $GITHUB_RELEASE_JSON | jq -r ".[0].assets[0].name")

echo "Downloading latest pre-compiled version of CCminer: $GITHUB_DOWNLOAD_NAME"

wget ${GITHUB_DOWNLOAD_URL} -P ~/ccminer

if [ -f ~/ccminer/config.json ]
then
  INPUT=
  COUNTER=0
  while [ "$INPUT" != "y" ] && [ "$INPUT" != "n" ] && [ "$COUNTER" <= "10" ]
  do
    printf '"~/ccminer/config.json" already exists. Do you want to overwrite? (y/n) '
    read INPUT
    if [ "$INPUT" = "y" ]
    then
      echo "\noverwriting current \"~/ccminer/config.json\"\n"
      rm ~/ccminer/config.json
    elif [ "$INPUT" = "n" ] && [ "$COUNTER" = "10" ]
    then
      echo "saving as \"~/ccminer/config.json.#\""
    else
      echo 'Invalid input. Please answer with "y" or "n".\n'
      ((COUNTER++))
    fi
  done
fi

wget https://raw.githubusercontent.com/tkashro/verus-mining/refs/heads/master/config.json -P ~/ccminer

if [ -f ~/ccminer/ccminer ]
then
  mv ~/ccminer/ccminer ~/ccminer/ccminer_old
fi

mv ~/ccminer/${GITHUB_DOWNLOAD_NAME} ~/ccminer/ccminer
chmod +x ~/ccminer/ccminer

cat << EOF > ~/ccminer/start.sh
#!/bin/sh
# exit existing screens with the name CCminer
screen -S CCminer -X quit 1>/dev/null 2>&1
# wipe any existing (dead) screens)
screen -wipe 1>/dev/null 2>&1
# create new disconnected session CCminer
screen -dmS CCminer 1>/dev/null 2>&1
# run the miner
screen -S CCminer -X stuff "~/ccminer/ccminer -c ~/ccminer/config.json\n" 1>/dev/null 2>&1
printf '\nMining started.\n'
printf '===============\n'
printf '\nManual:\n'
printf 'start: ~/.ccminer/start.sh\n'
printf 'stop: screen -X -S CCminer quit\n'
printf '\nmonitor mining: screen -x CCminer\n'
printf "exit monitor: 'CTRL-a' followed by 'd'\n\n"
EOF

chmod +x start.sh

echo "===================================================="
echo "NOTE: DO NOT FORGET TO EDIT THE CCMINER CONFIG"
echo "Start the miner with \"cd ~/ccminer; ./start.sh\"."
echo "===================================================="
