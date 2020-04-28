#!/bin/bash

SVBE_HOME=/home/ubuntu/src/svbe
ADMIN_MSP_DIR_ORG=${SVBE_HOME}/org0-docuseal-server/peer0-admin/msp
CERT_ORG=$(find ${ADMIN_MSP_DIR_ORG}/signcerts/*.pem -type f)
KEY_ORG=$(find ${ADMIN_MSP_DIR_ORG}/keystore/*_sk -type f)
TLS_CA_CERTS_PATH=/home/ubuntu/src/svbe/org0-docuseal-server/root.cert.pem

CA_ADMIN_PASSWORD=$(yq -r '.|.password' ${SVBE_HOME}/org0-docuseal-server/account-passwords/ca-admin.yaml)

# readlink to print full path
CERT_PATH=$(readlink -e "$CERT_ORG")
KEY_PATH=$(readlink -e "$KEY_ORG")

cat > network.yaml <<EOM
name: "salt-network-01"
description: "Load testing network: 1 org, HLF 1.4"
version: "1.0"

channels:
  simple-channel:
    peers:
      org0.peer0:
        eventSource: true

organizations:
  org0:
    mspid: org0MSP
    peers:
    - org0.peer0
    certificateAuthorities:
    - org0.ca
    adminPrivateKey:
      path: $KEY_PATH
    signedCert:
      path: $CERT_PATH

orderers:
  org0.orderer0:
    url: grpcs://localhost:7050
    grpcOptions:
      ssl_target_name_override: localhost
    tlsCACerts:
      path: $TLS_CA_CERTS_PATH

peers:
  org0.peer0:
    url: grpcs://localhost:7051
    grpcOptions:
      ssl_target_name_override: localhost
    tlsCACerts:
      path: $TLS_CA_CERTS_PATH

certificateAuthorities:
  org0.ca:
    url: https://localhost:7054
    tlsCACerts:
      path: /home/ubuntu/remotes/orgs/org0/fabric-ca-servers/ca/cert.pem
    registrar:
    - enrollId: ca-admin
      enrollSecret: $CA_ADMIN_PASSWORD
EOM

