# Container Notes

## LXD

* [Ubuntu LXD 2.0 Story](https://insights.ubuntu.com/2016/03/14/the-lxd-2-0-story-prologue/)
* [LXD Project Lead's Blog (stgraber)](https://stgraber.org/)

## Static IP addresses in LXD

Profiles are assigned to containers upon creation. The default profile assigns the default bridge (`lxdbr0`) to the
container. The LXD network subsystem uses the profile to detect which containers use the bridge even though the bridge
is not yet attached to the container. The bridge is not actually attached until the container starts. In order to
assign a static IP address, the bridge must be attached to the container prior to execution. This attachment must be
done explicitly.

Instructions taken from [here](https://discuss.linuxcontainers.org/t/lxd-host-with-arch-linux-cant-set-static-ip-to-containers-via-dnsmasq/1197/8).

```bash
lxc init <image> <container>
lxc network attach lxdbr0 <container> eth0
lxc config device set <container> eth0 ipv4.address <static-ip>
```

References:
* https://blog.simos.info/how-to-make-your-lxd-containers-get-ip-addresses-from-your-lan-using-a-bridge/
* https://blog.simos.info/how-to-make-your-lxd-container-get-ip-addresses-from-your-lan/
* https://blog.simos.info/how-to-use-lxd-instance-types/

## GUI applications in LXD

*Note: This will not work in Wayland.*

On the host, you need to map the container's user to root on the host.

```bash
echo "lxd:<user-uid>:1" | tee -a /etc/subuid /etc/subgid
echo "root:<user-uid>:1" | tee -a /etc/subuid /etc/subgid
```

On the host per-container, you need to perform the UID/GID mapping and map the host devices/files.

```bash
lxc config set <container> raw.idmap "both <user-uid> 1000"
lxc restart <container>

# Add the X display and XAuthority file.
lxc config device add <container> X0 disk path=/tmp/.X11-unix/X0 source=/tmp/.X11-unix/X0
lxc config device add <container> XAuthority disk path=/home/ubuntu/.Xauthority source=${XAUTHORITY}
lxc exec <container> -- sudo --login --user ubuntu echo "export DISPLAY=:0" >> ~/.profile

# Add GPU acceleration. (Likely not needed for Intel GPUs.)
lxc config device add <container> <gpu> gpu
lxc config device set <container> <gpu> uid 1000
lxc config device set <container> <gpu> gid 1000
```

For audio, we enable Pulse Audio's network server capability and configure the container to stream audio over the network.

```bash
apt install paprefs
paprefs # Enable network access for sound devices.
```

Run the following in the container.

```bash
echo export PULSE_SERVER="tcp:`ip route show 0/0 | awk '{print $3}'`" >> ~/.profile
mkdir -p ~/.config/pulse/
echo export PULSE_COOKIE=/home/ubuntu/.config/pulse/cookie >> ~/.profile
```

Finally, map the Pulse Audio cookie file into the container.

```bash
lxc config device add <container> PACookie disk path=$HOME/.config/pulse/cookie source=/home/ubuntu/.config/pulse/cookie
```

References:
* https://blog.simos.info/how-to-run-wine-graphics-accelerated-in-an-lxd-container-on-ubuntu/
* https://blog.simos.info/how-to-run-graphics-accelerated-gui-apps-in-lxd-containers-on-your-ubuntu-desktop/
* https://bitsandslices.wordpress.com/2015/12/08/creating-an-lxd-container-for-graphics-applications/

### Evince (AppArmor)

#### Denied access to X display sockets
AppArmor prevents evince from accessing the X display sockets by default (`/tmp/X11-unix/*`).
Copy the relevant lines from `/usr/apparmor.d/abstractions/X` to `/usr/apparmor.d/local/usr.bin.evince`.

#### Denied access based on Failed Name Lookup - Disconnected Path
Evince attempts to do a DNS lookup, which it does not have permission to do. Apply
`flags=(attach_disconnected)` to `/usr/apparmor.d/usr.bin.evince`.

## Atom in LXD
```shell
apt install libcanberra-gtk3-module libasound2 libxkbcommon-x11-0 libxkbfile1
```

## System-local Pi-Hole

Instruction outline: Configure an Ubuntu instance with a fixed IP address given from the LXD host. Then configure the LXD host's DHCP configuration to prioritize the container as the DNS server. Because systemd handles DNS fallback incorrectly, you must replace rather than supplement DNS settings on the host.

Verify the DNS settings for the interface using `systemd-resolve --status`.

## Migrating LXD Containers

To migrate LXD containers from one host to another, the process is to setup the listening services on both endpoints. At least one LXD instance must be network-accessible. This configuration assumes the local LXD instance is private and thus must "push" its data to the remote LXD instance.

1. Setup the remote LXD instance to listen on HTTPS with a shared key.

```shell
remote$ lxc config set core.https_address [::]:8443
remote$ lxc config set core.trust_password something-secure
```

2. Setup the local LXD instance to also listen on HTTPS.

```shell
local$ lxc config set core.https_address [::]:8443
```

3. Add the remote LXD instance to the local LXD instance as a remote server. During this process, the remote server will prompt for the password so it can store the local's certificate.

```shell
local$ lxc remote add <remote> <remote.ip>
```

4. Check the local configuration. Ensure all device mounts, storage pools, network settings, and other settings are accounted for.

```shell
local$ lxc config show <container>
local$ lxc config device show <container>
```

5. Move the local container.

```shell
local$ lxc stop <container>
local$ lxc move <container> <remote>: --mode=push
local$ lxc storage volume <pool>/<volume> <remote>:<pool>/<volume> --mode=push
```

6. Verify the configuration on the remote.

```shell
remote$ lxc config show <container>
remote$ lxc config device show <container>
```

## Snappy Snap Packages

### Snap Support in LXD Containers

Snap support in LXD requires `squashfuse` installed in the container per
[stgraber](https://stgraber.org/2016/12/07/running-snaps-in-lxd-containers/).
