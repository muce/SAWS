SAWS
====


Brief, How it works
===================

nagios.sh runs as a cron and fetches the status of the nagios server. For each nagios server it writes a status file with an integer representing the status of the nagios server.

The python script reads these files and sets the lights to a corresponding colour.

SawsConfig.py needs to be configured to read the status file 
LOG_FILES = ["nagiosStatus_server1", "nagiosStatus_server2"]

"LENGTHS" need to be configured to set the number of LEDs you wish to set for each file the python script is reading. If you monitor two servers you need two values. This must add up to 60 including the spaces that the script adds between each block of LEDs. In this example one at each end and one in between the two servers,  3 spacers. 

LENGTHS = [28, 29]


SawsDisplay needs to be modified so self.status has the same number of entries as servers. 999 represents an error colour

self.status = [999, 999]