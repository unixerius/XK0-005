# Case 1: NTP Server

I will make Ubuntu the NTP server, Fedora the NTP client.


## Walkthrough for Ubuntu

First, check if an NTP daemon is already running:

`ps -fC ntpd,chronyd`

Check if one is available:

`sudo systemctl list-unit-files | grep -e ntp -e chrony`

Let's install ntpd.

`sudp apt search ntp`

Look through the list for NTP client or tools.

`sudo apt install -y ntp`

Let's enable the service and make sure it runs at boot.

```
sudo systemctl enable ntp
sudo systemctl start ntp
ps -ef | grep ntp
```

This should show a running /usr/sbin/ntpd.

We can configure the NTP daemon through /etc/ntp.conf

First, make a backup copy.

`sudo cp /etc/ntp.conf /etc/ntp.conf.orig`

Then edit the file. We want to make sure we allow the daemon to be queried by hosts in our subnet. This is done by adding a "restrict" line, with the others.

`restrict 10.0.2.0 mask 255.255.255.0`

Then restart the service

```
sudo systemctl restart ntp
sudo systemctl status ntp
```

Now, I know from experience (that's why it's on the slides) that I can check if NTPd is properly talking to peer servers.

`sudo ntpq`

Then type "lpeers" and press enter. This should show the peer servers NTPd is connected to. 

To open up the NTPd, we may need to open the firewall on Ubuntu. 

`sudo ufw app list`

Unfortunately that does not show NTPd as standard option. So we need to figure out (with "man ufw") how to add a protocol + port based rule.

`sudo ufw rule allow in from 10.0.2.0/24 proto udp port 123 comment ntpd`

You can now test if this works from Fedora:

```
echo 1 >/dev/udp/ubuntu/123
echo $?
```

If that returns quickly and with exitcode 0, you're good to go.


## Walkthrough for Fedora

On Fedora, let's check if NTP is already running

`ps -fC ntpd,chronyd`

In my case, Chrony is already running. So we can just go and adjust the configuration file.

```
sudo cp /etc/chrony.conf /etc/chrony.conf.orig
sudo vi /etc/chrony.conf
```

We need to change the server configuration! Let's remove all the Internet-based servers and only set the NTP client to talk to our Ubuntu box. You REMOVE all the "pool" lines and ADD a server line. See "man chrony.conf"

Restart and test!

```
sudo systemctl restart chrony
sudo systemctl status chrony
```

Let's check that it's working.

```
chronyc sources
chronyc tracking
chronyc activity
```

It should show that the Fedora Chronyd is syncing with the Ubuntu VM. 

