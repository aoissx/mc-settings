#!/bin/bash

#*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
# Author: aoissx
# Description: start script
# OS: Ubuntu 22.04
#*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

#------------------------------------------------------------------------------------------
# VARIABLES
#------------------------------------------------------------------------------------------

#*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
# You can change these variables.
#*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
# project name: paper, velocity
PROJECT_NAME="velocity"

# project version
# if you want to use the latest version, set "latest"
VERSION="latest"

# server memory
# if you want to use the default memory, set "default"
# example: 2G, 4G, 8G
MEMORY="default"

# restart time
# if you want to use the default time, set "default"
# example: 1h, 2h, 3h
RESTART_TIME="default"

#*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
# You don't need to change these variables.
#*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
# project url
URL="https://papermc.io/api/v2/projects/${PROJECT_NAME}"

# log
SERVER_LOG=".mc.log"
SCRIPT_LOG=".script.log"

# file
SERVER_FILE="server.jar"

# screen name
SCREEN_NAME="minecraft"
RESTART_MANAGER="restart-manager"

# default memory
DEFAULT_MEMORY="2G"

# restart time
DEFAULT_RESTART_TIME="6h"

# stop command
STOP_COMMAND="stop"

# current directory
CURRENT_DIRECTORY=$(cd $(dirname $0); pwd)

# this file
SCRIPT_FILE=$(basename $0)

#------------------------------------------------------------------------------------------
# FUNCTIONS
#------------------------------------------------------------------------------------------

#------------------------------
# log
#------------------------------
info(){
    echo -e "\e[32m[INFO]\e[m $1"
    echo "[INFO] $1" >> ${SERVER_LOG}
}

warn(){
    echo -e "\e[33m[WARN]\e[m $1"
    echo "[WARN] $1" >> ${SERVER_LOG}
}

error(){
    echo -e "\e[31m[ERROR]\e[m $1"
    echo "[ERROR] $1" >> ${SERVER_LOG}
    exit 1
}

#------------------------------
# timestamp
#------------------------------
timestamp(){
    # time
    local CURRENT_TIME=$(date "+%Y/%m/%d %H:%M:%S")
    info "Current time is ${CURRENT_TIME}."
}

#------------------------------
# REQUIREMENTS
# openjdk-17-jdk, curl, 
# screen, jq
# fonts-noto-cjk
#------------------------------
require(){
    sudo apt update
    sudo apt install -y openjdk-17-jdk curl screen jq fonts-noto-cjk
}

#------------------------------
# Download project
#------------------------------
download(){
    # check exist screen
    exist-screen

    info "Server downloading..."
    info "This project is ${PROJECT_NAME}."

    # version check
    if [ "${VERSION}" = "latest" ]; then
        info "> Get latest version..."
        VERSION=$(curl -s ${URL} | jq -r '.versions[-1]')
    fi

    info "Version is ${VERSION}."

    # latest build number
    info "> Get latest build number..."
    BUILD=$(curl -s ${URL}/versions/${VERSION} | jq -r '.builds[-1]')
    info "Build is ${BUILD}."

    # download
    info "> Downloading..."
    JAR_NAME="${PROJECT_NAME}-${VERSION}-${BUILD}.jar"
    curl -s -o ${SERVER_FILE} ${URL}/versions/${VERSION}/builds/${BUILD}/downloads/${JAR_NAME}

    # check download
    if [ ! -e ${SERVER_FILE} ]; then
        error "Download failed."
    fi

    info "> Download complete."
}

#------------------------------
# Exist server
#------------------------------
exist-screen(){
    # check exist screen
    if [ $(screen -ls | grep ${SCREEN_NAME} | wc -l) -ne 0 ]; then
        error "Screen already exists."
    fi
}

#------------------------------
# Start server
#------------------------------
start-server(){
    # check exist screen
    exist-screen

    # download
    download

    info "Server starting..."

    # memory check
    if [ "${MEMORY}" = "default" ]; then
        MEMORY=${DEFAULT_MEMORY}
    fi

    # option
    JAR_OPTION="-Xms${MEMORY} -Xmx${MEMORY}"

    screen -UAmdS ${SCREEN_NAME} java -server -jar -Dpaper.disableChannelLimit=true ${JAR_OPTION} ${SERVER_FILE} nogui
    info "Server started."
}

