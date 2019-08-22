# pistrong
Simplified CA and device cert manager for the strongSwan VPN

## Overview

`pistrong` dramatically simplifies installing and configuring the strongSwan VPN. Once installed, use pistrong to easily manage the strongSwan Certificate Authority (CA) and Certificates for remote user devices connecting to the VPN. pistrong fully supports the roadwarrior use case (users on devices), and can be used to create and manage certs for other uses, such as host-to-host tunnels.

pistrong includes complete installation, configuration, and management support for Raspbian/Debian distros. There is partial install/config support for openSuSE, Ubuntu, Debian, and Centos. pistrong is distro-independent, so can be used on any distro once strongSwan is properly installed and configured.

pistrong consists of a couple of components:

* `pistrong` - Provides day-to-day CA and user Key/Cert management

* `InstallPiStrong` - Installs and configures strongSwan

* `makeMyCA` - Script to create your custom CA after completing the installation

The easiest way to install pistrong is to use the bash command:

    sudo curl -L https://raw.githubusercontent.com/gitbls/pistrong/master/EZPiStrongInstaller | bash

This will download pistrong and InstallPiStrong to /usr/local/bin, and then start `InstallPiStrong all` to fully install and configure strongSwan. See the InstallPiStrong section below for distro-specific details.

If you'd prefer to not feed an unknown script directly into bash, you can issue the following commands on your local system:

    sudo curl -L https://raw.githubusercontent.com/gitbls/pistrong/master/pistrong -o /usr/local/bin/pistrong
    sudo curl -L https://raw.githubusercontent.com/gitbls/pistrong/master/InstallPiStrong -o /usr/local/bin/InstallPiStrong
    sudo curl -L https://raw.githubusercontent.com/gitbls/pistrong/master/makeMyCA -o /usr/local/bin/makeMyCA           
    sudo chmod 755 /usr/local/bin/{pistrong,InstallPiStrong,makeMyCA}
    sudo /usr/local/bin/InstallPiStrong all

## pistrong

Once strongSwan has been installed and configured, use `pistrong` to create the CA and manage users. `pistrong` provides
commands to create (or delete) the CA, add, revoke, delete, or list
users, and simple strongSwan service management (start, stop, restart,
enable, disable, status).

If you have a webserver and an email server installed, `pistrong` can send email to the
user with a link to the certificates, and a separate email with the
password for the certificate. 

### Example commands

* `pistrong createca --vpnsankey my.special.vpnsankey` -- Create a new Certificate Authority using the vpnsankey as specified. The VPN SAN key is required and provides an extra level of security for iOS device authentication. See CertDetails.md for more information on VPN SAN keys.

* `pistrong add fred --device iPhone --mail fred@domain.com` -- Add user *fred*, for the device named *iPhone*. Copy the necessary certs to `webdir` (see Configuration below). Send *fred* email with links to the Certs using `weburl`. The device name is optional and may be helpful to track where a Cert is targeted. If --device is not specified, the string *`dev`* is used.

* `pistrong resend fred-iPhone --mail fred@otherdomain.com` -- Resend the email with the links to the Certs to the specified email address. 

* `pistrong list fred --all [--full]` -- List all Certs for user *fred*. Print the cert contents also if --full specified

* `pistrong deleteca` -- Delete the whole CA including all user Certs. You will be asked to confirm, since this is irreversible and will require that **all** issued Certs be replaced. **Everything** will be deleted. Be really sure, especially if you have more than a couple of users.

* `pistrong makevpncert mynewcert --vpnsankey the.other.clients` -- Create a new VPN Key and Cert with a different SAN key
* `pistrong service reload` -- Ask strongSwan to reload the credential database. This must be done to activate changes made into the running system
    
