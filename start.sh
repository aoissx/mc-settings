#!/bin/bash

#*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
# Author: aoissx
# Description: start script
# OS: Ubuntu 22.04
#*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*

#------------------------------------------------------------------------------------------
# VARIABLES
#------------------------------------------------------------------------------------------

# project name: paper, waterfall, velocity
PROJECT_NAME="paper"

# project version
# if you want to use the latest version, set "latest"
VERSION="latest"

# project url
URL="https://papermc.io/api/v2/projects/${PROJECT_NAME}"

# log
SERVER_LOG=".mc.log"
SCRIPT_LOG=".script.log"

# file
SERVER_FILE="server.jar"

#------------------------------------------------------------------------------------------
# FUNCTIONS
#------------------------------------------------------------------------------------------

#------------------------------
# log
#------------------------------
info(){
    echo -e "\e[32m[INFO]\e[m $1"
}

warn(){
    echo -e "\e[33m[WARN]\e[m $1"
}

error(){
    echo -e "\e[31m[ERROR]\e[m $1"
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

    info "> Download complete."
}

#------------------------------------------------------------------------------------------
# MAIN
#------------------------------------------------------------------------------------------
main(){
    clear
    # check requirements
    info "Checking requirements..."
    require > ${SCRIPT_LOG} 2>&1

    # download server jar
    info "Download server..."
    download
}

#------------------------------------------------------------------------------------------
# RUN
#------------------------------------------------------------------------------------------
echo "=================================================="
echo "=====         START MINECRAFT SERVER         ====="
echo "=================================================="

main