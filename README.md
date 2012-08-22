# Automatic Audio Recording

A bash script for automatically (with cron) recording sound which also compresses, names properly, and sends it off to the directory of your choice. Pretty sweet, huh?

## How do I get this thing working?

If you're new to scripting or Linux in general, this section is for you! If you're already familiar with these things, you can skip ahead to the "How to Contribute" section.

***********************
This script can only be used on Unix systems. Unfortunately, for right now it also has dependencies that come with Ubuntu (namely, alsamixer). If you're on a different flavor of Linux, you'll want to either comment out the volume-setting section or install alsamixer.
***********************

To start using this script for automatic recording, you'll need to do a few things:
* Make sure you have alsamixer and lame installed
* Download this to your home folder. If you have git installed, the easiest way is to run `git clone https://github.com/gorrillamcd/auto_record_script.git`
* Change certain variables in the script to match your needs and make the script executable
* Make a list of each recording you want in the recording_schedule file
* Fill in your crontab with the various times that you will be recording
* Make sure the directories where the script will save recordings have been created and your user has write-access.

### Using recording_schedule

recording_schedule is the file where you list all of your recordings. It is well commented and should be fairly easy to figure out. Here's an example:

108:morningmeeting:1

The first digit is the day of the week (0 is Sunday, 6 is Saturday). The next two digits are the hour of the day (08 is 8:00am, 20 is 8:00pm). Then you have the name of the recording and it's duration in hours.

### Filling in the crontab

If you need to know how to use crontab, here is a good tutorial: http://www.cyberciti.biz/faq/how-do-i-add-jobs-to-cron-under-linux-or-unix-oses/

Your cron entries should look something like this:

    Min Hour Day-of-Month Month Day-of-Week Where your script is
    00 	08 	 *            02-06 1-5         /path/to/script

This entry would run a command/script at 8:00 in the morning every weekday from February through June (a normal school spring semester).

### Making the Directories

The script is designed to move the recording to another directory (a file-server in my case). If something goes wrong and the file can't be moved, it will be logged and your file will still be in the recordings_hoy folder, so nothing is lost.

I prefer file organization with more directories than the normal person, so by default, the script will save the file to /server/Audio/year/semester/recordingname/date_recordingname.mp3

If you want the final directory where the recording will be saved to be different, you can change the variable in the script called $finaldir. You'll also want to set your server's mount point in the variable $server. You can mount your server using an entry in fstab. Other than that, just make sure your directories are made beforehand for each recording name that you use and make sure your user has write access to the directories.

### Setting variables and chmod

Some variables need to be set the first time you use this script. Look in the script and they are commented fairly obviously. You might also need to make the script executable. That's as easy as:
`chmod +x ./auto_recording.sh`

You'll most likely need to have root privileges to do that. If you have it, use sudo in front of the command. Otherwise, just open a root shell or use su.

### ondemand_recording.sh

There is also a modified version of the script for recording on-demand. When it's run, it prompts the user to input the recording name and duration instead of grabbing those from the recording_schedule.

## How to Contribute

Just fork the directory and submit a pull request. If you don't know how to contribute via github, contact me using the contact form on my website. Check out the TODO section below for some of the more obvious/necessary improvements.

## TODO

* Rewrite volume setting section so it's not dependent on alsamixer.
* Fix bug with logging where multiple recordings overlap in the log (minor)
* Set default duration on recordings so that, when no duration is explicitly set, the recording will not go on forever (important)
* Set a variable for compression options so that it's easier to change (important)
* Write installation script for creating directories, filling in the class_schedule file, and creating cron entries. After all, this does have "automatic" in the name. (important)