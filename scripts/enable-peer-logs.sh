#!/bin/bash
SPLUNK_HOME=/opt/splunkforwarder
INPUT_STANZA_PEER_ENABLED=inputs.conf.peerenabled
INPUT_STANZAS_REST=inputs.conf.nopeer
cat "$INPUT_STANZA_PEER_ENABLED" "$INPUT_STANZAS_REST" > $SPLUNK_HOME/etc/apps/search/local/inputs.conf
