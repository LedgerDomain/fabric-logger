#!/bin/bash

export SVBE_HOME=/home/ubuntu/src/svbe
export ADMIN_MSP_DIR_ORG=${SVBE_HOME}/org0-docuseal-server/peer0-admin/msp
export CERT_ORG=$(find ${ADMIN_MSP_DIR_ORG}/signcerts/*.pem -type f)
export KEY_ORG=$(find ${ADMIN_MSP_DIR_ORG}/keystore/*_sk -type f)

# readlink to print full path
export FABRIC_KEYFILE=$(readlink -e "$KEY_ORG")
export FABRIC_CERTFILE=$(readlink -e "$CERT_ORG")
export SPLUNK_HEC_TOKEN=533ed513-1eb9-4869-ac5d-37f8ba79dedd
export SPLUNK_HOST=172.31.46.252
export SPLUNK_PORT=8088
export SPLUNK_HEC_URL=http://${SPLUNK_HOST}:${SPLUNK_PORT}
export SPLUNK_INDEX=hyperledger_logs

echo "Using keyfile $FABRIC_KEYFILE"
echo "Splunk host: $SPLUNK_HOST"
echo "Splunk HEC token: $SPLUNK_HEC_TOKEN"

export FABRIC_MSP=org0MSP
export FABRIC_LOGGER_USERNAME=peer0-admin
export FABRIC_PEER=org0.peer0
#export LOGGING_LOCATION=stdout
export LOGGING_LOCATION=splunk
export NETWORK_CONFIG=network.yaml
export HFC_LOGGING='{"info":"console"}'

node dist/main.js
