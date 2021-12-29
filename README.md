# pistrong
Simple, Secure Certificate-based authentication manager for the strongSwan VPN

## Overview

`pistrong` dramatically simplifies installing and configuring the strongSwan VPN. Once installed, pistrong simplifies managing the strongSwan Certificate Authority (CA) and Certificates for remote user devices connecting to the VPN. pistrong fully supports the Cert-authenticated use case (users on devices), and can be used to create and manage certs for other strongSwan VPN scenarios, such as host-to-host or site-to-site tunnels.

The pistrong software package includes complete installation, configuration, and management support for Raspbian/RasPiOS and Debian-based distros. Other distros can be easily supported, since the only required changes are in the installer. Support for additional distros will be added based on inquiries.

Using pistrong, it's typically possible to have strongSwan up and running with clients securely connecting in **less than an hour**.

pistrong components include:

* `pistrong` - Day-to-day CA and user Key/Cert management

* `InstallPiStrong` - Install and configure strongSwan

* `makeMyCA` - Create your secure custom CA supporting iOS, Windows, and Linux Clients after completing the installation. Or you can roll your own of course, using this as a model.

* `makeTunnel` - Use makeTunnel to create a Site-to-Site (remote LANs are accessible) or Host-to-Host VPN (remote LANs are not accessible) with strongSwan on both ends of the VPN.

**NOTE:** It's 99%  likely that MacOS and Android clients will work as well, but they have not been tested. If you have either of these and want to help me document these, let me know via a GitHub issue.

If you find pistrong useful, please consider starring it to help me understand how many people are using it. Thanks!

## Installation Videos

If you prefer to watch videos to learn, you'll find these interesting.

