# pistrong Certificate Authority Deep Dive

pistrong is designed to be easy-to-use with no need to for the administrator to know about Certificate Authority (CA) Certs/Keys and VPN Certs/Keys. However, in more complex configurations, learning more about this is probably unavoidable. The goal of this document is to make that easier.

If you want to get started quickly, download and use the makeMyCA script after strongSwan is installed. makeMyCA builds a very prescriptive CA for Android, iOS/MacOS, Linux and Windows users.

* `sudo curl -L https://raw.githubusercontent.com/gitbls/pistrong/master/makeMyCA -o /usr/local/bin/makeMyCA`
* `sudo chmod 755 /usr/local/bin/makeMyCA`
* `sudo makeMyCA`

## CA overview
The strongSwan CA is maintained in /etc/swanctl, which is the structure used by the strongSwan service. The CA is maintained on behalf of strongSwan in several subdirectories:

* **x509** - Public Certs
* **x509ca** - CA Certs
* **private** - Private keys for Certs
* **p12** - User/device Certs
* **x509crl** - Revoked Cert list

`pistrong createca` with no CA name specified creates a CA named *strongSwan*. If additional CAs are created, you must explicitly specify the CA name. CA Cert filenames are of the form *caname*CACert. For example, the Cert name for the default CA is **strongSwanCACert**.

If you are using multiple CAs, you **must** use `--cacert` on the *add*, *showca*, and *makevpncert* commands to ensure that your updates are using the correct CA Cert.

## VPN Cert

The VPN Cert is used by the client to help validate that it's connecting with the server that it thinks it is. VPN Cert names are of the form *vpncertname-cacertname*VPNCert. By default, when the default CA is created, a VPN Cert named **default-strongSwanVPNCert** is created.

Additional VPN Certs can be created. You must explicitly specify the VPN Cert name. Use `--cacert` to specify the CA name when creating a VPN Cert for other than the default CA.

### What is a SAN used for?

A client can validate the VPN Cert (and hence the remote VPN host) in several ways. Among them:

* Is the VPN Cert signed by the CA that the client thinks it should be?

* Does the VPN Cert have a SAN key that matches the one the client wants?
    *  **iOS**: Is the remote ID in the iOS VPN configuration one of the SAN keys? (It probably checks the hostname as well, but this has not been validated by the author)

    *  **Windows**: Is one of the SAN keys set as the VPN server hostname/IP address as specified in the Windows VPN configuration? If you use a hostname, the FQDN host must be a SAN key. Likewise, if you're accessing the VPN using an IP address (NOT recommended), the IP address must be a SAN key. Note if you use an IP address and the IP address changes, you'll need to recreate the VPN and client Certs.

The command switch --vpnsankey controls the SAN contents in the VPN Cert. 

* There is no default value for the VPN SAN key. If you want to use the VPN with Windows clients you will need to specify the FQDN host name or IP address (see above).

## /etc/swanctl/swanctl.conf

pistrong doesn't touch /etc/swanctl.conf. makeMyCA creates its configuration information in /etc/swanctl/conf.d/pistrong-CAServer-Connection.conf. If you're using multiple CAs and/or multiple VPN keys, refer to [swanctl.conf](https://wiki.strongswan.org/projects/strongswan/wiki/Swanctlconf). If you change the vpnsankey, add new client types, or use other than the default CA Cert names, you will need to create a new connection file in /etc/swanctl/conf.d. strongSwan automatically sources all of the config files in this directory when it starts up.

## User/device Certificates

See CertInstall for the details on installing User/device certificates. These certs are named *username*-*devicename*-*hostname*@*cnsuffix* These fields are:

* **username** - The username specified on the pistrong add command
* **devicename** - the device name from --device or *dev* if --device not provided
* **hostname** - pistrong gets the hostname from the running host
* **cnsuffix** - *ipsec.vpn* by default. Change with --cnsuffix

## Command Examples

* `pistrong createca caname`

    Create the CA. Initial contents consist of a CA Cert *caname*CACert, a VPN Cert default-*caname*VPNCert, the above-mentioned directories, and the database (pistrongdb.json). If *caname* is not specified, the default CA name (strongSwan) will be used.

* `pistrong showca caname`

    Display the CA and VPN Certs for the CA named *caname*

* `pistrong showcert /etc/swanctl/x509ca/strongSwanCACert.pem`

    Display a Cert. Use with both CA and VPN Certs

* `pistrong makevpncert finance --cacert caname`

    Make a VPN Key named *finance* for CA *caname* 

* `pistrong makevpncert finance --vpnsankey finance.dept,host.company.com`

    Make a VPN Cert/Key. The SAN keys will be *finance.dept* and *host.company.com*

* `pistrong list username --all --full`

    List all the certificates for user *username*. Use --full to see the user Cert details.

* `pistrong service reload`

    Tell strongSwan to reload its certificate database