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

## Snappy Snap Packages

### Snap Support in LXD Containers

Snap support in LXD requires `squashfuse` installed in the container per
[stgraber](https://stgraber.org/2016/12/07/running-snaps-in-lxd-containers/).
