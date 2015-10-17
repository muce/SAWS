#!/bin/bash

dir="logs"
log="travis.log"
mkdir -p "$dir"
cd "$dir" || exit
rm -f travisJobLog_*  travisJobPage_*
#limit log file size
tail -n 1000 $log > $log.tmp && cat $log.tmp > $log
rm -f $log.tmp
echo "
`date`">> $log

function travisChecker {

    # 1. this is for commercial Travis, you may need to replace with .org for free Travis.
    travisHost="api.travis-ci.com"
    travisPort=443
    repo="$1"
    repoQuery=/repos/Hyperfish/"$repo"
    
    # 2. replace with your own travis auth token from your profile page in travis. 
    travisToken=".xml?token=<YOUR TOKEN HERE>"
    
    statusFile="travisJobStatus_`exec echo $travisJob | sed s/" "/_/g`"
    travisPage="travisJobPage_`exec echo $travisJob | sed s/" "/_/g`"
    travisLog="travisJobLog_`exec echo $travisJob | sed s/" "/_/g`"
    criticalTimeLimit=1
    T="$(date +%s)"

    echo Downloading Travis Repo Status  "$travisJob"

    wget -T 10 -t 4 -w 1 --retry-connrefused --server-response https://"$travisHost":"$travisPort""$repoQuery""$travisToken" -O "$travisPage" -o "$travisLog"

    if [ $? != 0 ]; then
        echo wget failed for "$travisPage"
        echo 999 > $statusFile
        exit
    fi

    rcode=`grep "HTTP/1.1 200 OK" "$travisLog" | awk '{ print $2 }'`

    if [[ "$rcode" = 200 ]]; then

        result=`cat "$travisPage" | sed -n 's/.*lastBuildStatus=\([\"A-Za-z]*\).*/\1/p'`
        currentActivity=`cat "$travisPage" | sed -n 's/.*activity=\([\"A-Za-z]*\).*/\1/p'`
    
        echo Current build activity: $travisJob $currentActivity
        echo Last build result: $travisJob $result
    
        if [ "$currentActivity" != "\"Sleeping\"" ]; then
                    echo Travis Repo \""$travisJob"\" is sleeping
                    echo 7 > "$statusFile"
                elif [ "$result" = "null" ]; then
                    echo Travis Repo \""$travisJob"\" is building
                    echo 999 > "$statusFile"
                elif [ "$result" = "\"Success\"" ]; then
                    echo Travis Repo \""$travisJob"\" has built successfully
                    echo 0 > "$statusFile"
                elif [ "$result" = "\"Failed\"" ]; then
                echo  Travis Repo \""$travisJob"\" has  failed
                echo 2 > "$statusFile"
                else
                echo Travis Repo "$travisJob" is in unknown state
                echo 10 > "$statusFile"
        fi

    else

        echo "Travis Repo \""$travisJob"\" return code not 200"
        echo 999 > $statusFile

    fi

    TT="$(($(date +%s)-T))"
    echo "Travis Job "$travisJob" took ${TT} seconds to complete"
}

IFS=,

# 3. replace with your repo names you want to monitor comma seperated.
travisJobList="MyAwesomeRepo, AnotherAwesomeRepo"

for travisJob in $travisJobList; do

    (travisChecker "$travisJob" &) >> $log 2>&1

done

sleep 4
tail -20 $log
