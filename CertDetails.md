# pistrong Certificate Authority Deep Dive

pistrong is designed to be easy-to-use with no need to for the administrator to know about Certificate Authority (CA) Certs/Keys and VPN Certs/Keys. However, in more complex configurations, learning more about this is probably unavoidable. That's what this document is for.

## CA overview
The strongSwan CA is maintained in /etc/swanctl, which is the structure used by the strongSwan systemd-swanctl service. The CA is maintained on behalf of strongSwan in several subdirectories:

* **x509** - Public Certs
* **x509ca** - CA Certs
* **private** - Private keys for Certs
* **p12** - User/device Certs
* **x509crl** - Revoked Cert list

`pistrong makeca` with no CA name specified creates a CA named *strongSwan*. If additional CAs are created, specify the CA name with --cacert. CA Cert names are of the form *caname*CACert. For example, the Cert name for the default CA is strongSwanCACert.

If you are using multiple CAs, you must use --cacert on the add, showca, and makevpncert commands to ensure that your additions are added to the correct CA.

## VPN Cert

the VPN Cert is used by the client to validate that it's connecting with the server that it thinks it is. VPN Cert names are of the form *vpncertname-cacertname*VPNCert. By default, when the default CA is created, a VPN Cert named default-strongSwanVPNCert is created.

Additional VPN Certs can be created. Use --vpncert to specify the Cert name. Use --cacert to specify the CA name when creating a VPN Cert for other than the default CA.

### What is a SAN used for?

A client can validate the VPN Cert (and hence the remote host) in several ways. Among them:

* Is the VPN Cert signed by the CA that the client thinks it should be?

* Does the VPN Cert have a SAN key that matches the one the client wants?
    *  **iOS**: Is one of the SAN keys the remote ID in the iOS VPN configuration? (It probably checks the hostname as well, but this has not been validated by the author)

    *  **Windows**: Is one of the SAN keys the VPN server hostname/IP address as specified in the Windows VPN configuration?

The command switches --vpnsankey, --altsankey, and --onlyalt control the SAN contents in the VPN Cert. 

* By default the SAN Keys in the VPN Cert will include the Host FQDN, the server's local IP address, and the --vpnsankey

* --altsankey Specifies one or more alternate SAN Keys in a comma-separated list to include. If --onlyalt is not specified, the values from altsankey are included as additional SANs. If --onlyalt is specified, only the altsankey values are included as SANs (i.e., no Host FQDN, Local IP address or --vpnsankey).

## /etc/swanctl/swanctl.conf

pistrong doesn't maintain much in swanctl.conf, especially for multiple CAs. If you're using multiple CAs and/or multiple VPN keys, refer to [https://wiki.strongswan.org/projects/strongswan/wiki/Swanctlconf](URL). Manual editing of swanctl.conf is required in these scenarios.

## User/device Certificates

See CertInstall for the details on installing User/device certificates. These certs are named *username*-*devicename*-*hostname*@*cnsuffix* These fields are:

* **username** - The username specified on the pistrong add command
* **devicename** - the device name from --device or *dev* if --device not provided
* **hostname** - pistrong gets the hostname from the running host
* **cnsuffix** - *ipsec.vpn* by default. Change with --cnsuffix

## Command Examples

* `pistrong makeca caname` or `pistrong makeca --cacert caname`

    Create the CA. Initial contents consist of a CA Cert *caname*CACert, a VPN Cert default-*caname*VPNCert, the above-mentioned directories, and the database (pistrongdb.json).

* `pistrong showca caname`

    Display the CA and VPN Certs for the CA named CA

* `pistrong showcert /etc/swanctl/strongSwanCACert.pem`

    Display a Cert. Use with both CA and VPN Certs

* `pistrong makevpncert finance --cacert caname`

    Make a VPN Key named finance for CA caname 

* `pistrong makevpncert finance --altsankey finance.dept`

    Make a VPN Cert/Key. In addition to the VPN server's hostname, local IP address, and default VPN SAN Key, include the alternate SAN finance.dept.

* `pistrong makevpncert finance --altsankey finance.dept`

    Ditto, but the Cert will only include the SAN finance.dept.

* `pistrong list username --all --full`

    List all the certificates for user *username*. Use --full to see the Cert details.
