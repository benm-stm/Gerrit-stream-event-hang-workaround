#! /bin/bash

#script path
PATH="/home/gerritadm/gerrit_site/streamevent_health_checker/"
#stream event output file (will be erased everytime the cron hits)
FILE="$PATHstream_event.tmp"
#log file
LOG="$PATHstream_event_checker.log"
#used to mark loging date
NOW=$(date)

#check wether the file exists and empty (if yes empty it)
if [[ -s $FILE ]] ; then
        > $FILE
        echo "[$NOW]: OK" >> $LOG
else
        #restart gerrit (which gonna refresh the stream event) and run stream event listener into a local file to ensure that it is not hangig
        echo "[$NOW]: Gerrit hang suspected" >> $LOG
        cd /home/gerritadm/gerrit_site/ && ./bin/gerrit.sh restart >> $LOG
        ssh -p 29418 user@gerrit.server.com gerrit stream-events >> $FILE &
fi ;
