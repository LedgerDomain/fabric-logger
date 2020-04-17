#!/bin/bash

SVBE_HOME=/home/ubuntu/src/svbe
ADMIN_MSP_DIR_ORG=${SVBE_HOME}/org0-docuseal-server/peer0-admin/msp
CERT_ORG=$(find ${ADMIN_MSP_DIR_ORG}/signcerts/*.pem -type f)
KEY_ORG=$(find ${ADMIN_MSP_DIR_ORG}/keystore/*_sk -type f)

# readlink to print full path
FABRIC_KEYFILE=$(readlink -e "$KEY_ORG")
FABRIC_CERTFILE=$(readlink -e "$CERT_ORG")

SPLUNK_HEC_TOKEN=533ed513-1eb9-4869-ac5d-37f8ba79dedd
SPLUNK_HOST=172.31.46.252
SPLUNK_PORT=8088
SPLUNK_INDEX=hyperledger_logs

echo "Using keyfile $FABRIC_KEYFILE"
echo "Splunk host: $SPLUNK_HOST"
echo "Splunk HEC token: $SPLUNK_HEC_TOKEN"

FABRIC_MSP=org0MSP
FABRIC_LOGGER_USERNAME=peer0-admin
FABRIC_PEER=org0.peer0
LOGGING_LOCATION=splunk
NETWORK_CONFIG=network.yaml
HFC_LOGGING='{"info":"console"}'

node dist/main.js
