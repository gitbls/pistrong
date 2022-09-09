# Changelog

## V3.14

* Enable host-to-host VPNs where both the LANs have the same subnet, as long as the VPN hosts have different IP addresses
* Correct uncaught error in socket.gethostbyname that only occurs under abnormal configuration
* Prevent Client VPN installers from over-writing existing Cert and config files

## V3.13

* macOS tested, verified, and documented!
* Fix broken 'resend' command

## V3.12

* Add Android client support
* MacOS should work, but alas! I have no way test it 
* Restructure and improve /etc/swanctl/conf.d/pistrong-CAServerConnection.conf
* Enable vpnmon to monitor a specific, per-monitored-VPN IP address
* Improve pistrong error handling
* pistrong code cleanups
* Python 3.7 or later now required

## V3.11

* Make 'client stop' a wee bit quieter
* In addition to ike, also set enc and net logging to 0 in /etc/strongswan.d/charon-systemd.conf
* makeTunnel improvements
  * Ask about and configure dead peer detection
  * Ease of use improvements
  * General code cleanup

## V3.10

* makeMyCA improvements

## V3.9

* Add pscollect to gather up problem-solving info
* Check for valid email settings before sending mail
* Improve validation of provided network configuration in makeMyCA and makeTunnel
* makeMyCA and makeTunnel now check for and require sudo

## V3.8

* Correct typo in client start error path
* Resync version number

## V3.7

* Skipped
	
## V3.6

* Prevent VPN connect timeout from killing pistrong

## V3.5

* Sending email with smtp and TLS now works. Tested with both gmail and outlook.com. See the README for configuration information.
  * --smtpusetls now requires an argument: y or n to enable or disable using TLS when connecting to the smtp server.
* Installation process has been simplified to: *download and run InstallPiStrong*. InstallPiStrong will download the other pistrong scripts, and install all prerequisites and strongSwan itself.
  *  InstallPiStrong now enables installing either the apt version or the "web" (download tar file and build) version. Debian Buster (and later) and variants have a version of strongSwan that can be installed and used with an apt install, rather than building from source.
  * The installer will enable you to switch from a "web" install on a system to an apt install, as long as the directory /root/piStrong from the "web" install is intact
  * Likewise, you can switch from an apt install to a "web" install if you need a later version for a certain feature or bug fix
  * In either case, your existing CA and user/device certs and keys are preserved
  * The installer enforces a minimum strongSwan version in apt of 5.8.0. This can be overridden by: `declare -x PSAPTOK foo` (any other non-null value). This should be OK for Linux-to-Linux VPNs but I found that iOS could not connect to 5.7.2, and there may be other incompatibilities with older versions. YMMV.
* Currently, InstallPiStrong only supports systems with apt packaging including Debian Buster, RasPiOS Buster, Debian Bullseye (beta), Ubuntu. It is NOT (yet) tested on any other distros and is unlikely to work. Support for other distros will be added based on inquiries.
* As with the *pistrong add* command, the *pistrong resend* command can now send an attached zip file if --zip specified
* makeMyCA now checks whether a CA already exists
* Simplify argparse defaults handling
* Simplify config command argument handling
* Code cleanups for utf-8


