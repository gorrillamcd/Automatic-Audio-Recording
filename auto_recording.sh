#!/bin/bash

########################################################################
# Auto Sound Recording v1.2			LAST EDITED: 2012/03/03
#
# AUTHOR: GorrillaMcD		    ORIGINALLY MADE FOR: ccbcmexico.com
#
# LICENSE INFO: You are free to use this script or make derivative
# works or even distribute it. You are never allowed to sell it and it
# should only be distributed gratis (free!!).
#
# If you do distribute this script, you must include the readme,
# supporting files, and a link back to http://techonamission.com
#
# Did you have some improvements to the script? Be a friend and pass
# them upstream. You can make a pull request on github.com
########################################################################

# Set working directory and username variables and change to that directory
username=username # <-----set username
workdir="/home/$username/recording/"
cd "$workdir"

# Set where the schedule file is. This determines both the name of the class and duration
schedule="./recording_schedule" # <-----set schedule directory

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
day=$(date +%d)
mon=$(date +%m)
year=$(date +%Y)
date=$(date +%Y%m%d)

# Variable sets the day of the week and hour so that grep can match the correct recording name.
time=$(date +%w%H)

# These set the recording and duration from the recording_schedule file.
# TODO: If there is not a recording that matches, it will record a file with no recording name and no duration (it will go on for infinity). Not good.
recording=$(grep "$time" "$schedule" | awk -F: '{print $2}')
duration=$(grep "$time" "$schedule" | awk -F: '{print $3}')

dur=$(($duration*3600)) # Make it easy on people and convert hours to seconds for them

# Set volume level for audio inputs.
card=0 # <-----Set variable for correct sound card. Use alsamixer to find which one it is
vol='100%' # <-----Set volume for microphone input

# Set variables for transferring the recording to the server
server='/path/to/server' # <-----set mount point for server share

if [ "$mon" -gt "6" ]; then  # Find what semester we're in and set the $semester variable. This is useful for schools to organize recordings by semester.
		semester="Agosto_Diciembre"
	else
		semester="Febrero_Mayo"
fi

finaldir="$server/Audio/$year/$semester/$recording"/"$date"_"$recording".mp3
# This is where the file will be saved on the server.
# TODO: All directories must be made ahead of time for it to work.

####### END VARIABLES SECTION #######

# Prep the log file
# TODO: The log has an issue when recording an audio file immediately after another one.
echo ------------------------------------ >> "$log"
echo $(date) >> "$log"
echo $(date)
echo ------------------------------------ >> "$log"

####### Set Sound Levels #######
# Set sound output to 0 so it is not recorded.
## TODO: Setting the sound levels doesn't work as well as I'd like and is not super intuitive.
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

# TODO: Set a variable for compression options in case someone wants more or less compression
arecord -f cd -d "$dur" -t raw | lame -V8 -r - "$workdir"recordings_hoy/"$date"_"$recording".mp3 >> "$log"
check_errors $? "arecord or LAME failed. Check Exit Status for more info." "arecord and LAME worked perfect."

####### Transfer recording to the server #######
mv "$workdir"recordings_hoy/"$date"_"$recording".mp3 "$finaldir"
check_errors $? "Transfer of recording to server failed!!!!!!" "Transfer successful."

echo $(date) ": Finished recording $recording" >> "$log"
echo "-----------------------------------------------------------" >> "$log"
echo >> "$log"