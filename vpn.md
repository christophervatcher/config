# VPN Notes

## OpenVPN

Instructions taken from [here](https://linuxconfig.org/openvpn-setup-on-ubuntu-18-04-bionic-beaver-linux).

Begin by installing the OpenVPN and Easy-RSA software packages. The Easy-RSA packages installs scripts to `/usr/share/easy-rsa`. The instructions linked recommend running the `make-cadirs` script. However, that script creates a symbolic link to the distro-owned `/usr/share/easy-rsa` directory. Instead, simply copy the directory to `/etc/openvpn`.

```bash
sudo apt install openvpn easy-rsa
sudo cp -rf /usr/share/easy-rsa /etc/openvpn/
```

Now configure the Easy-RSA.

### Intranet Routing
