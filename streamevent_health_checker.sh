#! /bin/bash

#gerrit path
GERRIT_PATH="/home/gerritadm/gerrit_site/"
#script path
SCRIPT_PATH="/home/gerritadm/gerrit_site/streamevent_health_checker/"
#stream event output file (will be erased everytime the cron hits)
FILE="${SCRIPT_PATH}stream_event.tmp"
#logging related params
LOG="${SCRIPT_PATH}stream_event_checker.log"
NOW=$(date)

#Gerrit related params
SERVER="gerrit.server.com"
USER="user"
PORT="29418"

#check wether the file exists and empty (if yes empty it)
if [[ -s $FILE ]] ; then
        > $FILE
        echo "[$NOW]: OK" >> $LOG
else
        #restart gerrit (which gonna refresh the stream event) and run stream event listener into a local file to ensure that it is not hangig
        echo "[$NOW]: Gerrit hang suspected" >> $LOG
        cd $GERRIT_PATH && ./bin/gerrit.sh restart >> $LOG
        ssh -p $PORT $USER@$SERVER gerrit stream-events >> $FILE &
fi ;
