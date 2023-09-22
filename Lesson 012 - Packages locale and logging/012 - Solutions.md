# XK0-004 - Lesson 012 - Solutions

## Lab: Managing Locales

### Assignment 1

The lab asks you to reconfigure a test/dummy account on either your Ubuntu or your Fedora VM. Hopefully you still have accounts like "dummy" or "opsuser" from previous classes. If not, quickly add a new account.

* Run: sudo useradd -m -s /bin/bash dummy
* Run: sudo passwd dummy

The lab then asks you to configure this user's .bashrc to set their locale and timezone. This user needs to be set to Russian with the "koi8r" character set, timezone Moscow.

The lab provides hints to find the right values for the variables. 

* locale -a | grep -i ^ru | grep -i koi8r
* timedatectl list-timezones | grep -i Moscow

The prior will give you "ru_RU.koi8r", the latter gives "Europe/Moscow".

* Run: sudo su - dummy
* Run: vi ~/.bashrc      # move to the end/bottom of the file
* Add the following:
    * TZ=Europe/Moscow; export TZ
    * LANG=ru_RU.koi8r; export LANG
    * LC_CALL=ru_RU.koi8r; export LC_CALL
    * LC_CTYPE=ru_RU.koi8r; export LC_CTYPE

To test these settings, SSH to the same host with user account "dummy". If you now run commands like "date" and "ls -al" you should see some errors with the character set. The timezone should be okay though. 

* Edit the ~/.bashrc file again and swith "koi8r" to "utf8".
* Logout from dummy.
* SSH back to dummy (or use su). 
* Output should now properly include Russian characters.

** NOTE: Cannot find koi8r on Ubuntu? **

* Run: sudo vi /etc/locale.gen
* Uncomment the lines for ru_RU.koi8r
* Run: sudo locale-gen


## Lab: Logging services

### Assignment 1

This lab asks you to follow the logs and to manually send a message into the system logs.

You can follow the journal with: 

* journalctl -f 

You can add a test message to the journal with either of these:

* logger "This is my test message"
* echo "This is my message." | systemd-cat -t mytest


### Assignment 2

To continue with what we learned in lab 1, we're now asked to make a shell script which tests for active root shells (like Bash). For our test, we'll run it via cron every minute. If a shell is active, an alert should be logged. 

Example shell script, which gets saved as ~/check-root.sh. You can of course save it somewhere else, like in your Git repository with lab scripts. 

* Run: vi ~/check-root.sh

> #!/bin/bash
> 
> if [[ ! -z $(ps -fC bash,sh,ksh,tmux | grep ^root) ]]
>
> then
>
> echo "Root has an active shell!" | systemd-cat -t check-root
>
> fi
>

* Run: chmod +x ~/check-root.sh

If you want to test-run the script first:

* Adjust the script to add "-x" to the shebang: "#!/bin/bash -x"
* Login as root in another window and run the script.
* Check the output of "journalctl -f".

To make the script run every minute:

* Run: crontab -e
* Add: * * * * * ~/check-root.sh

Then keep an eye on the journal logging. 