* `pistrong help` -- Print detailed online help

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
    * `/etc/swanctl/swanctl.conf` strongSwan config file for iOS and Windows roadwarrior use
    * `/etc/swanctl/pistrongdb.json` pistrong CA database
    * `/etc/swanctl/iptables.pistrong` required iptables addition. See Firewall section below
    * Copies (in /etc/swanctl) of the just-created files swanctl.piStrongInstall and pistrongdb.piStrongInstall.

    Use `InstallPiStrong postconf` if you install strongSwan with some other mechanism and want to use pistrong to manage your CA and user/device Certs.

## Firewall Considerations

strongSwan requires changes to the Firewall. If you don't have a firewall installed, InstallPiStrong writes a new systemd service pistrong-iptables-load, which will install only the VPN-required Firewall rules. If you want to use this service, `sudo systemctl enable pistrong-iptables-load` before rebooting. Most users either have or want more than this minimal firewall. In that case, the iptables rules in /etc/swanctl/iptables.pistrong must be added to the inuse Firewall.

## Hints

* Use the `pistrong config` command to quickly and easily configure pistrong for your system. See [makeMyCA](https://raw.githubusercontent.com/gitbls/pistrong/master/makeMyCA) for an example you can edit and use.
* Typically you'll want to include your host FQDN as one of the VPN SAN keys, unless you are using an IP address to access your VPN server, in which case, you'll need to include the IP address. pistrong does not apply the host FQDN or IP address as SAN keys. Be sure to put your VPN-specific SAN key first. For example, `--vpnsankey myipsec.home.vpn,myhost.mydomain.com`. pistrong will add both SAN keys to the VPN cert, but only sends the first SAN key to the user in email.
* After adding/deleting/revoking users, use `pistrong service reload` to cause strongSwan to reload all the credentials.

* If you need to use multiple strongSwan connections (for different users accessing different local subnets, for example), here is an outline of how to do this:
    * Establish the primary configuration with the desired CA Cert and VPN SAN keys.
    * Create a secondary CA and a VPN Cert/Key in that secondary CA with a different VPN SAN key
    * Manually edit /etc/swanctl/swanctl.conf and add the new connection using the secondary CA, VPN SAN Key, and secondary VPN Cert. Also add the secondary IP address pool.
    * When adding users, always specify --cacert and --remoteid to specify the secondary VPN SAN Key to ensure that the user Cert is assigned to the correct connction.
    * NOTE: If you ever re-create the CA using deleteca/createca you'll need to recreate the secondary Cert/Key and validate the connection in /etc/swanctl/swanctl.conf, so don't unless you're really sure!

* Email server configuration is beyond the scope of this
document. There are lots of guides on the internet for this.

## Security considerations

For the most secure implementation, here are some things to consider:

* Always use an FQDN hostname (hostname.domain.com) for a registered domain. If you do not have a static IP address, use a dynamic DNS service. The FQDN hostname helps ensure that your client is connecting to a known host, and is the most reliable way to connect to your VPN from the internet. This also insulates you from your ISP randomly changing your external, dynamically-assigned IP address.

* If you don't have an FQDN for the VPN server, you will probably need to use `--vpnsankey my.san.key,yourExternalIPAddress` when you create the CA

* pistrong easily enables a one certificate for multiple devices, or a one certificate per device scenario. The former is a wee bit easier, the latter provides finer granularity access control.

## Not Yet Completed

  * Android and MacOS testing - Certificate install testing and documentation for these devices.

  * Install on other distros - Additional popular distros should be added to InstallPiStrong

  * More usage. Besides me, that is. 

  * Improved username/keyname validation. Checks are very minimal now, and effects of strange characters are unknown, but do not pose any known security risk.

  * pistrong does not provide a way to delete a single CA or VPN Cert.

  * There is no upgrade from pistrong v1 to v3. If you need help with this, open an issue on github.

## If you're interested...

Please refer to the issues list if you have ideas for improving this tool or have found a problem, and if nobody else has mentioned it, I would be very happy to hear from you. There's always the possibility of a bug that I missed ;), or a great feature that should be added.

Or, if you're so inclined, do it yourself and leave a pull request.

Testing and documenting cert installation steps for Android and MacOS is another area where I would really appreciate your help.
