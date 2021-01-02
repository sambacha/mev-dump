#!/usr/bin/env bash

# ENV
# DOCKER_COMPOSE_SOLUTION=
# 

# Script we are executing
echo -e " \e[32m@@@ Excuting script: \e[1;33mlaunch.sh \e[0m"

# Get the absolute path for this file
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
# Get the absolute path for the refarch-kc project
MAIN_DIR=`echo ${SCRIPTPATH} | sed 's/\(.*refarch-kc\).*/\1/g'`

SETENV="${MAIN_DIR}/scripts/setenv.sh"

# Checking if the setenv.sh file exist for reading environment variables
if [[ ! -f "$SETENV"  ]]
then
    echo -e "\e[31m [ERROR] - The file setenv.sh not found under the scripts folder (${MAIN_DIR}/scripts) - Use the setenv.sh.tmpl template to create your setenv.sh file.\e[0m"
    exit -1
fi

# Read environment variables for LOCAL
source $SETENV LOCAL

# Get what option the user wants to launch
if [[ $# -eq 0 ]];then
  toLaunch="SOLUTION"
else
  toLaunch=$1
fi

# Launch the backbone components
if [ "$toLaunch" == "SOLUTION" ] || [ "$toLaunch" == "BACKEND" ]
then
    kafka=$(docker-compose -f ${MAIN_DIR}/docker/backbone-compose.yml ps | grep kafka | grep Up | awk '{ print $1}')
    if [[ $kafka != "docker_kafka1_1" ]]
    then
        echo -e " \e[32m@@@ Start back end\e[39m"
        rm -r kafka1 zookeeper1
        # Launching the backbone components in detached mode so that the output is cleaner
        # To see the logs execute either:
        # 1. docker-compose -f ${MAIN_DIR}/docker/backbone-compose.yml logs 
        # 2. docker logs <docker_container_id>
        docker-compose -f ${MAIN_DIR}/docker/backbone-compose-avro.yml up -d
        sleep 15
        ${MAIN_DIR}/scripts/createTopics.sh LOCAL
    else
        echo -e "\e[32m@@@ Back end services are running. These are the kafka topics: \e[39m"
        docker exec -ti docker_kafka1_1 /bin/bash -c "/opt/kafka/bin/kafka-topics.sh --list --zookeeper zookeeper1:2181"
    fi
fi

# Launch the solution
if [[ "$toLaunch" == "SOLUTION" ]]
then
    solution=$(docker-compose -f ${DOCKER_COMPOSE_SOLUTION}.yml ps | grep simulator | grep Up | awk '{ print $1}')
    if [[ $solution != "docker_simulator_1" ]]
    then
        echo -e "\e[32m@@@ Start all solution microservices\e[39m"
        # Launching the solution components in detached mode so that the output is cleaner
        # To see the logs execute either:
        # 1. docker-compose -f ${MAIN_DIR}/docker/${DOCKER_COMPOSE_SOLUTION}.yml logs 
        # 2. docker logs <docker_container_id>
        docker-compose -f ${MAIN_DIR}/docker/${DOCKER_COMPOSE_SOLUTION}.yml up -d
    else
        echo -e "\e[32m@@@ all solution microservices are running\e[39m"
    fi
fi

# Script we are executing
echo -e " \e[32m@@@ End script: \e[1;33mlaunch.sh \e[0m"
