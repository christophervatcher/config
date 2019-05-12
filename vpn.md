# VPN Notes

## OpenVPN

Instructions taken from [here](https://linuxconfig.org/openvpn-setup-on-ubuntu-18-04-bionic-beaver-linux). Description derived from [here](https://openmaniak.com/openvpn.php).

OpenVPN is an application-layer VPN. It has two modes of operation: pre-shared key and TLS. These instructions configure OpenVPN in TLS mode, which of course employs a CA-based PKI to authenticate server and client and to facilitate VPN key exchange. OpenVPN uses OpenSSL to perform TLS. The Easy-RSA package, which was developed for OpenVPN, automates the setup of a self-signed CA and generates keys/certificates.

### Creating the TLS Certificate Authority

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

### Creating the TLS Server Certificate

Next, generate a server certificate using the `build-key-server` script. This script takes the canonical name of the server as the parameter. Then generate the Diffe-Hellman parameters for the TLS key exchange. Four files are generated as part of these scripts: `<server>.crt`, `<server>.key`, `ca.crt`, and `dh2048.pem`. Copy these to

```shell
cd /etc/openvpn/easy-rsa
source vars
./build-key-server <cn-server-name>
./build-dh
openvpn --genkey --secret keys/ta.key
cp /etc/openvpn/easy-rsa/keys/{<server>.crt,<server>.key,ca.crt,dh2048.pem,ta.key} /etc/openvpn
```

### Creating a TLS Client Certificate

Now we can generate client certificates using the `build-key` script.

```shell
cd /etc/openvpn/easy-rsa
source vars
./build-key <cn-client>
```

### Configuring the OpenVPN Server

Copy the example configuration from `/usr/share/doc/openvpn/examples` to the OpenVPN configuration directory. Then edit the server configuration file to use the TLS server keys/certificates generated.

```dosini
proto [tcp|udp]
port 1194
dev tun

ca <ca-file>
cert <cert-file>
key <key-file>
dh <dhparams-file>

topology subnet
server <network> <netmask>
ifconfig-pool-persist /var/log/openvpn/ipp.txt
push "route <network> <netmask>"

; Redirect the client's Internet traffic through the VPN including DNS lookups.
;push "redirect-gateway def1 bypass-dhcp"
;push "dhcp-option DNS <dns-server>"

keepalive 10 120
tls-auth ta.key 0
cipher AES-256-GCM
; Enable compression. Note: This can expose VPN traffic to VORACLE attack.
compress lz4-v2
push "compress lz4-v2"

max-clients 10

; Run OpenVPN server unprivileged.
user nobody
group nogroup
persist-key
persist-tun

status /var/log/openvpn/openvpn-status.log
verb 3

explicit-exit-notify 1
```

#### Intranet Routing

The server configuration file pushes intranet routes to the client. To ensure OpenVPN routes traffic to the server network, enable IP forwarding on the OpenVPN server. Then configure IP tables to enable IP masquerade (one-to-many NAT).

* IP Forwarding
    * `/etc/sysctl.conf`
        ```dosini
        net.ipv4.ip_forward=1
        ```
    * `sysctl -p /etc/sysctl.conf`
* IP Masquerade
    * `/etc/ufw/before.rules`
        ```dosini
        *nat
        :POSTROUTING ACCEPT [0:0] 
        -A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE
        COMMIT
        ```
    * `/etc/default/ufw`
        ```dosini
        DEFAULT_FORWARD_POLICY="ACCEPT"
        ```
    * `ufw reload`

### Configuring OpenVPN Clients

```dosini
client
dev tun
proto [tcp|udp]

remote-random
remote <openvpn-server> <openvpn-port>

resolv-retry infinite
nobind

; Run OpenVPN service unprivileged.
user nobody
group nogroup
persist-key
persist-tun

<ca>
CERTIFICATE-AUTHORITY CERTIFICATE
</ca>
<cert>
CLIENT-SIDE TLS CERTIFICATE
</cert>
<key>
CLIENT-SIDE TLS PRIVATE KEY
</key>

remote-cert-tls server
tls-auth ta.key 1
cipher AES-256-GCM
; Enable compression. Note: This can expose VPN traffic to VORACLE attack.
compress lz4-v2
push "compress lz4-v2"

verb 3
```
