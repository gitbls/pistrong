# Changelog

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


