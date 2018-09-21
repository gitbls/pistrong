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

`InstallPiStrong` downloads the source and builds and installs the latest
release of strongSwan (currently 5.6.3). It also creates
the strongSwan configuration and required config files for `pistrong`. The
installation has been fully tested on Raspbian. Support for openSuSE,
Ubuntu, Debian, and Centos is implemented but not fully end-to-end
tested.

`InstallPiStrong` builds strongSwan from source rather than using the
distro's strongSwan package since most distros are carrying older
versions of strongSwan. Additionally, not all distros appear to have
strongSwan built with `--enable-systemd`. `pistrong` only works with the
new systemd model. The download/install/build process takes 15-20
minutes on a Raspberry Pi 3B.

## pistrong
`pistrong` is used to create the CA and manage users. `pistrong` provides
commands to create (or delete) the CA, add, revoke, delete, or list
users, and simple strongSwan service management (start, stop, restart,
enable, disable, status).

If you have a webserver and email, `pistrong` can send email to the
user with a link to the certificates, and a separate email with the
password for the certificate. 

If you want to use `pistrong` without a full InstallPiStrong install, use `InstallPiStrong postconf` which will create:

* `/etc/swanctl/swanctl.conf` strongSwan config file for iOS and Windows roadwarrior configuration
* `/etc/swanctl/pistrongdb.json` pistrong CA database
* `~/.pistrongrc` pistrong config file for frequently-used settings rather than on the command line
* Copies (in /etc/swanctl) of the just-created files swanctl.piStrongInstall, pistrongdb.piStrongInstall, and .pistrongrc.piStrongInstall

## Example commands

* `pistrong createca --vpnsankey my.special.vpnsankey`
    Create a new Certificate Authority using the vpnsankey as specified. The VPN SAN key provides an extra level of security for iOS device authentication. 

* `pistrong add fred --device=iPhone --mail fred@domain.com --webdir /var/www/html/vpn --weburl http://myhost/vpn --random`
    Add user Fred, for the deivce iPhone. Copy the necessary certs to `webdir`. Send Fred mail at the specified email address with links to the certs using `weburl`. The device name is a convenience to help you identify where a cert is deployed. If --device is not specified, `dev` is used.

* `pistrong list fred --all`
    List all certs for user fred

* `pistrong deleteca`
    Delete the whole CA including all user certs. You will be asked "are you sure", since this is irreversible and will require that all issued certs be replaced.

* `pistrong help`
    Print some online help


## Hints

* Edit ~/.pistrongrc as needed. Strongly suggest random:True, as it
simplifies the add user workflow, and adds additional protection to your
certificates.

* For quick and dirty cert loading via the web (Raspbian example):

    * `apt-get install apache2`
    * `mkdir /var/www/html/vpn`
    * In ~/.pistrongrc:

        "webdir":"/var/www/html/vpn",  
        "weburl":"http://hostname/vpn",  
        "smtpserver":"ip address of smart smtp server",

    Note that the last configuration line in .pistrongrc must not have a comma. 

* For an iPhone user who has received the email message, it's easier to load the CA
cert first. Then copy the cert password and lastly click the device
cert. Refer to the cert link email for the fields to fill in when
creating the VPN.

* I don't think you can use a blank password for the device cert on iOS (but
  you can on Windows). Why would you need to? Cut/paste the key and you're good
  to go.

* Email server configuration is beyond the scope of this
document. However, if you install postfix (on a Raspberry Pi), take all
the defaults, and select local mail delivery, pistrong will be able to
send mail to local users.

## Not Yet Completed

  * Android and MacOS testing - Install documentation and testing for
   these devices remains to be done.

   * Install on other distros - Additional popular distros should be added
   to InstallPiStrong