* Install pistrong and strongSwan on Debian Bullseye &mdash; [Install and configure a VPN Server and Client Cert Manager](https://youtu.be/gDvglvgtYzY)
* Install pistrong and strongSwan and configuring a site-to-site VPN &mdash; [Install and configure a Site-to-Site VPN](https://youtu.be/mUitM2JeKRc)

Since Debian Bullseye is new, many people are still running Buster. The strongSwan package in Buster is a bit old, so InstallPiStrong will download and install strongSwan from the source tarball. Watch this [here](https://youtu.be/SONenXy4IiY). (Long wait times have been edited out of this video, so the 14-minute install on a Pi4 can be viewed in less than a minute.)

## Up and Running Nearly Instantly!

Before diving in, decide if you're going to use a DNS name (highly recommended!) for external VPN access.Your public DNS IP address can be static or dynamic, depending on your Internet connection or ISP. If you don't use a DNS name, then you'll need to use your external IP address to access the VPN. If you're planning to use an IP address, there are ramifications so please read the section below: Using an IP Address for VPN Access.

If you're going to use a DNS name, it's best to ensure this is properly set up before proceeding. If you don't have a static external IP address, you can use a dynamic DNS service such as www.dyn.com, www.noip.com, etc. NoIP, for example, provides a small Linux tool that will monitor your external IP address and if it changes, updates selected DNS names.

To access your VPN from outside your LAN, configure your router to forward UDP ports 500 and 4500 to the LAN IP address of your strongSwan server.

Now that you've attended to the external network considerations, it's time to install and configure pistrong and strongSwan.

* **Download and run InstallPiStrong**. InstallPiStrong will download the remaining pistrong components from GitHub, and then install strongSwan. You will have the choice of installing either the strongSwan that is delivered with your apt-based distro, or building the latest version from sources from strongswan.org

Download and run the installer on your local system:

    sudo curl -L https://raw.githubusercontent.com/gitbls/pistrong/master/InstallPiStrong -o /usr/local/bin/InstallPiStrong
    sudo chmod 755 /usr/local/bin/InstallPiStrong
    sudo /usr/local/bin/InstallPiStrong

* **Create your CA** You can do this manually, or use the makeMyCA script. makeMyCA uses pistrong to create a complete, secure, and ready-to-use CA for iOS, Windows, and Linux clients. See below for details.

* **Add your users and devices.** These examples assume the username is *username*, and are taking the default *dev* for the device name. You can ease your management by adding `--dev something` which directs pistrong to add the string *something* to the name of this user. This is especially important if a user has multiple devices and you want to use a different cert on each device. Conversely, if a user's cert is going to be used across multiple devices, you don't need to use `--dev`, although you certainly can.
    *  iOS users: `pistrong add username --remoteid ios.yourdomain.com`
    *  Windows users: `pistrong add username --remoteid windows.yourdomain.com`
    *  Linux users: `pistrong add username --remoteid linux.yourdomain.com --linux`
    *  `sudo systemctl enable --now strongswan` &mdash; Enable and start the strongSwan service

    Create multiple certs for a user with multiple devices in the following manner. Note that the value provided to --dev is strictly for your use to keep track of different devices, so can be anything you want.

    * `pistrong add bill --dev iphone8 --remoteid ios.yourdomain.com`
    * `pistrong add bill --dev ipad --remoteid ios.yourdomain.com`
    * `pistrong add bill --dev surface --remoteid windows.yourdomain.com`
    * `pistrong add myportapi --linux --remoteid linux.yourdomain.com`

Once the certs for a client device or system have been created, you will install and configure the VPN on the client or device. Follow the OS-specific Cert installation instructions at [Client Certificate Installation and VPN Configuration](https://github.com/gitbls/pistrong/blob/master/CertInstall.md) to install the Cert and configure the VPN.

See [Installation Log](https://github.com/gitbls/pistrong/blob/master/log-installpistrong.txt) for a session log which is the result of installing and configuring pistrong and InstallPiStrong. Also see [makeMyCA log](https://github.com/gitbls/pistrong/blob/master/log-makeca.txt) to see the configuration of a CA and adding a couple of users.

## pistrong

Once strongSwan has been installed and configured, and the CA has been created, presumably using makeMyCA, use `pistrong` to manage users. `pistrong` provides
commands to manage the CA, add, revoke, delete, or list
users, and simple strongSwan service management (start, stop, restart,
enable, disable, status, and reload).

If you have a webserver and an email server installed locally, `pistrong` can send email to the
user with a link to the certificates, and a separate email with the
password for the certificate. See section below on Local Mail for a quick and easy way to install a local-only email on your system.

### Example commands

* `pistrong createca --vpnsankey my.special.vpnsankey` - Create a new Certificate Authority using the vpnsankey as specified. The VPN SAN key is required and provides an extra level of security for iOS device authentication. See CertDetails.md for more information on VPN SAN keys.

* `pistrong add fred --device iPhone --mail fred@domain.com --zip` - Add user *fred*, for the device named *iPhone*. Send *fred* email with an attached zip file containing the Certs. The device name is optional and may be helpful to track where a Cert is targeted. If --device is not specified, the string "*dev*" is used.

* `pistrong add fred --device iPhone --mail fred@domain.com` - Add user *fred*, for the device named *iPhone*. Copy the necessary certs to `webdir` (see Configuration below). Send *fred* email with links to the Certs using `weburl`. The device name is optional and may be helpful to track where a Cert is targeted. If --device is not specified, the string *`dev`* is used.

* `pistrong resend fred-iPhone --mail fred@otherdomain.com` - Resend the email with the links to the Certs to the specified email address. 

* `pistrong list fred --all [--full]` - List all Certs for user *fred*. Print the cert contents as well if --full specified

* `pistrong deleteca` - Delete the whole CA including all user Certs. You will be asked to confirm, since this is irreversible and will require that **all** issued Certs be replaced. **Everything will be deleted. Be really sure, especially if you have more than a couple of users.**

* `pistrong makevpncert mynewcert --vpnsankey the.other.clients` - Create a new VPN Key and Cert with a different SAN key
* `pistrong service reload` - Ask strongSwan to reload the credential database. This must be done to activate changes made into the running system

* `pistrong help` -- Display detailed online help

## InstallPiStrong 

`InstallPiStrong` installs strongSwan, and downloads the remainder of the pistrong scripts. strongSwan can be installed in two different ways:
* Using the strongSwan packages in your distro, if they are present
* Build strongSwan from a source tarball downloaded from strongswan.org

InstallPiStrong will display the version numbers of both, and ask you to choose which to install. The pros/cons of each method:

**From apt package**
* **Pros**
    * Smaller download and very quick install
    * Easy to manage and update with apt package tools
* **Cons**
    * Typically not the latest version

**From a source tarball**
* **Pros**
    * The latest and greatest released version
* **Cons**
    * Larger download and longer install (10-15 minutes on a Pi4, and about an hour on a Pi Zero)
    * Cannot be managed or updated with apt package tools
    * You **must** retain the directory /root/piStrong in order to uninstall strongSwan installed with this method.

In general, unless you have a strong need for the latest/greatest, it's better to use the apt-provided packages, simply because of the install time and package management tools. But, both are supported, and pistrong works with both of them.

**NOTE:** If the version of strongSwan in your distro is less than 5.8.0, InstallPiStrong will not allow you to use the apt install.

When building from a source tarball, `InstallPiStrong` has several phases. If no phase is specified or **all** is the default, and 
all phases will be run. InstallPiStrong does not pause at the start of each phase. If you it to pause at the start of each phase, use **allx** as the command line argument. The phases include:

* **allx** the same as **all** but pauses at the start of each phase
* **prereq** ensures that the required packages are installed on your system
* **download** downloads the latest strongSwan source tarball 
* **preconf** runs `configure` on the strongSwan source to ensure proper system configuration
* **make** compiles and builds strongSwan
* **install** installs strongSwan into the system
* **postconf** or **post-configure** creates
    * `/etc/sysctl.d/92-pistrong.conf` if configuring a VPN Server or `/etc/sysctl.d/.92-pistrong.conf` if configuring a Client. On the server, this enables IPV4 forwarding between the VPN and the LAN. The Client version is for reference only and not used since it starts with a ".".

## makeMyCA

makeMyCA builds a complete CA configured for use with iOS, Windows, and Linux clients.  
makeMyCA prompts for all the configuration information and provides explanations of each item. In addition to the necessary Certs, makeMyCA also creates

* `/etc/swanctl/conf.d/pistrong-CAServerConnection.conf` strongSwan config file for iOS, Windows, and Linux client VPN connections
* `/etc/swanctl/pistrong/CA-iptables` required iptables addition for IPV4 routing to work. See Firewall Considerations section below

## Resetting Everything

If you want to completely delete and reset the CA, you can do that relatively easily. *This will completely invalidate all user certs!*

* `sudo pistrong service stop` - Stop the strongswan service
* `sudo pistrong deleteca` - Deletes Everything
* If things are **really confused**, you can go even further and do:
    * `sudo pistrong config --list > ~/old-pistrong-config.txt` &mdash; Save the old settings for reference
    * `sudo rm -f /etc/swanctl/pistrong/pistrongdb.json` &mdash; Deletes the pistrong database, which pistrong will recreate as needed.  
* `sudo makeMyCA` - Create a new CA. Use this, or your own script, as desired.
*  Add new users or devices to the CA

## Linux Clients Connecting to Your VPN

pistrong supports Linux Client devices connecting to the VPN. The easiest approach is to use strongSwan on the Linux client, and installing it via:

* Download pistrong and InstallPiStrong onto the Linux client system as described above
* `sudo InstallPiStrong` - Download, build, and install strongSwan
    * In the *postconf* phase, InstallPiStrong will ask if the VPN server should be enabled. For a client-only system, answer No. You can change your mind and enable this in the future if desired.
* The VPN Server Manager adds Linux clients by using `sudo pistrong add clientname --remoteid linux-remoteid --linux`.

    For instance, using the default CA built by makeMyCA, one might use `sudo pistrong add tomspi --device pi4 --remoteid linux.mydomain.com --linux`.

    The `--linux` switch causes pistrong to create a Linux VPN Config Pack. Once the VPN Config Pack (zip file) has been copied to the Linux client system, install the new connection on the client with `sudo pistrong client install /path/to/zip-file`. 

* Connect to the remote strongSwan VPN server with `sudo pistrong client start servername.fqdn.com`. The remote name can be abbreviated to its uniqueness.

* Stop the VPN connection with `sudo pistrong client stop`

## Firewall Considerations

strongSwan **requires** changes to the Firewall on the VPN Server for proper operation. This is not required on the Linux VPN Client system, or any other client for that matter. In case you don't have a firewall installed, InstallPiStrong writes a new systemd service *pistrong-iptables-load*, which contains only the VPN-required Firewall rules. If you want to use this service, `sudo systemctl enable pistrong-iptables-load` before rebooting.

The minimal firewall rules are in /etc/swanctl/pistrong/CA-iptables. If your connection to the internet changes from what you specified in makeMyCA, you must sudoedit this file and change the network device (typically, eth0, but could be eth1) to the appropriate network adapter. There is no validity checking done on this by pistrong, and if it's incorrect, VPN traffic from remote clients will not be able to access the VPN Server's LAN.

Many users either have or want more than this very minimal firewall. In that case, the iptables rules in /etc/swanctl/pistrong/CA-iptables must be added to the Firewall rules for your system.

## Hints

* Use the `pistrong config` command to quickly and easily configure pistrong for your system. See [makeMyCA](https://raw.githubusercontent.com/gitbls/pistrong/master/makeMyCA), which creates a fully-functional CA to serve iOS, Windows, and Linux clients.

* Typically you'll want to include your host FQDN as one of the VPN SAN keys, unless you are using an IP address to access your VPN server. In that case, you'll need to include the IP address. For maximum flexibility, pistrong does not apply the host FQDN or IP address as SAN keys, although makeMyCA does. If you are not using makeMyCA you must put the VPN-specific SAN key first. For example, `--vpnsankey myipsec.home.vpn,myhost.mydomain.com`. pistrong will add all specified SAN keys to the VPN cert. The VPN SAN key should match the value for the --remoteid switch, as this is how strongSwan determines which VPN configuration is applied to an incoming connection. The --remoteid value is sent to the user in email.

    Note that makeMyCA adds the host FQDN to the SAN keys it creates.

* After adding/deleting/revoking users, use `pistrong service reload` to cause strongSwan to reload all credentials.

* If you need to use multiple strongSwan connections (for different users accessing different local subnets, for example), here is an outline of how to do this:
    * Establish the primary configuration with the desired CA Cert and VPN SAN keys, for instance, by using makeMyCA.

    * Create a secondary CA and a VPN Cert/Key in that secondary CA with a different VPN SAN key

    * Create a new .conf file in /etc/swanctl/conf.d with the new connection using the secondary CA, VPN SAN Key, and secondary VPN Cert. Also add a secondary IP address pool.

    * When adding users, always specify --cacert and --remoteid to specify the secondary VPN SAN Key to ensure that the user Cert is assigned to the correct connction.

    * **NOTE:** If you ever re-create the CA using deleteca/createca you'll need to recreate the secondary Cert/Key and validate the connection details the secondary .conf file in /etc/swanctl/conf.d/

* Email and web server configuration is beyond the scope of this document. There are lots of guides on the internet for this, such as https://raspberrytips.com/mail-server-raspberry-pi/, but also see the section on Sending Mail below.

* If you have issues with trying the VPN on your local network, you should consider installing a local LAN DNS server rather than depending on your router or other less deterministic naming systems.

    [ndm](https://github.com/gitbls/ndm) provides a simple DNS and DHCP server manager using the Bind9 DNS server and ISC DHCP Server, or alternatively dnsmasq. Of course, if you opt to not use ndm you can use any name server you'd prefer.

    I've found that having my local LAN domain name be the same as my external domain name (static or dynamic) makes VPN testing and usage on the LAN SO much easier, since the client device can refer to the sam VPN DNS name regardless of whether it's on the internal LAN or on the Internet.

## Security Considerations

For the most secure implementation, here are some things to consider:

* Always use an FQDN hostname (hostname.domain.com) for a registered domain. If you do not have a static IP address, use a dynamic DNS service. The FQDN hostname helps ensure that your client is connecting to a known host, and is the most reliable way to connect to your VPN from the internet. This also insulates you from your ISP randomly changing your external, dynamically-assigned IP address and invalidating your whole CA.

* If you don't have an FQDN for the VPN server, you will probably need to use `--vpnsankey my.san.key,yourExternalIPAddress` when you create the CA. `makeMyCA` does this by default.

* pistrong easily enables a one certificate for multiple user devices, or a one certificate per user device scenario. The former is easier to manage, the latter provides finer granularity access and management/monitoring control.

## Using an IP Address for VPN Access

While using a DNS name is the best way to access the VPN, that may not always be possible. pistrong makes using an Internet IP Address as painless as possible, but there are a few things to be aware of:

* If you opt to use an IP address to access the VPN, you will need to recreate all user certificates if the external IP address of the VPN Server changes.

* You won't be able to easily test your VPN Server with a client on the LAN. Here's an outline of how to do that:

    * **iOS and Windows:** Create a new VPN connection with a different name, and use the VPN Server LAN IP address for the Server address, but using the same Cert as for the Internet case.
    * **Linux:** Create a new Device Cert as follows:
        * `pistrong add username --dev somename --cname somename --vpnaddr VPNServerLANAddr`
            
            * `--dev somename` &mdash; A slightly different name for the same device. For instance, if you created the Internet connection using `--dev pi3`, you might decide to use `--dev pi3LAN`. The name can be whatever you want, but it must be different from the Internet connection.
            * `--cname some-name` &mdash; Specifies the name you'll use to reference the connection on a `pistrong client start` command. This has nothing to do with DNS CNAMEs.
            * `--vpnaddr VPNSERVER-LANAddr` &mdash; Specifies the LAN IP address for the VPN Server. This only affects the address that is in the Client connection config file.

## Tunnels

A simple way to enable LAN clients to utilize the tunnel is to add a route to the remote server's IP address(es) to the router. It does cause outgoing traffic to hit the router twice, which may be a consideration on a heavily-utilized tunnel. It's easy to add routes to Linux clients, which can be used to ameliorate the router impact.

## Sending Mail

If you want to send email to a user with their cert information, there are two approaches. You can either send it using your gmail or Outlook.com (or other Internet or ISP) email account, or you can set up your own local mail server.

### Sending using gmail or Outlook.com

To send with **gmail**, perform these configuration steps:

* Configure an app password for pistrong to use. Follow the directions in the section *Google Account Setup* at [automate sending emails with gmail in python](https://towardsdatascience.com/automate-sending-emails-with-gmail-in-python-449cc0c3c317) to configure your gmail account and establish an app password. Save the app password in a secure location.

* Then configure pistrong to use gmail:
    * `sudo pistrong config --smtpserver smtp.gmail.com --smtpport 587 --smtpusetls y`
    * `sudo pistrong config --smtpuser yourgmail@gmail.com --smtppassword yourapppassword`
    * `sudo pistrong config --mailfrom yourgmail@gmail.com`

To send with **Outlook.com**, perform these configuration steps:

* Configure an app password for pistrong to use. Go to [https://account.microsoft.com/security](URL), Select *Advanced Security options*, and then scroll down and select *Create a new app password*. The next screen will display the created app password. Save the app password in a secure location.

* Then configure pistrong to use outlook.com (or equivalently, live.com):
    * `sudo pistrong config --smtpserver smtp-mail.outlook.com --smtpport 587 --smtpusetls y`
    * `sudo pistrong config --smtpuser youremail@outlook.com --smtppassword yourapppassword`
    * `sudo pistrong config --mailfrom youremail@outlook.com`

Note that `--mailfrom` can be specified as just an email address as above, or you can include a *pretty name* such as: `--mailfrom "MyVPNServer<<myemail@gmail.com>>". This works for both Outlook.com and gmail.

### Sending using local mail server

If you'd prefer to use your own mail server, you can configure pistrong to use that. If your system does not have the capability to send email, and you want it to, you can easily install a local-only email system. Here are the steps:

* Install postfix -- `sudo apt-get install bsd-mailx postfix libsasl2-modules` You don't really need bsd-mailx but it may be useful to have a local bash shell mail command for testing.

* Install dovecot -- If you want to access email on the system using an IMAP email client. See the script [install-dovecot](https://raw.githubusercontent.com/gitbls/pistrong/master/install-dovecot). This will install and configure dovecot for local, non-ssl usage, which should be fine for installing pistrong-created certs to your Windows or iOS device.

* If you don't use the `--zip` switch, you'll also need to have a webserver installed, so that users can pick up the zip file from your web server. If you `sudo apt-get install apache2` before running makeMyCA everything will be set up correctly. You may need to restart the apache2 service after running makeMyCA. If you install apache2 after running makeMyCA, you may need to execute this command: `echo "ServerName vpnserver.fqdn" > /etc/apache2/conf-enabled/servername.conf`, of course, replacing vpnserver.fqdn with the fully-qualified domain name for your VPN Server.

## Starting a Site-To-Site Tunnel Automatically

It's easy to keep a site-to-site tunnel up and running using vpnmon (available on this github). Download vpnmon.service and vpnmon.sh to your system and then:

* `sudo cp vpnmon.service /etc/systemd/system/vpnmon@.service`
* `sudo cp vpnmon.sh /usr/local/bin/vpnmon`
* `sudo pistrong client list` to get the name of the tunnel (e.g., otherhost-Tunnel)
* sudo enable vpnmon@*otherhost*

Generally, for any pair of tunnel endpoints, decide which will be the client (the one that initiates the VPN tunnel connection) and install vpnmon on that endpoint.

## Not Yet Completed

  * Android and MacOS testing - Certificate install testing and documentation for these devices.

  * In-depth crypto performance/security tradeoff evaluation.

  * Install on other distros - Additional popular distros should be added to InstallPiStrong

  * More usage. Besides me, that is. 

  * pistrong does not provide a way to delete a single CA or VPN Cert.

  * pistrong does not encrypt Certs in a Linux Cert Pack

## If you're interested...

Please refer to the issues list if you have ideas for improving pistrong or have found a problem. I would be very happy to hear from you. There's always the possibility of a bug that I missed ;), or a great feature that should be added.

Or, if you're so inclined, do it yourself and leave a pull request.

Testing and documenting cert installation steps for Android and MacOS is another area where I would really appreciate your help.

## Troubleshooting

If you're having problems and can't sort them out, please download and run the script `pscollect` and provide the output from it when you open an issue on this github. `pseollect` gathers up all the relevant information to help jump-start the process.
