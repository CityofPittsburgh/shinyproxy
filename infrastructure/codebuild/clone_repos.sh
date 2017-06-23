#!/usr/bin/env bash
export ROOT=$PWD
mkdir shinyapps
cd shinyapps
source /tmp/shiny_proxy_ip

# This script will clone the repos specified in the repositories.conf file.
# moves the source code to the AWS instance and builds the docker files contained in them

echo "attempting clone repos and build docker images from the following list"
cat $ROOT/repositories.conf
IFS=$'\n'
set -f
for repo in $(cat < $ROOT/repositories.conf); do
    export REPO_NAME=$(echo $repo | grep -P -o "git@github.com:CityOfBoston\/\w+.git")
    export NAME=$(echo $repo | grep -P -o "^\w+")
    echo cloning the following "${REPO_NAME}"
    git clone ${REPO_NAME}
    echo "copying over ${NAME} to the shinyproxy server"
    echo "why is this ip not resolving: ${SHINY_PROXY_IP} ?"
    #sudo scp -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no -r ${NAME} ubuntu@${SHINY_PROXY_IP}:~/shinyproxy/
    scp -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no -r ${NAME} ec2-user@${BASTION_PUBLIC_IP}:/tmp/shinyproxy/
    ssh -T -A -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no ec2-user@${BASTION_PUBLIC_IP} <<EOF
        scp -r /tmp/shinyproxy/ ubuntu@${SHINY_PROXY_IP}:~/shinyproxy/
EOF

    ssh -A -T -i ~/.ssh/shinyproxy.pem -o StrictHostKeyChecking=no  ec2-user@${BASTION_PUBLIC_IP} << EOF
            ssh -T -o StrictHostKeyChecking=no ubuntu@${SHINY_PROXY_IP} << BAS
            cd ~/shinyproxy/$NAME
            echo "Building the $NAME docker image"
            sudo docker build -t bostonanalytics/${NAME} .
BAS
EOF
done


echo "done building docker images for shiny apps"

