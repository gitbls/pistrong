# Client Certificate Installation and VPN Configuration

A client device must have the correct certificates installed in order to use the VPN. The details for installing certificate(s) and configuring the VPN vary by operating system. Here are step-by-step instructions for tested client operating systems.

## iOS 10
One method is to put the certificates on a web server and browse to them. `pistrong` can send email with URLs for the certificates. Browse to each file and follow the prompts to add both the .p12 file and the CA certificate. They can be installed in any order. Alternatively, you can use the Apple Configurator app to load certificates.

After the certificates have been added, configure the VPN. 

* Open the Settings app
* Open the VPN settings
* Tap "Add VPN Configuration"
   * **Type:** IKEv2
   * **Description:** Descriptive name for the VPN
   * **Server:** the fully-qualified domain name provided in the mail from `pistrong`. Use the server (external) IP address if you don't have a DNS name for the server.
   * **Remote ID:** The remote ID provided in the mail (This is the VPN san key)
   * **Local ID:** the local ID given to you in the mail (this is also the certificate/profile name)
   * **User Authentication:** Certificate
   * **Certificate:** choose the certificate matching the Local ID you entered above
   * Done

You can now connect to the VPN from your iOS device.

### iOS Connect Problems Hints and Tips

If you have a problem connecting to the VPN from iOS, make sure you have the correct certificates installed and carefully check all the VPN settings.

## Windows 10

* Install the certificate
    * Make the .p12 file available to the user, via mail, file share, etc.
    * Double-click the .p12 file from Windows File Explorer to open the Certificate Import Wizard
    * Select "Local machine" and click Next
    * Give permission for the app to make changes to your device
    * Check the file path for the .p12 file and click Next
    * Enter the password that was provided to you for the .p12 file. The default import options are fine (only "Include all extended properties" is selected).
    * Choose "Automatically select the certificate store..." and click Next. The user/device certificate will be stored in the Personal Certificates store, and the CA certificate contained in the .p12 will be stored in Trusted Root Certification Authorities store.
    * Click Finish
* Create the VPN connection
    * In the Settings app, go to "Network & Internet" then click "VPN"
      * Click "Add a VPN connection"
      * **VPN provider:** Windows (built-in)
      * **Connection name:** Descriptive name for the VPN
      * **Server name or address:** the fully-qualified domain name (or IP) of your VPN server
      * **VPN type:** IKEv2
      * **Type of sign-in info:** Certificate
      * **User name and Password:** leave blank
      * Click Save
* Require encryption on the VPN
    * In the Settings app, go to "Network & Internet" then click "Change Adapter Options"
      * Right click on the newly-created VPN and then click Properties
      * On the Security tab
        * **Data encryption:** Require encryption
        * Ensure "Use machine certificates" is selected
      *  Click OK or Done all the way out, and you can then close the Adapter Connections window and the Settings app.

You can now connect to the VPN from your Windows 10 device.

If you want to route all of your internet traffic over the VPN, as opposed to only traffic destined for your VPN server network, you need to enable "Use default gateway on remote network", or disable Split Tunneling. There are two ways to do this.

* **Network and Sharing Center GUI**  - "Use Default Gateway"
    * Open the Settings app, select Network & Internet, and click "Change adapter options” 
      * Right-click on your VPN and select Properties
      * Select the Networking tab
      * Select "Internet Protocol Version 4 (TCP/IPv4)", then select the Properties Tab and click Advanced…
      * Select/check "Use default gateway on remote network"
      * OK out of all screens
* **Powershell (Admin)** - Split Tunnelingx
    * Open a Powershell (Admin) window
    * Use `Get-VpnConnection` to list your VPNs and check the current state of Split Tunneling
    * Use `Set-VpnConnection -SplitTunneling 0 to turn it off (all traffic flows over the VPN), or 0 to turn it on (only traffic destined for the VPN router or it's local network  flows over the VPN)

### Windows Connect Problems Hints and Tips

If you've set everything up correctly, it should, of course, "just work". But there are a few gotchas. Here are the ones that I discovered.

* The server name or address in the Windows VPN connection properties must be the same as the fully qualified name (FQDN) of the server. On Raspbian, this can be found in /etc/hostname. Other distros may use /etc/HOSTNAME, or something else altogether. It appears that the hostname specified in the VPN connection properties is checked against the altNames (SAN values) in the VPN Host Certificate, and there must be a match or Windows will fail the connection. 

  In other words, the connection will fail if Windows tries to connect to 'host.domain.com' and the host system is configured internally with a host name of 'host'. Proper use of dynamic DNS makes this simple. It is possible to make the VPN work using an IP address rather than an FQDN, but this is not recommended.

* After you install the certificate, you can see them in the certificate manager. After you've installed the certificates, you can Windows-R (run) certmgr.msc and you'll find the strongSwan root certificate in the Trusted Root Certification Authorities. To see the user/device certificate, use the following steps to look at the device certificates.
    * Windows-R mmc.exe
    * File | Add/Remove Snap-in... (or CTRL-M)
    * Select Certificates and click Add
    * Select Computer account and click Finish
    * Click OK
    * User/device certificates can be found in the Personal Certificates store


## MacOS

TBD

## Android

TBD
