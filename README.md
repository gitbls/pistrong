# pistrong
Simplified CA and device cert manager for the strongSwan VPN

## Overview

`pistrong` dramatically simplifies installing and configuring the strongSwan VPN. Once installed, pistrong simplifies managing the strongSwan Certificate Authority (CA) and Certificates for remote user devices connecting to the VPN. pistrong fully supports the Cert-authenticated roadwarrior use case (users on devices), and can be used to create and manage certs for other uses, such as host-to-host or LAN-to-LAN tunnels.

pistrong includes complete installation, configuration, and management support for Raspbian/Debian distros. There is basic install/config support for openSuSE, Ubuntu, Debian, and Centos. pistrong itself is distro-independent, so can be used on any distro once strongSwan is properly installed and configured.

Using pistrong, it's typically possible to have strongSwan up and running with clients securely connecting in 30-60 minutes.

pistrong consists of a couple of different components:

* `pistrong` - Day-to-day CA and user Key/Cert management

* `InstallPiStrong` - Install and configure strongSwan

* `makeMyCA` - Use makeMyCA to create your secure custom CA after completing the installation. Or you can roll your own of course, using this as a model. Or not ;).

## Up and Running Quickly!

Before diving in, decide if you're going to use a DNS name (strongly preferred!) for external VPN access.Your public DNS IP address can be static or dynamic, depending on your Internet connection or ISP provider. If you don't use a DNS name, then you'll need to use your external IP address to access the VPN.

