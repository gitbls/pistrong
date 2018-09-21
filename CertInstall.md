# Installing Certificates

## iOS 10
You can use the Apple Configurator app to load certificates. Another way is to put them on a web server and browse to
them. pistrong can send email  with URLs for the certificates if desired. Browse to each file and follow the prompts to add them
both. After the certificates have been added, configure the VPN.
* Open the Settings app
* Open the VPN settings
* Tap "Add VPN Configuration"
   * Type: IKEv2
   * Description: Descriptive name for the VPN
   * Server: the fully-qualified domain name provided in the mail from `pistrong`
   * Remote ID: The remote ID provided in the mail (This is the VPN san key)
   * Local ID: the local ID given to you in the mail (this is user-device-servername@ipsec.vpn)
   * User Authentication: Certificate
   * Certificate: choose the certificate matching the Local ID you entered above
   * Done

* You can now connect to the VPN from your iOS device.

## Windows 10

* Install the certificate
    * Make the .p12 file available to the user, via mail, file share, etc.
    * Double-click the .p12 file to open the Certificate Import Wizard
    * Select "Local machine" and click Next
    * Check the file path for the .p12 file and click Next
    * Enter the password that was provided to you for the .p12 file. The default import options are fine (only "Include all extended
properties" is selected).
    * Choose "Automatically select the certificate store..." and click Next. The user/device certificate will be stored in the
Personal Certificates store, and the CA certificate will be stored in Trusted Root Certification Authorities store
    * Click Finish
* Create the VPN connection
    * Open the "Change virtual private networks (VPN)" control panel
      * Click "Add a VPN connection"
      * VPN provider: Windows (built-in)
      * Connection name: Enter a name of your choice
      * Server name or address: the fully-qualified domain name (or IP) of your VPN server
      * VPN type: IKEv2
      * Type of sign-in info: Certificate
      * User name and Password can stay blank
      * Click Save
* Require encryption on the VPN
    * Go to the Control Panel | Network and Sharing Center
      * Click on Change Adapter Settings
      * Right click on the newly-created VPN | Properties
      * On the Security tab
        * Data encryption: Require encryption
        * Use Machine certificates
      *  Click OK or Done all the way out

* You can now connect to the VPN from your Windows 10 device.

If you want to route your entire internet connection over the VPN, enable Use default gateway on remote network. There are two ways
to do this.
* Via Network and Sharing Center GUI 
    * Open the Settings app, select Network & Internet, and then “Network and Sharing Center”, OR Open Control Panel | Network and Sharing Center
      * Select "Change adapter settings” on the LH side
      * Right-click on your VPN and select Properties
      * Select the Networking tab
      * Select "Internet Protocol Version 4 (TCP/IPv4)", then Properties / Advanced…
      * Select/check "Use default gateway on remote network"
      * OK out of all screens
    * Via Powershell (Admin)
      * Use Get-VpnConnection to list your VPNs and check the current state of Split Tunneling
      * Use Set-VpnConnection -SplitTunneling 1 to turn it on (all traffic flows over the VPN), or 0  to turn it off
