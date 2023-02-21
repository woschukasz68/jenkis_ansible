#!/usr/bin/bash

for env in `cat envs`;do
	json=$(curl --silent -k  "https://servus.krakow.comarch/rest/api/1/env/$env")
	ip_of_env=$(echo $json | jq '.hosts | .[] | .host' 2> /dev/null)
	if [ ! -z "$ip_of_env" ];then
		for ip in $ip_of_env;do
			sed -i "/\[env\]/a $ip" inventory
		done
	fi

done
