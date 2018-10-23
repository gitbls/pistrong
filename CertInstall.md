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
* **Powershell (Admin)** - Split Tunneling
    * Open a Powershell (Admin) window
    * Use `Get-VpnConnection` to list your VPNs and check the current state of Split Tunneling
    * Use `Set-VpnConnection -SplitTunneling 0 to turn it off (all traffic flows over the VPN), or 1 to turn it on (only traffic destined for the VPN router or it's local network  flows over the VPN)

### Windows Connect Problems Hints and Tips

If you've set everything up correctly, it should, of course, *just work*. But, since there are a lot of moving parts involved, it may not. Here are some tips to consider as you create your CA and configure users.

* The server name or address in the Windows VPN connection properties must be included as a SAN value in the host VPN Cert. If the server name specified in the VPN Server name or address field is not found in the SAN values in a VPN Host Certificate, Windows will fail the connection. 

    In other words, the connection will fail if Windows tries to connect to 'host.domain.com' and the host system VPN Cert only has a SAN with 'host', or vice versa. Similarly, if you are connecting from the Internet and are trying to use an IP address, if the VPN Cert does not have the IP address as a SAN the connection will fail.

    Proper use of dynamic DNS makes all this very simple. It can also be addressed by using --altsankey when creating the CA or VPN Cert. If you only have an IP address and no DNS name, include the external address as a SAN when you ceate the CA or additional VPN Cert, but this is not recommended, especially for dynamically assigned IP addresses.

* After installing the certificate, they can be viewed in the certificate manager. After installing the certificates, use the following steps to look at the device certificates:

    * Windows-R mmc.exe
    * File | Add/Remove Snap-in... (or CTRL-M)
    * Select *Certificates *and click Add
    * Select *Computer account *and click Finish
    * Click OK
    * User/device certificates can be found in the Personal Certificates store
    * The strongSwan root certificate will be found in the Trusted Root Certification Authorities


## MacOS

TBD

## Android

TBD
