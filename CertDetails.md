# pistrong Certificate Authority Deep Dive

pistrong is designed to be easy-to-use with no need to for the administrator to know about Certificate Authority (CA) Certs/Keys and VPN Certs/Keys. However, in more complex configurations, learning more about this is probably unavoidable. The goal of this document is to make that easier.

## CA overview
The strongSwan CA is maintained in /etc/swanctl, which is the structure used by the strongSwan systemd-swanctl service. The CA is maintained on behalf of strongSwan in several subdirectories:

* **x509** - Public Certs
* **x509ca** - CA Certs
* **private** - Private keys for Certs
* **p12** - User/device Certs
* **x509crl** - Revoked Cert list

`pistrong makeca` with no CA name specified creates a CA named *strongSwan*. If additional CAs are created, specify the CA name with `--cacert`. CA Cert filenames are of the form *caname*CACert. For example, the Cert name for the default CA is **strongSwanCACert**.

If you are using multiple CAs, you must use `--cacert` on the *add*, *showca*, and *makevpncert* commands to ensure that your updates are added to the correct CA.

## VPN Cert

The VPN Cert is used by the client to help validate that it's connecting with the server that it thinks it is. VPN Cert names are of the form *vpncertname-cacertname*VPNCert. By default, when the default CA is created, a VPN Cert named **default-strongSwanVPNCert** is created.

Additional VPN Certs can be created. Use `--vpncert` to specify the VPN Cert name. Use `--cacert` to specify the CA name when creating a VPN Cert for other than the default CA.

### What is a SAN used for?

A client can validate the VPN Cert (and hence the remote VPN host) in several ways. Among them:

* Is the VPN Cert signed by the CA that the client thinks it should be?

* Does the VPN Cert have a SAN key that matches the one the client wants?
    *  **iOS**: Is the remote ID in the iOS VPN configuration one of the SAN keys? (It probably checks the hostname as well, but this has not been validated by the author)

    *  **Windows**: Is one of the SAN keys set as the VPN server hostname/IP address as specified in the Windows VPN configuration? If you use a hostname, the FQDN host must be a SAN key. Likewise, if you're accessing the VPN using an IP address (NOT recommended), the IP address must be a SAN key. Note if you use an IP address and the IP address changes, you'll need to recreate VPN cert and update the client VPN configurations.

The command switch --vpnsankey controls the SAN contents in the VPN Cert. 

* The default value for the VPN SAN key is the fully qualified host name (FQDN). If you want to use the VPN with Windows clients this is all youll need unless you're using an IP address. However, pistrong will force you to specify an additional SAN key in case you're using iOS. For iOS this additional SAN key must be specified in the VPN Cert and also configured as the Remote ID on the iOS clients.

* For instance, `--vpnsankey my.special.vpn` adds SAN key my.special.vpn, which is also added to the iOS VPN configuration, and host.domain.com (the FQDN of the server), which is used by Windows Clients.

## /etc/swanctl/swanctl.conf

pistrong doesn't maintain much in swanctl.conf, especially for multiple CAs. If you're using multiple CAs and/or multiple VPN keys, refer to [https://wiki.strongswan.org/projects/strongswan/wiki/Swanctlconf](URL). If you change the vpnsankey, add new client types, or use other than the default CA Cert names, you'll need to edit /etc/swanctl/swanctl.conf.

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

    Display the CA and VPN Certs for the CA named *caname*

* `pistrong showcert /etc/swanctl/x509ca/strongSwanCACert.pem`

    Display a Cert. Use with both CA and VPN Certs

* `pistrong makevpncert finance --cacert caname`

    Make a VPN Key named *finance* for CA *caname* 

* `pistrong makevpncert finance --vpnsankey finance.dept,host.company.com`

    Make a VPN Cert/Key. The SAN keys will be *finance.dept* and *host.company.com*

* `pistrong list username --all --full`

    List all the certificates for user *username*. Use --full to see the user Cert details.
