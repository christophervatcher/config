# VPN Notes

## OpenVPN

Instructions taken from [here](https://linuxconfig.org/openvpn-setup-on-ubuntu-18-04-bionic-beaver-linux). Description derived from [here](https://openmaniak.com/openvpn.php).

OpenVPN is an application-layer VPN. It has two modes of operation: pre-shared key and TLS. These instructions configure OpenVPN in TLS mode, which of course employs a CA-based PKI to facilitate VPN key exchange. OpenVPN uses OpenSSL to perform TLS. The Easy-RSA package, which was developed for OpenVPN, automates the setup of a self-signed CA and generates keys/certificates.

Begin by installing the OpenVPN and Easy-RSA software packages. The Easy-RSA packages installs scripts to `/usr/share/easy-rsa`. The instructions linked recommend running the `make-cadirs` script. However, that script creates a symbolic link to the distro-owned `/usr/share/easy-rsa` directory. Instead, simply copy the directory to `/etc/openvpn`.

*Note: The Easy-RSA scripts are mostly a wrapper around the pkitool script.*

```shell
sudo su -
apt install openvpn easy-rsa
cp -rf /usr/share/easy-rsa /etc/openvpn/
```

Now configure Easy-RSA to build a certificate authority by editing the `vars` file in the Easy-RSA directory. Sourcing the `vars` file exports the Easy-RSA configuration as environment variables. The `clean-all` script must be run before the other scripts to create the directory where keys will be generated.

```shell
cd /etc/openvpn/easy-rsa
vim vars
source vars
./clean-all
./build-ca
```

Next, generate a server certificate using the `build-key-server` script. This script takes the canonical name of the server as the parameter. Then generate the Diffe-Hellman parameters for the TLS key exchange. Four files are generated as part of these scripts: `<server>.crt`, `<server>.key`, `ca.crt`, and `dh2048.pem`. Copy these to

```shell
cd /etc/openvpn/easy-rsa
source vars
./build-key-server <cn-server-name>
./build-dh
openvpn --genkey --secret keys/ta.key
cp /etc/openvpn/easy-rsa/keys/{<server>.crt,<server>.key,ca.crt,dh2048.pem,ta.key} /etc/openvpn
```

Now we can generate client certificates using the `build-key` script.

```shell
cd /etc/openvpn/easy-rsa
source vars
./build-key <cn-client>
```

### Intranet Routing
