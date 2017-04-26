#!/usr/bin/env bash

source /tmp/shiny_proxy_ip && \
(nohup ssh -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no ubuntu@$SHINY_PROXY_IP '(jps -ml | grep shinyproxy | grep -P -o "\d+\s" | awk '{print $1}' | xargs kill)' &)  && \
ssh -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no ubuntu@$SHINY_PROXY_IP  'cd ~/shinyproxy/ && (nohup java -jar shinyproxy-0.8.7.jar &)'


#&& ( cd ~/shinyproxy/ && nohup java -jar shinyproxy-0.8.7.jar &)'  ||