#------------------------------
# Stop server
#------------------------------
stop-server(){
    # check exist screen
    if [ $(screen -ls | grep ${SCREEN_NAME} | wc -l) -eq 0 ]; then
        error "Screen does not exist."
    fi

    screen -S ${SCREEN_NAME} -p 0 -X stuff "${STOP_COMMAND}\n"

    # wait
    while true;
    do
        info "Waiting for server to stop..."
        timestamp
        if [ $(screen -ls | grep ${SCREEN_NAME} | wc -l) -eq 0 ]; then
            break
        fi
        sleep 10
    done

    info "Server stopped."

}

#------------------------------
# Restart server
#------------------------------
restart(){
    # stop server
    stop-server

    # start server
    start-server
}

#------------------------------
# Restart manager
#------------------------------
manager(){
    info "Restart manager starting..."

    # time check
    if [ "${RESTART_TIME}" = "default" ]; then
        RESTART_TIME="${DEFAULT_RESTART_TIME}"
    fi

    info "Restart time is ${RESTART_TIME}."

    # check exist screen
    if [ $(screen -ls | grep ${RESTART_MANAGER} | wc -l) -ne 0 ]; then
        error "Screen already exists."
    fi

    # if server is not running, start server
    if [ $(screen -ls | grep ${SCREEN_NAME} | wc -l) -eq 0 ]; then
        warn "Server is not running."
        info "Server starting..."
        start-server
        info "Server started."
    fi

    # start screen
    local SCRIPT=${CURRENT_DIRECTORY}/${SCRIPT_FILE}
    warn "If you want to stop the restart manager, type \"stop-manager\"."
    info "SCRIPT: ${SCRIPT}"
    screen -UAmdS ${RESTART_MANAGER} bash ${SCRIPT} _manager
    
}

#------------------------------
# _restart manager
#------------------------------
_manager(){
    info "===== Restart manager ====="
    info "Restart manager started."
    info "==========================="
    timestamp

    # time check
    if [ "${RESTART_TIME}" = "default" ]; then
        RESTART_TIME="${DEFAULT_RESTART_TIME}"
    fi

    while true;
    do
        local CURRENT_TIME=$(date "+%Y/%m/%d %H:%M:%S")
        info "Current time is ${CURRENT_TIME}."
        info "Restarting. Wait ${RESTART_TIME}..."
        sleep ${RESTART_TIME}
        info "Wait complete."
        info "Restarting..."
        restart
    done
}

#------------------------------
# Stop restart manager
#------------------------------
stop-manager(){
    info "Restart manager stopping..."
    # check exist screen
    if [ $(screen -ls | grep ${RESTART_MANAGER} | wc -l) -eq 0 ]; then
        error "Screen does not exist."
    fi

    screen -S ${RESTART_MANAGER} -p 0 -X quit

    info "Restart manager stopped."

}

#------------------------------
# Help
#------------------------------
help(){
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  start        Start the server"
    echo "  stop         Stop the server"
    echo "  restart      Restart the server"
    echo "  manager      Start the restart manager"
    echo "  stop-manager Stop the restart manager"
    echo "  help         Display this help message"
    echo ""
}

#------------------------------
# sub commands
#------------------------------
option(){
    info "Command: $1"
    case $1 in
        start)
            start-server
            ;;
        stop)
            stop-server
            ;;
        restart)
            restart
            ;;
        manager)
            manager
            ;;
        stop-manager)
            stop-manager
            ;;
        _manager)
            _manager
            ;;
        help)
            help
            ;;
        *)
            error "Invalid command."
            ;;
    esac

}

#------------------------------
# main
#------------------------------
main(){

    # opt
    if [ $# -eq 1 ]; then
        option $1
    else
        # check requirements
        info "Checking requirements..."
        require
        info "Requirements check complete."

        help
    fi
}

#------------------------------------------------------------------------------------------
# RUN
#------------------------------------------------------------------------------------------
clear
info "=================================================="
info "=====         START MINECRAFT SERVER         ====="
info "=================================================="

# timezone
export TZ=Asia/Tokyo
timestamp

main $1

screen -ls