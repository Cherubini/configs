#!/bin/bash
OPTION=$1

PROXY_PAC=http://proxy.sjk.emb/proxy.pac
HTTP_PROXY_HOST=lnx237in.sjk.emb
HTTP_PROXY_PORT=9090

HTTPS_PROXY_HOST=$HTTP_PROXY_HOST
HTTPS_PROXY_PORT=$HTTP_PROXY_PORT

#-------------------- Replace charters --------------------
replace() {
  str=$1
  find=$2
  replace=$3
  echo ${str//"$find"/$replace}
}

replace_pass() {
  str=$1
  str=$(replace "$str" "!" "%21")
  str=$(replace "$str" "#" "%23")
  str=$(replace "$str" "$" "%24")
  str=$(replace "$str" "&" "%26")
  str=$(replace "$str" "'" "%27")
  str=$(replace "$str" "(" "%28")
  str=$(replace "$str" ")" "%29")
  str=$(replace "$str" "*" "%2A")
  str=$(replace "$str" "+" "%2B")
  str=$(replace "$str" "," "%2C")
  str=$(replace "$str" "/" "%2F")
  str=$(replace "$str" ":" "%3A")
  str=$(replace "$str" ";" "%3B")
  str=$(replace "$str" "=" "%3D")
  str=$(replace "$str" "?" "%3F")
  str=$(replace "$str" "@" "%40")
	str=$(replace "$str" "*" "%2A")
  echo $str
}

CREDENTIALS_FILE=credentials
credentials() {
  i=0
  while IFS='' read -r line || [[ -n "$line" ]]; do
    if [ $i == 0 ]; then
      USER=$line
    fi
    if [ $i == 1 ]; then
      PASS=$line
    fi
    i=$((i+1))
  done < "$CREDENTIALS_FILE"
  PASS=$(replace_pass "$PASS")
}

#-------------------- Backup file --------------------
backup_file()
{
	if [ -f "$1" ];
	then
		sudo sed -i.bak '/http[s]::proxy/Id' "$1"
	fi
}

#-------------------- Gnome --------------------
start_gnome()
{
	gsettings set org.gnome.system.proxy mode auto
	gsettings set org.gnome.system.proxy autoconfig-url $PROXY_PAC
  gsettings set org.gnome.system.proxy ignore-hosts "['localhost', '127.0.0.0/8', '*.sjk.emb', '::1', '10.5.2.*', '*.embraer.com.br']"
  gsettings set org.gnome.system.proxy.http authentication-user $USER
  gsettings set org.gnome.system.proxy.http authentication-password $PASS
}

credentials
start_gnome
echo "ABC"
exit

stop_gnome()
{
	gsettings set org.gnome.system.proxy mode none
}

#-------------------- Docker --------------------
DOCKER_CONF_DIR=/etc/systemd/system/docker.service.d/
DOCKER_CONF_FILE=$DOCKER_CONF_DIR/http-proxy.conf
start_docker()
{
	sudo mkdir -p $DOCKER_CONF_DIR
	backup_file "$DOCKER_CONF_FILE"
	sudo tee -a "$DOCKER_CONF_FILE" \
<<EOF
[Service]
Environment="HTTP_PROXY=http://$USER:$PASS@$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/"
Environment="HTTPS_PROXY=http://$USER:$PASS@$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/"
EOF
	sudo systemctl daemon-reload
	sudo systemctl restart docker
}

stop_docker()
{
	sudo rm -rf $DOCKER_CONF_FILE
	sudo systemctl daemon-reload
	sudo systemctl restart docker
}

#-------------------- Apt --------------------
APT_FILE=/etc/apt/apt.conf
start_apt()
{
	backup_file "$APT_FILE"
	sudo tee -a "$APT_FILE" \
<<EOF
Acquire::http::proxy "http://$USER:$PASS@$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/";
Acquire::https::proxy "http://$USER:$PASS@$HTTPS_PROXY_HOST:$HTTPS_PROXY_PORT/";
EOF
}

stop_apt()
{
	sudo sed -i -e '/Acquire::http::proxy/d' "$APT_FILE"
}

#-------------------- Environment --------------------
ENVIRONMENT_FILE=/etc/environment
start_environment()
{
	backup_file "$ENVIRONMENT_FILE"
	sudo tee -a "$ENVIRONMENT_FILE" \
<<EOF
http_proxy="http://$USER:$PASS@$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/"
https_proxy="http://$USER:$PASS@$HTTPS_PROXY_HOST:$HTTPS_PROXY_PORT/"
EOF
}

stop_environment()
{
	sudo sed -i -e '/http_proxy/d' "$ENVIRONMENT_FILE"
	sudo sed -i -e '/https_proxy/d' "$ENVIRONMENT_FILE"
	unset http_proxy
	unset https_proxy
	export http_proxy=
	export https_proxy=
	http_proxy=
	https_proxy=
}

#-------------------- Git --------------------
GIT_FILE=~/.gitconfig
start_git()
{
	git config --global http.proxy http://$USER:$PASS@$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/
	git config --global https.proxy http://$USER:$PASS@$HTTPS_PROXY_HOST:$HTTPS_PROXY_PORT/
}

stop_git()
{
	backup_file "$GIT_FILE"
	git config --global --unset http.proxy
	git config --global --unset https.proxy
	sed -i -e '/http/d' "$GIT_FILE"
}

#-------------------- Node --------------------
start_node()
{
	sudo npm config set proxy http://$USER:$PASS@$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/
	sudo npm config set https-proxy http://$USER:$PASS@$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/
	npm config set proxy http://$USER:$PASS@$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/
	npm config set https-proxy http://$USER:$PASS@$HTTP_PROXY_HOST:$HTTP_PROXY_PORT/
}

stop_node()
{
	npm config delete proxy
	npm config delete https-proxy
}

#-------------------- Bower --------------------
BOWER_FILE=~/.bowerrc
start_bower()
{
	backup_file "$BOWER_FILE"
	touch $BOWER_FILE
	sudo tee -a "$BOWER_FILE" \
<<EOF
{
  "proxy": "http://$USER:$PASS@$HTTP_PROXY_HOST:$HTTP_PROXY_PORT",
  "https-proxy":"http://$USER:$PASS@$HTTP_PROXY_HOST:$HTTP_PROXY_PORT",
}
EOF
}

stop_bower()
{
	rm -rf $BOWER_FILE
}

#-----------------------------------------------------------------------------------------------------------------

proxy_start()
{
	start_gnome
	start_docker
	start_apt
	start_environment
	start_git
	start_node
	start_bower
}

proxy_stop()
{
	stop_gnome
	stop_docker
	stop_apt
	stop_environment
	stop_git
	stop_node
	stop_bower
}

proxy()
{
	case $OPTION in
		"start")
			echo "Setting proxy..."
			proxy_start
			echo "Done."
		;;
		"stop")
			echo "Unsetting proxy..."
			proxy_stop
			echo "Done."
		;;
		*)
			echo "Invalid option!"
			echo "Error."
		;;
	esac
}

# Main software
if [ -n "$OPTION" ];
then
  credentials
	proxy
else
	echo 'Option is null'
	echo 'Error.'
fi
exit
