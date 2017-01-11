#!/bin/bash

#preconfig:
#first of all you'll have to create a project in gerrit and make a first commit
#then you'll have to fill the change id
CHANGEID=****

#To enable the dry run mode
DRY_RUN=0

#to relaunch the stream event if it's suspended for a certain reason
LISTEN=$1

#gerrit path
GERRIT_PATH="/home/gerritadm/gerrit_site/"
#script path
SCRIPT_PATH="/home/gerritadm/gerrit_site/streamevent_health_checker/"

#stream event output file (will be erased everytime the cron hits)
FILE="${SCRIPT_PATH}stream_event.tmp"
#logging related params
LOG="${SCRIPT_PATH}stream_event_checker.log"

#Gerrit related params
SERVER="gerrit.com"
USER="login"
HTTP_PASSWORD="password"
PORT=29418

#Current time used for logging
NOW=$(date +"%Y-%m-%d %T")

#used to check whether streamevent listener is listening or not
IS_LIESTENING=$(ps aux |grep "[s]sh -p 29418 $USER@$SERVER gerrit stream-events")

if [ $LISTEN == 1 ] && [ "$IS_LIESTENING" == "" ]
then
        ssh -p $PORT $USER@$SERVER gerrit stream-events >> $FILE &
        #echo "[$NOW]: Initialize listening" >> $LOG
fi

if [ $LISTEN == 0 ]
then
        curl -k --digest -XPOST -s /dev/null -u $USER:$HTTP_PASSWORD "https://gerrit.st.com/a/changes/$CHANGEID/abandon" >> /dev/null
        curl -k --digest -XPOST -s /dev/null -u $USER:$HTTP_PASSWORD "https://gerrit.st.com/a/changes/$CHANGEID/restore" >> /dev/null

        #check wether the file exists and empty (if full empty it)
        if [[ -s $FILE ]]
        then
                > $FILE
                echo "[$NOW]: OK" >> $LOG
        else
                echo "[$NOW]: Gerrit hang suspected" >> $LOG
                if [[ $DRY_RUN == 0 ]]
                then
                         #if tmp file is empty, we suppose that the stream event is hanging
                         #restart gerrit (which gonna refreh the stream event)
                         cd $GERRIT_PATH && ./bin/gerrit.sh restart >> $LOG
                fi
        fi
fi
exit 0
