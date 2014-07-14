#!/bin/bash

dir="/home/saws/saws/logs"
log="jenkins.log"
mkdir -p "$dir"
cd "$dir" || exit
rm -f jenkinsJobLog_*  jenkinsJobPage_*
#limit log file size
tail -n 1000 $log > $log.tmp && cat $log.tmp > $log
echo "
`date`">> $log

function jenkinsChecker {

    jenkinsHost="jenkins_server"
    jenkinsPort=8080
    job="$1"
    jobQuery=/job/"$job"
    buildStatusQuery=/lastBuild/api/json
    statusFile="jenkinsJobStatus_`exec echo $jenkinsJob | sed s/" "/_/g`"
    jenkinsPage="jenkinsJobPage_`exec echo $jenkinsJob | sed s/" "/_/g`"
    jenkinsLog="jenkinsJobLog_`exec echo $jenkinsJob | sed s/" "/_/g`"
    criticalTimeLimit=1
    T="$(date +%s)"

    echo Downloading Jenkins Job "$jenkinsJob"

    wget -T 10 -t 4 -w 1 --retry-connrefused --server-response http://"$jenkinsHost":"$jenkinsPort""$jobQuery""$buildStatusQuery" -O "$jenkinsPage" -o "$jenkinsLog"

    if [ $? != 0 ]; then
        echo wget failed for "$jenkinsPage"
        echo 999 > $statusFile
        exit
    fi

    rcode=`grep "HTTP/1.1 200 OK" "$jenkinsLog" | awk '{ print $2 }'`

    if [[ "$rcode" = 200 ]]; then

        #check that the page contains the correct string
        #correctPage=`grep -E "^\{\"actions.*\[\]\}$" "$jenkinsPage"`
        #if [[ ! "$correctPage" ]]; then
        #    echo "$jenkinsPage" page does not contain the correct string
        #    echo 999 > "$statusFile"
        #    exit
        #fi

        result=`cat "$jenkinsPage" | sed -n 's/.*"result":\([\"A-Za-z]*\),.*/\1/p'`

        if [ "$result" = "null" ]; then
                echo Jenkins Job \""$jenkinsJob"\" is building
                echo 8 > "$statusFile"
            elif [ "$result" = "\"SUCCESS\"" ]; then
                echo Jenkins Job \""$jenkinsJob"\" has built successfully
                echo 7 > "$statusFile"
            elif [ "$result" = "\"FAILURE\"" ]; then
               echo  Jenkins Job \""$jenkinsJob"\" has  failed
               echo 9 > "$statusFile"
            else
               echo Jenkins Job "$jenkinsJob" is in unknown state
               echo 10 > "$statusFile"
        fi

    else

        echo "Jenkins Job \""$jenkinsJob"\" return code not 200"
        echo 999 > $statusFile

    fi

    TT="$(($(date +%s)-T))"
    echo "Jenkins Job "$jenkinsJob" took ${TT} seconds to complete"


}

IFS=,
jenkinsJobList="workflow_name"

for jenkinsJob in $jenkinsJobList; do

    (jenkinsChecker "$jenkinsJob" &) >> $log 2>&1

done

sleep 4
tail -20 $log
