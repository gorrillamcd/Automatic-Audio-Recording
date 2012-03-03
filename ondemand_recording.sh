#!/bin/bash

##########################################################################
# Auto Sound Recording				LAST EDITED: 2012/01/23
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
# variable such as duration and class name. This one is meant to be called
# when needed and not from cron.

# Set working directory and username variables and change to that directory
username=username # <-----set username
workdir="/home/$username/recording/"
cd "$workdir"

# Check_errors function and Logfile variable
log="./class_recording.log" # <-----set logfile directory
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
bhour=14 # <--set the hour that block classes start
hour=$(date +%H)
day=$(date +%d)
mon=$(date +%m)
year=$(date +%Y)
date=$(date +%Y%m%d)

# Asks user to set variables for class and duration
echo "What class are you recording? Cual es la clase que estas grabando?"
read class

echo "How long does the class last (only type the number of hours) Por cuanto tiempo dura la clase (contesta con el numero de horas)?"
read duration

dur=$(($duration*3600)) # Make it easy on people and convert hours to seconds for them

# Set volume level for audio inputs.
card=0 # <-----Set variable for correct sound card. Use alsamixer to find which one it is
vol='100%' # <-----Set volume for microphone input

# Set variables for transferring the recording to the server
server="path/to/server" # <-----set mount point for server share

if [ "$mon" -gt "6" ]; then  # Find what semester we're in and set the $semester variable
		semester="Agosto_Diciembre"
	else
		semester="Febrero_Mayo"
fi

finaldir="$server/Audio/$year/$semester/$class"/"$date"_"$class".mp3 # Put it all together.

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

####### Record Class #######
echo "Starting to record $class."
echo "Starting to record $class." >> "$log"

arecord -f cd -d "$dur" -t raw | lame -V8 -r - "$workdir"recordings_hoy/"$date"_"$class".mp3 >> "$log"
check_errors $? "arecord or LAME failed. Check Exit Status for more info." "arecord and LAME worked perfect."

####### Transfer recording to the server #######
mv "$workdir"recordings_hoy/"$date"_"$class".mp3 "$finaldir"
check_errors $? "Transfer of recording to server failed!!!!!!" "Transfer successful."

echo $(date) ": Finished recording $class" >> "$log"
echo "-----------------------------------------------------------" >> "$log"
echo >> "$log"
