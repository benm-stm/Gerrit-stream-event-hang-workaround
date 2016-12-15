#!/bin/bash

#To enable the dry run mode
DRY_RUN=1

#this const should be the same as the one inserted in the cron
SQUEDUAL_FREQUENCY=30

#gerrit path
GERRIT_PATH="/home/gerritadm/gerrit_site/"
#script path
SCRIPT_PATH="/home/gerritadm/gerrit_site/streamevent_health_checker/"


#stream event output file (will be erased everytime the cron hits)
FILE="${SCRIPT_PATH}stream_event.tmp"
#logging related params
LOG="${SCRIPT_PATH}stream_event_checker.log"
#required
SSHDLOG="${GERRIT_PATH}logs/sshd_log"

#Gerrit related params
SERVER="gerrit-server.com"
USER="user"
PORT=29418

#Current time used for logging
NOW=$(date +"%Y-%m-%d %T")

#check wether the file exists and empty (if yes empty it)
if [[ -s $FILE ]]
then
        > $FILE
        echo "[$NOW]: OK" >> $LOG
else
        #get the content of sshd log into a string
        content=$(cat $SSHDLOG)
        operation_exist=0
        for (( c=0; c<$SQUEDUAL_FREQUENCY; c++ ))
        do
                #t is the instant on which the script should search for the entry
                t=$(date --date="$c minutes ago" +'%Y-%m-%d %H:%M')
                regex="$t.*git-receive-pack"
                if [[ "$content" =~ $regex ]]
                then
                        operation_exist=1
                        break
                fi
        done
        if [[ $operation_exist == 1 ]]
        then
                echo "[$NOW]: Gerrit hang suspected" >> $LOG
                if [[ $DRY_RUN == 0 ]]
                then
                        #if matches, we suppose that the stream event is hanging
                        #restart gerrit (which gonna refreh the stream event) and run stream event listener into a local file to ensure that it is not hanging
                        cd $GERRIT_PATH && ./bin/gerrit.sh restart >> $LOG
                        ssh -p $PORT $USER@$SERVER gerrit stream-events >> $FILE &
                fi
        else
                #if no matches then we suppose that theres no activity on the on gerrit and we continue
                echo "[$NOW]: OK (check done on gerrit log file)" >> $LOG
        fi
fi
exit 0
