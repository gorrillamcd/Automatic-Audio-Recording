#!/bin/bash

##########################################################################
# Auto Sound Recording v1.2				LAST EDITED: 2012/03/03
# On Demand Version
#
# AUTHOR: GorrillaMcD		    ORIGINALLY MADE FOR: ccbcmexico.com
#
# COPYRIGHT INFO: You are free to use this script or make derivative
# works or even distribute it. You are never allowed to sell it and it
# should only be distributed gratis (free!!).
# 
# If you do distribute this script, you should include the readme and
# supporting files.
#
# Did you have some improvements to the script? Be a friend and pass
# them upstream. You can email tech@ccbcmexico.com or use the contact
# form on http://techonamission.com/
#########################################################################

# NOTE: This version of the script will ask for the user to input certain
# variable such as duration and recording name. This one is meant to be called
# when needed and not from cron.

# Set working directory and username variables and change to that directory
username=username # <-----set username
workdir="/home/$username/auto_record_script/"
cd "$workdir"

# Set variables for transferring the recording to the server
server="path/to/server" # <-----set mount point for server share

# Check_errors function and Logfile variable
log="./auto_recording.log" # <-----set logfile directory
check_errors()
{
	if [ "${1}" -ne "0" ]; then
		echo "ERROR # ${1} : ${2}." >> "$log"
		echo "ERROR # ${1} : ${2}."
	else
		echo "SUCCESS: ${3}." >> "$log"
		echo "SUCCESS: ${3}."
	fi
}

####### VARIABLES #######

# Set variables for date and time
hour=$(date +%H)
day=$(date +%d)
mon=$(date +%m)
year=$(date +%Y)
date=$(date +%Y%m%d)

# Asks user to set variables for class and duration
echo "What is the name of what you are recording? Cual es el nombre de lo que estas grabando?"
read recording

echo "How long does the recording last (only type the number of hours)? Por cuanto tiempo dura la grabacion (contesta con el numero de horas)?"
read duration

dur=$(($duration*3600)) # Make it easy on people and convert hours to seconds for them

# Set volume level for audio inputs.
card=0 # <-----Set variable for correct sound card. Use alsamixer to find which one it is
vol='100%' # <-----Set volume for microphone input

# Find what semester we're in and set the $semester variable
if [ "$mon" -gt "6" ]; then
		semester="Agosto_Diciembre"
	else
		semester="Febrero_Mayo"
fi

# This is the final directory where your recording should be saved
finaldir="$server/Audio/$year/$semester/$recording"/"$date"_"$recording".mp3

####### END VARIABLES SECTION #######

# Prep the log file
echo ------------------------------------ >> "$log"
echo $(date) >> "$log"
echo $(date)
echo ------------------------------------ >> "$log"

####### Set Sound Levels #######
# Set sound output to 0 so it is not recorded.
## NOTE: Setting the sound levels doesn't work as well as I'd like and is not super intuitive.
##	 Could be improved with more knowledge of alsamixer or some other program (sox?)
amixer -c "$card" set "Master" 0%
check_errors $? "Muting the master output volume didn't work for some reason." "Master Output Volume muted."

# Set input levels to max and set Capture to cap
amixer -c "$card" set "Mic" $vol
check_errors $? "Setting the Mic volume did not work." "Mic set to $vol."
amixer -c "$card" set "Mic" cap
#amixer -c "$card" set "Mic Boost" $vol
amixer -c "$card" set "Capture" cap

####### Record #######
echo "Starting to record $recording."
echo "Starting to record $recording." >> "$log"

arecord -f cd -d "$dur" -t raw | lame -V8 -r - "$workdir"recordings_hoy/"$date"_"$recording".mp3 >> "$log"
check_errors $? "arecord or LAME failed. Check Exit Status for more info." "arecord and LAME worked perfect."

####### Transfer recording to the server #######
mv "$workdir"recordings_hoy/"$date"_"$recording".mp3 "$finaldir"
check_errors $? "Transfer of recording to server failed!!!!!!" "Transfer successful."

echo $(date) ": Finished recording $recording" >> "$log"
echo "-----------------------------------------------------------" >> "$log"
echo >> "$log"