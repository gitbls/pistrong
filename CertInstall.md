# Client Certificate Installation and VPN Configuration

A client device must have the correct certificates installed in order to use the VPN. The details for installing certificate(s) and configuring the VPN vary by operating system. Here are step-by-step instructions for tested client operating systems.

## Android

I'm not an Android user, and I'm sure there are better/alternate ways to install Certs on Android. This is how I did it.

* I put the .p12 Cert on a web server and browsed to that URL with the browser. The browser noticed that it was a Cert and asked if I wanted to install it. Simple, except for needing to type in the Cert password
* Another approach is to get the Cert onto the Android system somehow and then use *Install certificates from storage* in the *Settings* app to install them
* Once the Cert is installed, download and install the strongSwan VPN Client from the Play Store
* Start the VPN Client and add a new VPN Profile:
   * **Server identity:** the server name (Fully-qualified domain name or IP address) provided in the mail from `pistrong`
   * **VPN Type:** IKEv2 Certificate
   * **User Certificate:** choose the certificate matching the Local ID for the Cert
   * **Profile name:** Your own descriptive name for the VPN
   * **Server identity:** The Remote ID provided in the mail (This is the VPN SAN key)
   * **Client identity:** the Local ID given to you in the mail (this is also the certificate/profile name, e.g., *user@dev-vpnhost@myvpn.net*)
   * **User Authentication:** Tap and change to **Certificate**
   * Tap **Save**

Start the VPN by tapping on the new VPN connection in the strongSwan VPN Client

## iOS Cert Installation

Here are two different methods to install the Certs on an iOS device, depending on how the Certs are sent. Other methods can be used, such as the Apple Configurator, but they are out of scope for pistrong and this document.

### Install from zip file sent in email

The very easiest way is to use the iOS Files app with any cloud storage that you can connect to it, such as iCloud Drive, OneDrive, or Dropbox. Because there are so many different storage possibilities, you're pretty much on your own to sort this out. If you do, I'll be happy to incorporate your notes/feedback into this procedure.

With pistrong, use the `--zip` switch on the add command, along with the `--mail` switch, to have pistrong send the zip file in an email message.

* In iOS mail, open the message with the zip file, and long press on the zip file, and then tap *Share*. In the menu that comes up click on *Save to Files*. In the Files application, you can select your cloud storage location (iCloud Drive, OneDrive, Dropbox, etc) and then tap *Save*.

* Now open the Files app and navigate to the zip file that you just saved. Long press on the zip file and tap *Uncompress*. Files will create a folder which matches the filename of the zip file (minus the ".zip" file type).

* Tap on that folder to open it. Tap the CA Cert (file with the string **CACert** in the name). iOS will download the Cert (Profile). 

* Close the "Profile Downloaded" message and go to iOS **Settings** | General | Profiles

* The newly-downloaded Cert (Profile) will be found under the heading "Downloaded Profile". Tap on it, and on the next screen tap *Install*. You'll need to enter your iOS device passcode to install the Cert. Tap *Install* 2 more times, and the Cert will be installed. Tap *Done*.

* Return to mail and go to the message with the Cert Password. iOS requires a password on the Device Cert, so select and copy the password.

* Go back to the Files app, and tap on the Device Cert. 

* Close the "Profile Downloaded" message and go to **Settings** | General | Profiles

* The newly-downloaded Cert (Profile) will be found under the heading "Downloaded Profile" and may say "Identity Certificate". Tap on it, and on the next screen tap *Install*. You'll need to enter your iOS device passcode to install the Cert. Tap *Install* 2 more times. 

* Paste the Cert Password (that we copied previously) and tap *Next*. The Device Cert is now installed. Tap *Done*.

Continue with the iOS VPN Configuration below.

### Install from email containing links to Certs

* On the iPhone, open the email message with the Cert password (if there is one) and select and copy the password

* Open the message with the links to the Certs, and click on the Root CA Cert link. iOS will tell you that the Cert has been downloaded.

* Go to the Settings App | General | Profiles. The newly-downloaded CA Cert will appear there.

* Install the CA Cert

* Return to the email message and click on the device Cert link. Again, the Cert will be downloaded to the phone.

* Go back to the Settings App | General | Profiles. The newly-downloaded Identity (device) Cert will appear there.

* Install the Identity Cert. You'll be prompted for the Cert Password as a late step in the Cert installation. If you copied the password as suggested above, simply paste it in and tap *Next*.

### iOS VPN Configuration
After the certificates have been added, configure the VPN. 

* Open the **Settings** app
* Tap *VPN* settings
* Tap *Add VPN Configuration...*
   * **Type:** IKEv2
   * **Description:** Your own descriptive name for the VPN
   * **Server:** the server name (Fully-qualified domain name or IP address) provided in the mail from `pistrong`.
   * **Remote ID:** The remote ID provided in the mail (This is the VPN SAN key)
   * **Local ID:** the local ID given to you in the mail (this is also the certificate/profile name)
   * **User Authentication:** Tap and change to **Certificate**
   * **Certificate:** choose the certificate matching the Local ID you entered above
   * Tap *Done*

