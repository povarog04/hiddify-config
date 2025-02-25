#!/bin/bash
#ln -sf $(pwd)/hiddify-warp.service /etc/systemd/system/hiddify-warp.service
systemctl disable hiddify-warp.service

# if [[ $warp_mode == 'disabled' ]];then
#   bash uninstall.sh
# else

if ! [ -f "wgcf-account.toml" ];then
    mv wgcf-account.toml wgcf-account.toml.backup
    wgcf register --accept-tos -m hiddify -n $(hostname)
fi

#api.zeroteam.top/warp?format=wgcf for change warp
export WGCF_LICENSE_KEY=$WARP_PLUS_CODE
wgcf update
if [ $? != 0 ];then
  mv wgcf-account.toml wgcf-account.toml.backup
  wgcf update
  if [ $? != 0 ];then
    mv wgcf-account.toml wgcf-account.toml.backup
    export WGCF_LICENSE_KEY=
    wgcf update
  fi 
fi 



wgcf generate
sed -i 's/\[Peer\]/Table = off\n\[Peer\]/g'  wgcf-profile.conf

curl --connect-timeout 1 -s http://ipv6.google.com 2>&1 >/dev/null
if [ $? != 0 ]; then
  sed -i '/Address = [0-9a-fA-F:]\{4,\}/s/^/# /' wgcf-profile.conf
fi

mkdir -p /etc/wireguard/
ln -sf $(pwd)/wgcf-profile.conf /etc/wireguard/warp.conf  
systemctl enable --now wg-quick@warp

systemctl restart wg-quick@warp