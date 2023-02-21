#!/usr/bin/bash -i

declare -a table_of_subsystems=(Grafana Prometheus kafdrop AKHQ Elasticsearch-logging ElasticSearch_Zipkin Kibana APMServerOss Node_Exporter)

env_name=$(cat .bash_profile | grep PS1 | tr -d "\r\n" | sed 's/.*\[//' | sed 's/ .*//')
echo -n "$env_name,"

get_port_of_subsystem () {
	echo $(ps aux | grep "Dsubsystem.name=$1 " | grep -v grep | awk '{print $13}' | sed 's/.*://')
}

percent_of_up_jobs () {
	json=$(curl --silent "http://localhost:$( get_port_of_subsystem Prometheus )/api/v1/targets")
	num=$(echo $json | jq '.data.activeTargets | length')

	if [ -z "$num" ];then
		echo "lack_of_jobs"
	else
		count_of_up=$(echo $json | jq '.data.activeTargets | .[] | .health' | grep up | wc -l)
		score=$(awk "BEGIN {print $count_of_up/$num}")
        	echo ${score::4}
	fi
}

response_of_elasticsearch_server () {
	port=$(cat ~/subsystems/Elasticsearch-logging/runContainer/run_Elasticsearch-logging.sh | grep ELASTIC_URL= | sed 's/.*://')
	ip=$(cat ~/subsystems/Elasticsearch-logging/runContainer/run_Elasticsearch-logging.sh | grep ELASTIC_URL= | sed 's/.*=//' | sed 's/:.*//')
	json=$(curl --silent "http://$ip:$port/_cluster/health")
	status=$(echo $json | jq '.status')
	if [ "$status" = "yellow" ] || [ "$status" = "green" ];then
		echo "ok"
	else
		echo "not ok"
	fi
}

if [ ! -d "subsystems" ];then
	for _ in {1..18};do
		echo -n "X,"
	done
	exit 0
fi

cd ./subsystems

for subsystem in "${table_of_subsystems[@]}";do
	if [ -d "$subsystem" ];then

		echo -n "yes,"

		if [ "$subsystem" = "Kibana" ];then

                        process=$(ps aux | grep "Kibana" | grep -v grep)
                else

                        process=$(ps aux | grep "Dsubsystem.name=$subsystem " | grep -v grep)
                fi

		if [ -z "$process" ];then

			echo -n "not working,"
			if [ "$subsystem" == "Prometheus" ];then

                                echo -n "X,"
                        fi
			if [ "$subsystem" == "Elasticsearch-logging" ];then

                                echo -n "X,"
                        fi
		else
			echo -n "working,"
                	if [ "$subsystem" == "Prometheus" ];then
				
				echo -n "$( percent_of_up_jobs ),"
                	fi

			if [ "$subsystem" == "Elasticsearch-logging" ]; then

				echo -n "$( response_of_elasticsearch_server ),"
			fi
		fi
	else
		echo -n "no,"
		echo -n "X,"
		if [ "$subsystem" == "Prometheus"  ];then
			echo -n "X,"
		fi
		if [ "$subsystem" == "Elasticsearch-logging" ];then
			echo -n "X,"
		fi
	fi
done
