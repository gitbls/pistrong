# Installing Certificates

## iOS 10
You can use the Apple Configurator app to load certificates. Another way is to put them on a web server and browse to
them. piswanctl can send email  with URLs for the certificates if desired. Browse to each file and follow the prompts to add them.
* Open the Settings app
* Open the VPN settings
* Tap "Add VPN Configuration…"

      * Type: IKEv2
      * Description: Anything here
      * Server: the fully-qualified domain name provided in the mail from piswanctl
      * Remote ID: The remote ID provided in the mail from piswanctl
      * Local ID: the local ID given to you in the mail from piswanctl
      * User Authentication: Certificate
      * Certificate: choose the certificate matching the Local ID you entered above.
      * Done

* You can now connect to the VPN from your iOS device.
