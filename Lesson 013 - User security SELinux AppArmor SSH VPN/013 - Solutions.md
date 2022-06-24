# XK0-004 - Lesson 013 - Solutions

## Lab: Users and more

### Assignment 1: sudo

The lab asks you to reconfigure two extra accounts (if you don't already have them): "pete" and "support". These will get different settings applied to them in this lab.

* Run: sudo useradd -m -s /bin/bash pete
* Run: sudo passwd pete
* Run: sudo useradd -m -s /bin/bash support
* Run: sudo passwd support

The lab then asks you to make sudo rules that allows the group "support" Bash as root, with a password. Plus rules that allow "pete" to run ls, cp and cat as root, **without** password.

* Run: sudo visudo
* At the bottom of the file, add:
    * %support ALL=(root) /bin/bash
    * pete ALL=(root) NOPASSWD: /usr/bin/ps, /usr/bin/ls, /usr/bin/cat

Test your setup by:

* Logging in to the support user and run:
    * sudo -l
    * sudo /bin/bash
* Logging in to the pete user and run:
    * sudo -l
    * sudo ps
    * sudo ls
    * sudo cat /etc/shadow


### Assignment 2: chage

The lab asks you to Change the "pete" user so:

* He needs 1 day between each password change.
* His password is valid for 60 days. 

Now expire Pete's password and "su" to his account. 

* Run: sudo passwd -e pete
* Run: su - pete

Now expire Pete's account and "su" to him again.

* Run: sudo chage -E 0 pete
* Run: su - pete

Don't forget to UNexpire Pete's account again ;)

* Run: sudo chage -E -1 pete
* Run: su - pete


### Assignment 3: FACL

I will simply copy the instructions from the lab here and provide the required commands.

Create the directory /tmp/demo/ and add a few test files in there (test1, test2).

* Run: mkdir /tmp/demo/
* Run: cd /tmp/demo
* Run: for i in {1..10}; do touch file${i}; done

Use a FACL on the files to make sure that:
* User "pete" can also read/write the files.
* Group "support" can also read the files.

Run: 
* sudo setfacl -d -m u:pete:rw /tmp/demo
* sudo setfacl -m u:pete:rw /tmp/demo/file*
* sudo setfacl -d -m g:support:r /tmp/demo
* sudo setfacl -m g:support:r /tmp/demo/file*

Test this!! SU to the relevant users.

Run:
* su - pete
    * ls /tmp/demo
    * echo "Test line" >> /tmp/demo/file1
    * cat /tmp/demo/file1
    * exit
* su - support
    * ls /tmp/demo
    * echo "Support test line" >> /tmp/demo/file1    # this should fail
    * cat /tmp/demo/file1     # this should work


### Assignment 4: Ulimits

You are asked to limit user "pete" to 10 processes (soft) with a max limit of 50. 

* Run: sudo vi /etc/security/limits.conf
    * Add: pete soft nproc 10
    * Add: pete hard nproc 50

Now switch to "pete" via su and run the following. You will then see that it will get stuck after starting 9 sleep processes. Why 9? Because 9 sleeps, plus 1 bash = 10.

> for i in {1..12}
> do
> sleep 60 &
> done

This returns:

> [1] 36031
> [2] 36032
> [3] 36033
> [4] 36034
> [5] 36035
> [6] 36036
> [7] 36037
> [8] 36038
> [9] 36039
> -bash: fork: retry: Resource temporarily unavailable

Use ctrl-C to abort. Then run:

> ulimit -u 20
> for i in {1..12}
> do
> sleep 60 &
> done

This should now work and start more sleeps in the background.

Wait until all sleeps go away (or run "pkill sleep"). Now try to go over the new/temporary ulimit, by starting 20 sleeps (which will again go over the limit, because 20+1).

> for i in {1..20}
> do
> sleep 60 &
> done

Starting the final sleep should fail again.


## Lab: SELinux

These labs are "follow-along" with the slides. There is no separate walk-through


## Lab: AppArmor

These labs are "follow-along" with the slides. There is no separate walk-through


## Lab: SSH recap

### Assignment 1: new keys

Generate a new key pair on one of the accounts.  Make it type ECDSA, with a password.

* ssh-keygen -t ecdsa -f ~/.ssh/id_ecdsa-new
    * Enter a passphrase when asked for one!

Setup its pub.key for authentication on the other VM. In my case, I'm sending it to my Ubuntu VM.

* ssh-copy-id -i ~/.ssh/id_ecdsa-new.pub tess@ubuntu
    * This asks for my account's password, on the ubuntu host.

Test your SSH key authentication. 

* ssh -i ~/.ssh/id_ecdsa-new tess@ubuntu
    * This asks for the passphrase on the new key pair.


### Assignment 2: ssh-agent

SSH-agent is a piece of software which allows you to securely load your private key into memory, by entering its passphrase once. From the on, as long as your agent remains running and as long as you tell your shell how to find it, you will no longer need to enter the passphrase.

Run:
* eval $(ssh-agent)
* ssh-add ~/.ssh/id_ecdsa-new
    * This asks for the passphrase ONCE.
* ssh -i ~/.ssh/id_ecdsa-new tess@ubuntu
    * This should no longer ask for your password.


### Assignment 3: restrict SSH access

The lab asks: "Reconfigure "sshd_config" on one of the VMs, so it will only allow group "sshusers" to login."

On the target host, run:

* sudo groupadd sshusers
* sudo usermod -a -G sshusers $(whoami)
    * Check if the "dummy" user exists, with a proper password.
    * Check if it can SSH into the target host at this point.
* sudo vi /etc/ssh/sshd_config
    * At the bottom, add: AllowGroups sshusers
* sudo systemctl restart sshd

Now test if you can SSH into the target host. This should work. Then also test that "dummy" cannot SSH into the host (they don't have the right group). 