You can now connect to the VPN from your iOS device.

### iOS Connect Problems Hints and Tips

If you have a problem connecting to the VPN from iOS, make sure you have the correct certificates installed and carefully check all the VPN settings.

## Linux Cert Installation

Certs for Linux systems are created using pistrong with `sudo pistrong add username --linux` (plus other switches as required). The certs are stored in a Linux Client Cert Pack at /etc/swanctl/pistrong/server-assets/username-devicename.zip.

Copy the Cert Pack to your Linux client system in a convenient directory, then issue the command: `sudo pistrong client install username-devicename.zip`

pistrong will display the pistrong-vpn-installer script from the zip file. Once you approve, pistrong will add the certs and connection information to the strongSwan configuration. Restart the strongSwan server, and then connect using `sudo pistrong client connect server.fqdn.com`. 

Use `sudo pistrong client stop` to disconnect the VPN connection.

## MacOS

I don't have a Mac for testing to document this. Can you help?

## Windows 10 Cert Installation

* Install the certificate
    * Make the .p12 file available to the user, via mail, file share, etc.
    * Double-click the .p12 file from Windows File Explorer to open the Certificate Import Wizard
    * Select *Local machine* and click *Next*
    * Give permission for the app to make changes to your device
    * Check the file path for the .p12 file and click *Next*
    * Enter the password that was provided to you for the .p12 file. The default import options are fine (only "Include all extended properties" is selected).
    * Choose "Automatically select the certificate store..." and click *Next*. The user/device certificate will be stored in the Personal Certificates store, and the CA certificate contained in the .p12 will be stored in Trusted Root Certification Authorities store.
    * Click *Finish*
* Create the VPN connection
    * In the **Settings** app, go to *Network & Internet* then click *VPN*
      * Click "Add a VPN connection"
      * **VPN provider:** Windows (built-in)
      * **Connection name:** Descriptive name for the VPN
      * **Server name or address:** the fully-qualified DNS name (or IP address) of your VPN server
      * **VPN type:** IKEv2
      * **Type of sign-in info:** Certificate
      * **User name and Password:** leave blank
      * Click *Save*
* Set Require encryption on the VPN
    * In the **Settings** app, go to *Network & Internet* then click *Change Adapter Options*
      * Right click on the newly-created VPN and then click *Properties*
      * On the **Security** tab
        * **Data encryption:** Require encryption
        * Ensure *Use machine certificates* is selected
      *  Click *OK* or *Done* all the way out, and you can then close the Adapter Connections window and the Settings app.

You can now connect to the VPN from your Windows 10 device.

If you want to route all of your internet traffic over the VPN, as opposed to only traffic destined for your VPN server network, you need to enable *Use default gateway on remote network*, or disable Split Tunneling. There are two ways to do this.

* **Network and Sharing Center** GUI  &mdash; *Use Default Gateway*
    * Open the **Settings** app, select *Network & Internet*, and click *Change adapter options*
      * Right-click on your VPN and select *Properties*
      * Select the *Networking* tab
      * Select *Internet Protocol Version 4 (TCP/IPv4)*, then select the *Properties* Tab and click *Advanced…*
      * Select/check *Use default gateway on remote network*
      * *OK* out of all screens
* **Powershell (Admin)** &mdash; Split Tunneling
    * Open a Powershell (Admin) window
    * Use *Get-VpnConnection* to list your VPNs and check the current state of Split Tunneling
    * Use *Set-VpnConnection -SplitTunneling 0* to turn it off (all traffic flows over the VPN), or 1 to turn it on (only traffic destined for the VPN router or it's local network flows over the VPN)

### Windows Connect Problems Hints and Tips

If you've set everything up correctly, it should, of course, *just work*. But, since there are a lot of moving parts involved, it may not. Here are some tips to consider as you create your CA and configure users.

* The server name or address in the Windows VPN connection properties must be included as a SAN value in the host VPN Cert. If the server name specified in the VPN Server name or address field is not found in the SAN values in a VPN Host Certificate, Windows will fail the connection. 

    In other words, the connection will fail if Windows tries to connect to 'host.domain.com' and the host system VPN Cert only has a SAN with 'host', or vice versa. Similarly, if you are connecting from the Internet and are trying to use an IP address, if the VPN Cert does not have the IP address as a SAN the connection will fail.

    Proper use of dynamic DNS makes all this very simple. If you only have an IP address and no DNS name, include the external address as a SAN when you ceate the CA or additional VPN Cert, but this is not optimal, especially for dynamically assigned IP addresses. `makeMyCA` will help you set this up correctly.

* After installing the certificate, they can be viewed in the certificate manager. After installing the certificates, use the following steps to look at the device certificates:

    * Windows-R mmc.exe
    * File | Add/Remove Snap-in... (or CTRL-M)
    * Select *Certificates *and click Add
    * Select *Computer account *and click Finish
    * Click OK
    * User/device certificates can be found in the Personal Certificates store
    * The strongSwan root certificate will be found in the Trusted Root Certification Authorities