If you're going to use a DNS name, it's best to ensure this is properly set up before proceeding (although it's quite easy to reset and start over if you change your mind).

To access your VPN from outside your LAN, configure your router to forward UDP ports 500 and 4500 to the LAN IP address of your strongSwan server.

Now that you've attended to the external network considerations, it's time to install and configure pistrong and strongSwan.

* Copy pistrong, InstallPistrong, and makeMyCA to your local system

    The easiest way to install pistrong is to use the bash command:

    `sudo curl -L https://raw.githubusercontent.com/gitbls/pistrong/master/EZPiStrongInstaller | bash`

    This will download pistrong and InstallPiStrong to /usr/local/bin, and then start `InstallPiStrong all` to fully install and configure strongSwan. See the InstallPiStrong section below for distro-specific details.

    If you'd prefer to not feed an unknown script directly into bash, you can issue the following commands on your local system:

    `sudo curl -L https://raw.githubusercontent.com/gitbls/pistrong/master/pistrong -o /usr/local/bin/pistrong`

    `sudo curl -L https://raw.githubusercontent.com/gitbls/pistrong/master/InstallPiStrong -o /usr/local/bin/InstallPiStrong`
    
    `sudo curl -L https://raw.githubusercontent.com/gitbls/pistrong/master/makeMyCA -o /usr/local/bin/makeMyCA`
    
    `sudo chmod 755 /usr/local/bin/{pistrong,InstallPiStrong,makeMyCA}`
    
    `sudo /usr/local/bin/InstallPiStrong all`

* `sudo InstallPiStrong` - Perform the complete download, build, install, and initial configuration
* `sudo makeMyCA` - Create a secure custom CA
* **Add your users and devices.** These examples assume the username is *username*, and are taking the default *dev* for the device name. You can ease your management by adding `--dev something` which directs pistrong to add the string *something* to the name of this user. This is especially important if a user has multiple devices and you want to use a different cert on each device. Conversely, if a user's cert is going to be used across multiple devices, you don't need to use `--dev`.
    *  iOS users: `pistrong add username --remoteid ios.yourdomain.com`
    *  Windows users: `pistrong add username --remoteid windows.yourdomain.com`
    *  Linux users: `pistrong add username --remoteid linux.yourdomain.com --linux`
* `sudo systemctl enable --now strongswan` - Enable and start the strongSwan service

Now it's time to install and configure the client or device. Follow the user's OS-specific Cert installation instructions at [Client Certificate Installation and VPN Configuration](https://github.com/gitbls/pistrong/blob/master/CertInstall.md) to install the Cert and configure the VPN.

See [Installation Log](https://github.com/gitbls/pistrong/blob/master/log-installpistrong.txt) for a session log which is the result of installing and configuring pistrong and InstallPiStrong. Also see [makeMyCA log](https://github.com/gitbls/pistrong/blob/master/log-makeca.txt) to see the configuration of a CA and adding a couple of users.

## pistrong

Once strongSwan has been installed and configured, use `pistrong` to create the CA and manage users. `pistrong` provides
commands to create (or delete) the CA, add, revoke, delete, or list
users, and simple strongSwan service management (start, stop, restart,
enable, disable, status, and reload). The makeMyCA script discussed above super-simplifies the initial CA creation.

You can also use pistrong to easily configure and manage a strongSwan-based Linux VPN client connecting to a pistrong-managed strongSwan server. See the Linux RoadWarriors section below.

If you have a webserver and an email server installed locally, `pistrong` can send email to the
user with a link to the certificates, and a separate email with the
password for the certificate. See section below on Local Mail for a quick and easy way to install a local-only email on your system.

### Example commands

* `pistrong createca --vpnsankey my.special.vpnsankey` - Create a new Certificate Authority using the vpnsankey as specified. The VPN SAN key is required and provides an extra level of security for iOS device authentication. See CertDetails.md for more information on VPN SAN keys.

* `pistrong add fred --device iPhone --mail fred@domain.com` - Add user *fred*, for the device named *iPhone*. Copy the necessary certs to `webdir` (see Configuration below). Send *fred* email with links to the Certs using `weburl`. The device name is optional and may be helpful to track where a Cert is targeted. If --device is not specified, the string *`dev`* is used.

* `pistrong resend fred-iPhone --mail fred@otherdomain.com` - Resend the email with the links to the Certs to the specified email address. 

* `pistrong list fred --all [--full]` - List all Certs for user *fred*. Print the cert contents as well if --full specified

* `pistrong deleteca` - Delete the whole CA including all user Certs. You will be asked to confirm, since this is irreversible and will require that **all** issued Certs be replaced. **Everything will be deleted. Be really sure, especially if you have more than a couple of users.**

* `pistrong makevpncert mynewcert --vpnsankey the.other.clients` - Create a new VPN Key and Cert with a different SAN key
* `pistrong service reload` - Ask strongSwan to reload the credential database. This must be done to activate changes made into the running system

* `pistrong help` -- Display detailed online help

## InstallPiStrong 

`InstallPiStrong` downloads the source and builds/installs the latest
release of strongSwan. It also creates
the strongSwan configuration and required config files for `pistrong`. The
installation has been fully tested on Raspbian. Support for openSuSE,
Ubuntu, Debian, and Centos is implemented but not fully end-to-end
tested.

`InstallPiStrong` builds strongSwan from source rather than using the
distro's strongSwan package since most distros are carrying older
versions of strongSwan. Additionally, not all distros appear to have
strongSwan built with `--enable-systemd`. `pistrong` only works with the
new systemd model. The download/build/install process takes about 20
minutes on a Raspberry Pi 3B with a reasonable internet connection.


`InstallPiStrong` has several phases. If no phase is specified or **all** is specified,
all phases will be run. InstallPiStrong will pause at the start of each phase to provide time for reviewing the results of the previous phase. The phases include:

* **prereq** ensures that the required packages are installed on your system
* **download** downloads the latest strongSwan source tarball 
* **preconf** runs `configure` on the strongSwan source to ensure proper system configuration
* **make** compiles and builds strongSwan
* **install** installs strongSwan into the system
* **postconf** or **post-configure** creates
    * `/etc/swanctl/conf.d/pistrong-ServerConnection.conf` strongSwan config file for iOS and Windows roadwarrior use
    * `/etc/swanctl/pistrong/iptables` required iptables addition. See Firewall Considerations section below
    * `/etc/swanctl/pistrong/backup/connections-pistrong.piStrongInstall` copy of the initial pistrong-ServerConnection.conf for future reference if needed

If you know that your distro is carrying strongSwan 5.8.0 or greater, and it has been built with --enable-systemd, you can install strongSwan from your distro and skip the download, preconf, make, and install phases. That is, you'll only need to do the preqreq and postconf phases.

Use `InstallPiStrong postconf` if you install strongSwan with some other mechanism and want to use pistrong to manage your CA and user/device Certs.

## Resetting Everything

If you want to completely delete and reset the CA, and the whole strongSwan/pistrong directory tree, you can do that relatively easily. *This will completely invalidate all user certs!*

* `sudo systemctl stop strongswan` - Stop the strongswan service
*  `cd /etc`
*  `sudo mv swanctl old-swanctl` - Rename the /etc/swanctl directory to /etc/old-swanctl. Keep this copy until you're sure it's no longer needed
*  `sudo InstallPiStrong install` - Recreates the /etc/swanctl directory tree
*  `sudo InstallPiStrong postconf` - Configures pistrong for initial operation
*  `sudo makeMyCA` - Create a new CA. Use this, or your own script, as desired.
*  Now you are ready to add new users or devices to the CA

## Linux Roadwarrior Support

pistrong supports Linux Roadwarrior users. The easiest approach is to use strongSwan on the Linux client, and installing it via:

* Download pistrong and InstallPiStrong onto the Linux client system as described above
* `sudo InstallPiStrong` - Download, build, and install strongSwan
    * In the postconf phase, InstallPiStrong will ask if the VPN server should be enabled. For a client-only system, answer No. If you change your mind in the future, you can rerun `sudo InstallPiStrong postconf` to enable VPN server connections to your Linux Roadwarrior system.
* The manager of the strongSwan server to which you want to connect adds Linux clients to the server by using `sudo pistrong add clientname --remoteid linux-remoteid --linux`.

    For instance, using the default CA built by makeMyCA, one might use `sudo pistrong add tomspi --device pi4 --remoteid linux.mydomain.com --linux`.

    NOTE: For Linux clients, you must use the name of the Linux client system for the name. For example, the above command assumes that the hostname is tomspi.

    The `--linux` switch causes pistrong to create a Linux Client Cert Pack. Once the Cert Pack (zip file) has been copied to the Linux Roadwarror system, install the new connection with `sudo pistrong client install zip-file`. The zip file has the certificates and connection information for the remote VPN server.

* Connect to the remote strongSwan VPN server with `sudo pistrong client start server.fqdn.com`
* Stop the remote connection with `sudo pistrong client stop`

## Firewall Considerations

strongSwan requires changes to the Firewall for proper operation. In case you don't have a firewall installed, InstallPiStrong writes a new systemd service pistrong-iptables-load, which contains only the VPN-required Firewall rules. If you want to use this service, `sudo systemctl enable pistrong-iptables-load` before rebooting.

Many users either have or want more than this very minimal firewall. In that case, the iptables rules in /etc/swanctl/pistrong/iptables must be added to the Firewall rules for your system.

## Hints

* Use the `pistrong config` command to quickly and easily configure pistrong for your system. See [makeMyCA](https://raw.githubusercontent.com/gitbls/pistrong/master/makeMyCA), which creates a fully-functional CA to serve iOS, Windows, and Linux roadwarriors.

* Typically you'll want to include your host FQDN as one of the VPN SAN keys, unless you are using an IP address to access your VPN server. In that case, you'll need to include the IP address. For maximum flexibility, pistrong does not apply the host FQDN or IP address as SAN keys. It's suggested that you put the VPN-specific SAN key first. For example, `--vpnsankey myipsec.home.vpn,myhost.mydomain.com`. pistrong will add both SAN keys to the VPN cert. The VPN SAN key should match the value for the --remoteid switch. The --remoteid value is sent to the user in email.

    Note, however, makeMyCA DOES add the host FQDN to the SAN keys it creates.

* After adding/deleting/revoking users, use `pistrong service reload` to cause strongSwan to reload all credentials.

* If you need to use multiple strongSwan connections (for different users accessing different local subnets, for example), here is an outline of how to do this:
    * Establish the primary configuration with the desired CA Cert and VPN SAN keys.

    * Create a secondary CA and a VPN Cert/Key in that secondary CA with a different VPN SAN key

    * Create a new .conf file in /etc/swanctl/conf.d with the new connection using the secondary CA, VPN SAN Key, and secondary VPN Cert. Also add a secondary IP address pool.

    * When adding users, always specify --cacert and --remoteid to specify the secondary VPN SAN Key to ensure that the user Cert is assigned to the correct connction.

    * **NOTE:** If you ever re-create the CA using deleteca/createca you'll need to recreate the secondary Cert/Key and validate the connection details in /etc/swanctl/conf.d/pistrong-ServerConnection.conf, so don't deleteca unless you're really sure!

* Email and web server configuration is beyond the scope of this document. There are lots of guides on the internet for this, such as https://raspberrytips.com/mail-server-raspberry-pi/, but also see the section on Local Mail below.

* If you have issues with trying the VPN on your local network, you should consider installing a local LAN DNS server rather than depending on your router or other less deterministic naming systems.

    [ndm](https://github.com/gitbls/ndm) provides a simple DNS and DHCP server manager using the Bind9 DNS server and ISC DHCP Server. Of course, you can use any name server you'd prefer.

    I've found that having my local LAN domain name be the same as my external domain name (static or dynamic) makes VPN testing on the LAN SO much easier.

## Security considerations

For the most secure implementation, here are some things to consider:

* Always use an FQDN hostname (hostname.domain.com) for a registered domain. If you do not have a static IP address, use a dynamic DNS service. The FQDN hostname helps ensure that your client is connecting to a known host, and is the most reliable way to connect to your VPN from the internet. This also insulates you from your ISP randomly changing your external, dynamically-assigned IP address and invalidating your whole CA.

* If you don't have an FQDN for the VPN server, you will probably need to use `--vpnsankey my.san.key,yourExternalIPAddress` when you create the CA. `makeMyCA` offers this as an option.

* pistrong easily enables a one certificate for multiple user devices, or a one certificate per user device scenario. The former is a wee bit easier, the latter provides finer granularity access control.

## Local Mail

If your system does not have the capability to send email, you can easily install a local-only email system. Here are the steps:

* Install postfix -- `sudo apt-get install bsd-mailx postfix libsasl2-modules` You don't really need bsd-mailx but it may be useful to have a local bash shell mail command for testing.

* Install dovecot -- See the script [install-dovecot](https://raw.githubusercontent.com/gitbls/pistrong/master/install-dovecot). This will install and configure dovecot for local, non-ssl usage, which should be fine for installing pistrong-created certs to your Windows or iOS device.

* You'll also need to have a webserver installed. If you `sudo apt-get install apache2` before running makeMyCA everything will be set up correctly. You may need to restart the apache2 service after running makeMyCA. If you install apache2 after running makeMyCA, you may need to execute this command: `echo "ServerName vpnserver.fqdn" > /etc/apache2/conf-enabled/servername.conf`, of course, replacing vpnserver.fqdn with the fully-qualified domain name for your VPN Server.

## Not Yet Completed

  * Android and MacOS testing - Certificate install testing and documentation for these devices.

  * In-depth crypto performance/security tradeoff evaluation.

  * Install on other distros - Additional popular distros should be added to InstallPiStrong

  * More usage. Besides me, that is. 

  * pistrong does not provide a way to delete a single CA or VPN Cert.

  * There is no upgrade from earlier versions of pistrong to v3. If you need help with this, open an issue on github.

## If you're interested...

Please refer to the issues list if you have ideas for improving pistrong or have found a problem. I would be very happy to hear from you. There's always the possibility of a bug that I missed ;), or a great feature that should be added.

Or, if you're so inclined, do it yourself and leave a pull request.

Testing and documenting cert installation steps for Android and MacOS is another area where I would really appreciate your help.
