#!/bin/bash

dir="/home/saws/saws/logs"
log="nagios.log"
mkdir -p "$dir"
cd "$dir" || exit
rm -f nagiosLog_*  nagiosPage_*
#limit log file size
tail -n 1000 $log > $log.tmp && cat $log.tmp > $log
echo "
`date`">> $log

function nagiosChecker {

    statusFile="nagiosStatus_"$nagiosHost""
    nagiosPage="nagiosPage_"$nagiosHost""
    nagiosLog="nagiosnLog_"$nagiosHost""
    criticalTimeLimit=30
    OverViewPage="/nagios/cgi-bin//status.cgi?servicestatustypes=28"
    wgetOptions="-T 10 -t 4 -w 1 --retry-connrefused --server-response"
    T="$(date +%s)"

    echo Downloading Nagios host "$nagiosHost"

    wget $wgetOptions http://$nagiosHost$OverViewPage -O "$nagiosPage" -o "$nagiosLog"

    if [ $?  != 0 ]; then
        echo wget failed for "$nagiosPage"
        echo 999 > $statusFile
        exit
    fi

    rcode=`grep "HTTP/1.1 200 OK" "$nagiosLog" | awk '{ print $2 }'`

    #check that the page contains the correct format
    correctString=`grep "Service Status Details For All Hosts" "$nagiosPage"`
    if [[ -n "$correctrString" ]]; then
        echo page does not seem correct
        echo 999 > "$statusFile"
        exit
    fi

    TT="$(($(date +%s)-T))"

    if [[ "$rcode" = 200 ]]; then

        critical=`egrep  "BGCRITICAL'>(1/1|2/2|3/3|4/4)" "$nagiosPage"`
        warning=`egrep "BGWARNING'>(1/1|2/2|3/3|4/4)" "$nagiosPage"`
        unknown=`egrep "BGUNKNOWN" "$nagiosPage"`

        if [ -z "$warning" ] && [ -z "$critical" ] && [ -z "$unknown" ]; then
                echo "$nagiosHost has no service errors, took ${TT} seconds to complete"
                echo 0 > "$statusFile"

            elif [ -z "$warning" ] && [ -z "$critical" ] && [ -n "$unknown" ]; then
                echo ""$nagiosHost" is Unknown, took ${TT} seconds to complete"
                echo 1 > "$statusFile"

            elif [ -n "$warning" ] && [ -z "$critical" ]; then
                echo ""$nagiosHost" is Warning, took ${TT} seconds to complete"
                echo 2 > "$statusFile"

            elif [ -n "$critical" ]; then

                #if the host has a critical alert for over X minutes we set the status to 4 (flashing red)
                criticalStatus=`cat "$statusFile"`
                criticalMAX=`find "$statusFile" -mmin +"$criticalTimeLimit"`

                if [[ $criticalStatus == 3 ]] && [ -z "$criticalMAX" ]; then
                        echo "Nagios host \""$nagiosHost"\" status is already set to 3 and file age is under "$criticalTimeLimit" minutes, took ${TT} seconds to complete"
                    elif [ "$criticalStatus" = 3 ] && [ -n "$criticalMAX" ]; then
                        echo "Nagios host \""$nagiosHost"\" status has been Critical for over "$criticalTimeLimit" minutes, took ${TT} seconds to complete"
                        echo 4 > $statusFile
                    elif [ "$criticalStatus" = 4 ]; then
                        echo "Nagios host \""$nagiosHost\"" status is still 4, took ${TT} seconds to complete"
                    else
                        echo "Nagios host \""$nagiosHost"\" set critical status to 3, took ${TT} seconds to complete"
                        echo 3 > "$statusFile"
                fi

        fi

    else

        echo "Nagios host return code not 200, took ${TT} seconds to complete"
        echo 999 > "$statusFile"

    fi

}

hostlist="server1 server2"


for nagiosHost in $hostlist; do

    (nagiosChecker "$nagiosHost" &) >> $log 2>&1

done
