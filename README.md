# pistrong
Simple CA and device cert manager for strongSwan

## Overview

`pistrong` greatly simplifies installing the strongSwan VPN for
the roadwarrior use case, as well as configuring and managing
the strongSwan Certificate Authority (CA) and certificates for 
user devices.

pistrong consists of two components:

* `InstallPiStrong` - Installs and configures strongSwan for the roadwarrior
usage scenario

* `pistrong` - Provides day-to-day CA and user key/cert management

## InstallPiStrong 

`InstallPiStrong` downloads the source and builds/installs the latest
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

`InstallPiStrong` has several phases. If no phase is specified, or **all** is specified,
all phases will be run. The phases include:

* **prereq** ensures that the required packages are installed on your system
* **download** downloads the latest strongSwan release 
* **preconf** runs `configure` on the strongSwan source
* **make** compiles strongSwan
* **install** installs strongSwan into the system
* **postconf** or **post-configure** creates
    * `/etc/swanctl/swanctl.conf` strongSwan config file for iOS and Windows roadwarrior use
    * `/etc/swanctl/pistrongdb.json` pistrong CA database
    * `~/.pistrongrc` pistrong config file for frequently-used settings rather than on the command line
    * Copies (in /etc/swanctl) of the just-created files swanctl.piStrongInstall, pistrongdb.piStrongInstall, and .pistrongrc.piStrongInstall

    Use this (`InstallPiStrong postconf`) if you install strongSwan with some other mechanism and want to use pistrong to manage your CA and user/device certs.

## pistrong
`pistrong` is used to create the CA and manage users. `pistrong` provides
commands to create (or delete) the CA, add, revoke, delete, or list
users, and simple strongSwan service management (start, stop, restart,
enable, disable, status).

If you have a webserver and email, `pistrong` can send email to the
user with a link to the certificates, and a separate email with the
password for the certificate. 

### Example commands

* `pistrong createca --vpnsankey my.special.vpnsankey`
    Create a new Certificate Authority using the vpnsankey as specified. The VPN SAN key is required and provides an extra level of security for iOS device authentication. 

* `pistrong add fred --device=iPhone --mail fred@domain.com --webdir /var/www/html/vpn --weburl http://myhost/vpn --random`
    Add user Fred, for the device named iPhone. Copy the necessary certs to `webdir`. Send Fred email with links to the certs using `weburl`. The device name is optional and may help you track where a cert is deployed. If --device is not specified, `dev` is used. In general, you should have `webdir`, `weburl`, and `random` configured in ~/.pistrongrc rather than specifying them on the command line.

* pistrong resend fred-iPhone --mail fred@otherdomain.com Resend the email with the links to the certs to the specified email address. This assumes that `weburl` and `webdir` are set correctly in ~/.pistrongrc

* `pistrong list fred --all [--full]`
    List all certs for user fred. Print the cert contents also if --full specified

* `pistrong deleteca`
    Delete the whole CA including all user certs. You will be asked "are you sure", since this is irreversible and will require that **all** issued certs be replaced.

* pistrong makevpncert --altsankey "IPAddress,FQDN,"
    Create a new VPN key and cert with additional SAN keys. This can be done without re-installing client certs.

* `pistrong help`
    Print some online help


## Hints

* Edit ~/.pistrongrc as needed. Strongly suggest random:true, as it
simplifies the add user workflow, and adds additional protection to your
certificates.

* For quick and dirty cert loading via the web (Raspbian example):

    * `apt-get install apache2`
    * `mkdir /var/www/html/vpn`
    * In ~/.pistrongrc:

        "webdir":"/var/www/html/vpn",  
        "weburl":"http://hostname/vpn",  
        "smtpserver":"ip address of smart smtp server",

    Note that the last configuration line in .pistrongrc before the close brace must not have a comma. 

* Email server configuration is beyond the scope of this
document. However, if you install postfix (on a Raspberry Pi), take all
the defaults, and select local mail delivery, pistrong will be able to
send mail to local users.

## Security considerations

For the most secure implementation, here are some things to consider:

* Always use an FQDN hostname (hostname.domain.com) for a registered domain. If you do not have a static IP address, use a dynamic DNS service. The FQDN hostname helps ensure that your client is connecting to a known host, and is the most reliable way to connect to your VPN from the internet.

* If you don't have an FQDN for the VPN server, you may need to use --vpnsankey yourExternalIPAddress when you create the CA. 

* pistrong easily enables a one certificate for multiple devices, or a one certificate per device scenario. The former is a bit easier, the latter provides finer granularity access control.

## Not Yet Completed

  * Android and MacOS testing - Certificate install testing and documentation for these devices.

  * Install on other distros - Additional popular distros should be added to InstallPiStrong

  * More usage. Besides me, that is. 

  * Improved username/keyname validation. Checks are very minimal now, and effects of strange characters are unknown, but do not pose any known security risk.

## If you're interested...

Please refer to the issues list if you have ideas for improving this tool or have found a problem, and if nobody else has mentioned it, I would be very happy to hear from you. There's always the possibility of a bug that I missed ;), or a great feature that should be added.

Or, if you're so inclined, do it yourself and leave a pull request.

Testing and documenting cert installation steps for Android and MacOS is another area where your help would be greatly appreciated, in addition to adding support to InstallPiStrong for more Linux distros.