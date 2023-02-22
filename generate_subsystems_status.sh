#!/usr/bin/bash

output_file='table_ofsubsystems_status.txt'
echo 'ENVIRONMENT,GRAFANA,GRAFANA,PROMETHEUS,PROMETHEUS,PROMETHEUS,KAFDROP,KAFDROP,AKHQ,AKHQ,ELASTICSEARCH-LOGGING,ELASTICSEARCH-LOGGING,ELASTICSEARCH-LOGGING,ELASTICSEARCH_ZIPKIN,ELASTICSEARCH_ZIPKIN,KIBANA,KIBANA,APMServerOss,APMServerOss,Node_Exporter,Node_Exporter' > $output_file
echo '"",Exist,Status,Exist,Status,rate_of_up_jobs,Exist,Status,Exist,Status,Exist,Status,response_of_server,Exist,Status,Exist,Status,Exist,Status,Exist,Status' >> $output_file

./inventory_generator.sh
ansible-playbook playbook_generating_of_subsystem_status.yml --extra-vars "ansible_password=$password"
sed -i '/^"/d' inventory

sort -o subsystems_info.txt subsystems_info.txt
cat subsystems_info.txt >> $output_file
rm -f subsystems_info.txt
