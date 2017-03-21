#!/bin/bash
USERNAME=$1
PASSWORD=$2

validate()
{
  if [ -z $1 ]; then
    echo '[ERROR] Please specify embraer username and password'
    echo 'Usage: ./setup.sh <embraer-username> <embraer-password>'
    exit 1
  fi
}

validate $USERNAME
validate $PASSWORD

echo $USERNAME > credentials
echo $PASSWORD >> credentials

echo 'Credentials file created!'
echo 'Now run proxy start'

pwd=$(pwd)

sudo tee -a proxy \
<<EOF
#!/bin/bash
cd $pwd && ./proxy.sh start
EOF

sudo chmod +x proxy
sudo mv proxy /usr/local/bin/proxy
