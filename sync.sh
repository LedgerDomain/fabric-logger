#!/bin/bash

REMOTE_HOST=ld-salt-01
LOCAL_DIR_NOSLASH=/home/leo/projects/ledgerdomain/splunk-fabric-logger
REMOTE_DIR=/home/ubuntu/splunk-fabric-logger/fabric-logger
SYNC_ID=sync-fabric-logger

EXECUTE_COMMAND="run"
DRY_RUN_COMMAND="test"
DELETE_OPT="--delete"   # TODO make this option parsing logic better

LOCAL_DIR=${LOCAL_DIR_NOSLASH}/
DRY_RUN_FLAG="--dry-run"

RSYNC_TMPFILE=$(mktemp /tmp/lva${SYNC_ID}.tmp.XXXXXXXXXX)
RSYNC_RELATIVE_TMPFILE=$(mktemp /tmp/lva${SYNC_ID}-relative.tmp.XXXXXXXXXX)
trap 'rm -rf "${RSYNC_TMPFILE}"; exit' INT TERM EXIT
trap 'rm -rf "${RSYNC_RELATIVE_TMPFILE}"; exit' INT TERM EXIT


function usage {
    echo "Usage: $(basename $0): command required; allowed commands:"
    echo "           $(basename $0) $EXECUTE_COMMAND"
    echo "           $(basename $0) $DRY_RUN_COMMAND"
    echo "       allowed options:"
    echo "           $DELETE_OPT"
}

COMMAND=$1
DEL_OPT=$2

case $COMMAND in
    $EXECUTE_COMMAND ) DRY_RUN_FLAG="" ;;
    $DRY_RUN_COMMAND ) ;;
    *) usage; exit 1 ;;
esac

if [[ $DEL_OPT == $DELETE_OPT ]]; then
    DELETE_FLAG="--delete-after"
    read -p 'This will delete stuff. Continue [y|yes]? Dry run? [d] ' cont
    if [[ "$cont" == "d" ]]; then
        COMMAND=$DRY_RUN_COMMAND
        DRY_RUN_FLAG="--dry-run"
        DELETE_FLAG="--delete-after"
    elif [[ "$cont" != "yes" ]] && [[ "$cont" != "y" ]]; then
        DELETE_FLAG=""
        echo "Exiting now."
        exit 0
    fi
else
    DELETE_FLAG=""
fi

echo "Starting initial sync..."
rsync --verbose -azP \
      $DRY_RUN_FLAG \
      $DELETE_FLAG \
      --filter=':e- .gitignore' \
      --exclude='network.yaml' \
      --exclude='.git/' \
      $LOCAL_DIR ${REMOTE_HOST}:${REMOTE_DIR}

if [[ $COMMAND == $DRY_RUN_COMMAND ]]; then
    exit 0
fi

echo "$(date) starting to monitor for file changes..."

# FSWATCH_EXCLUDE_REGEX=".git\|\\.#.\+"  #note \\. for literal '.' and \+, \|
# note: with fswatch 1.14 only the following extended regex worked
# -Ee flag uses extended regex
FSWATCH_EXCLUDE_REGEX=".git|\.#.+"

# if this keeps throwing weird errors try to include explicit events
# as shown in https://github.com/emcrisostomo/fswatch/issues/191
fswatch -Ee "${FSWATCH_EXCLUDE_REGEX}" --batch-marker=EOF \
        --event Created --event Updated --event Removed \
        --event Renamed --event MovedFrom --event MovedTo \
        --latency 0.5 \
        --event-flags --recursive ${LOCAL_DIR} | while read file event; do
    if [[ $file == "EOF" ]]; then
        # echo "$(date) detected change in ${list[@]}"
        printf "%s\n"  "${list[@]}" > ${RSYNC_TMPFILE}
        sed -e "s,${LOCAL_DIR_NOSLASH},," -e "s,${LOCAL_DIR},," \
            ${RSYNC_TMPFILE} > ${RSYNC_RELATIVE_TMPFILE}
        echo "$(date) beginning sync..."
        rsync --verbose --files-from=${RSYNC_RELATIVE_TMPFILE} \
              $LOCAL_DIR ${REMOTE_HOST}:${REMOTE_DIR}
        echo "$(date) sync completed, continuing monitoring..."
        list=()
    else
        if [[ $event != "PlatformSpecific" ]] && [[ $event != "IsDir" ]]; then
            list+=($file)
            echo "$(date) $file $event"
        fi
    fi
done
