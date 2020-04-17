#!/bin/bash

ADMIN_MSP_DIR_ORG=/home/ubuntu/src/svbe/org0-docuseal-server/peer0-admin/msp
CERT_ORG=$(find ${ADMIN_MSP_DIR_ORG}/signcerts/*.pem -type f)
KEY_ORG=$(find ${ADMIN_MSP_DIR_ORG}/keystore/*_sk -type f)
CA_ADMIN_PASSWORD=$(yq -r '.|.password' ~/src/svbe/org0-docuseal-server/account-passwords/ca-admin.yaml)

# readlink to print full path
echo $(readlink -e "$CERT_ORG")
echo $(readlink -e "$KEY_ORG")
echo ${CA_ADMIN_PASSWORD}

