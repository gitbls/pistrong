# pistrong
Simplified CA and device cert manager for strongSwan

## Overview

pistrong greatly simplifies the installation of the strongSwan VPN for
the roadwarrior scenario, as well as the configuration and management of
the strongSwan Certificate Authority (CA) and certificates for mobile
users.

pistrong consists of two components:

* `InstallPiStrong` - Installs and configures strongSwan for the roadwarrior
usage scenario

* `pistrong` - Used for ongoing CA and user key/cert management

## InstallPiStrong 

InstallPiStrong downloads the source and builds and installs the latest
release of strongSwan (currently 5.6.3). InstallPiStrong also creates
the strongSwan configuration and required config files for pistrong. The
installation has been fully tested on Raspbian. Support for openSuSE,
Ubuntu, Debian, and Centos is implemented but not fully end-to-end
tested.

InstallPiStrong builds strongSwan from source rather than using the
distro's strongSwan version for two reasons. Most distros are carrying
older versions of strongSwan. Additionally, most distros appear to have
built strongSwan with the legacy model, rather than the newer
--enable-systemd. pistrong only works with the new systemd model. The
download/install/build process takes 15-20 minutes on a Raspberry Pi
3B.

## pistrong
pistrong is used to create the CA and manage users. pistrong provides
commands to create (or delete) the CA, add, revoke, delete, or list
users, and simple strongSwan service management (start, stop, restart,
enable, disable, status).

The CA is maintained in `/etc/swanctl`. As mentioned previously, pistrong
requires strongSwan to be built with `--enable-systemd`.

If you have a webserver and email, pistrong can send email to the
user with a link to the certificates, and a separate email with the
password for the certificate. 

If you're using pistrong without a full InstallPiStrong, use
`InstallPiStrong postconf` which will create `/etc/swanctl/swanctl.conf`
and `~/.pistrongrc`, as well as the backup copies (in /etc/swanctl)
swanctl.piStrongInstall and .pistrongrc.piStrongInstall. This will also
create `pistrongdb.json`, which contains the CA configuration information
and the user cert database.

## Example commands

pistrong createca --vpnsankey my.special.vpnsankey

pistrong add fred --device=iPhone --mail fred@domain.com --webdir /var/www/html/vpn --weburl http://myhost/vpn --random

pistrong list fred --all

pistrong deleteca

pistrong help


## Hints

* Edit ~/.pistrongrc as needed. Strongly suggest random:True, as it
simplifies the add user workflow, and adds additional protection to your
certificates.

*For quick and dirty cert loading via the web (Raspbian example):

apt-get install apache2
mkdir /var/www/html/vpn
In ~/.pistrongrc:

   "webdir":"/var/www/html/vpn",
   "weburl":"http://hostname/vpn",
   "smtpserver":"ip address of smart smtp server",

Note that the last configuration line in .pistrongrc does not have a comma.

Then `pistrong add username --device devname --mail username@email.provider`

* For an iPhone user with the email message, it's easier to load the CA
cert first. Then copy the cert password and lastly click the device
cert. Refer to the cert link email for the fields to fill in when
creating the VPN.

* I don't think you can use a blank password for the device cert on iOS,
but why would you need to? Cut/paste the key and you're good to go.

* Configuration of your email server is beyond the scope of this
document. However, if you install postfix on a Raspberry Pi and take all
the defaults and select local mail delivery, pistrong will be able to
send mail to local users.

* Not Yet Completed

  * Android and MacOS testing - Install documentation and testing for
   these devices remains to be done.

   * Install on other distros - Additional popular distros should be added
   to InstallPiStrong
