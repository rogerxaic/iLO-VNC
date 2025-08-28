#! /usr/bin/env bash 

export SESSION_KEY=$(wget --no-check-certificate --post-data '{"method": "login", "user_login": "'$ILO_USER'", "password": "'$ILO_PASSWORD'"}' -q -O - https://$ILO_HOST/json/login_session | jq -r .session_key)
envsubst < iLO-jirc.jnlp.template > iLO-jirc.jnlp

javaws /iLO-jirc.jnlp

mkdir -p /root/.java/deployment/
cp /deployment.properties /root/.java/deployment/deployment.properties

# Setup VNC password

echo $PASSWORD | vncpasswd -f > ~/.vnc/passwd && chmod 0600 ~/.vnc/passwd

# Original command
/opt/TurboVNC/bin/vncserver && websockify -D --web=/usr/share/novnc/ --cert=~/novnc.pem 80 localhost:5901 && tail -f /dev/null
