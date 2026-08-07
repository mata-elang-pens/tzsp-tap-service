# tzsp-tap-service

Receives a [TZSP](https://en.wikipedia.org/wiki/TZSP) (TaZmen Sniffer
Protocol) packet stream from a MikroTik RouterOS device's packet sniffer
and injects the raw Ethernet frames into a local `tap0` interface — no
extra software needed on the router itself, RouterOS mirrors traffic to
this service natively.

Built to feed a Snort/Suricata IDS research pipeline
([Mata Elang](https://github.com/mata-elang-stable) —
[mata-elang-pens](https://github.com/mata-elang-pens)) that needs every
real packet on a host interface, not a summary or a sample.

## How it works

- `tzsp-tap` (Python, stdlib only) binds UDP `37008` (RouterOS's default
  TZSP streaming port), strips the TZSP header and tag-list from each
  datagram, and writes the raw Ethernet frame straight into a `tap0` TAP
  device via the `TUNSETIFF`/`IFF_TAP` ioctl. The interface is brought up
  with `promisc on` so downstream tools (Snort, Suricata, `tcpdump`) see
  everything.
- Packaged as a root-run systemd service (`Restart=always`) so it
  survives crashes and reboots.
- `install.sh` also builds and installs
  [`tzsp2pcap`](https://github.com/thefloweringash/tzsp2pcap), a small
  companion tool that dumps the same TZSP stream straight to a `.pcap`
  file for offline inspection in Wireshark — useful for one-off
  debugging without needing `tap0` at all.

```
MikroTik router --TZSP/UDP:37008--> tzsp-tap --> tap0 (promisc, up)
                                                    │
                                          Snort / Suricata / tcpdump
```

## Requirements

- Linux with `/dev/net/tun` available
- Python 3 (stdlib only, no dependencies)
- Root (TAP device creation and systemd service installation both need
  it)
- `git`, `make`, `gcc`, `libpcap-dev` — only needed for the bundled
  `tzsp2pcap` build

## Install

```bash
sudo ./install.sh
```

This builds and installs `tzsp2pcap` to `/usr/local/bin`, installs
`tzsp-tap` to `/usr/local/bin`, installs and enables the `tzsp-tap`
systemd service, and starts it.

Check it's running:

```bash
sudo systemctl status tzsp-tap
ip link show tap0
```

## Router-side setup

On the MikroTik device, point its packet sniffer at this service's host
and port:

```
/tool sniffer set streaming-enabled=yes streaming-server=<this-host-ip>:37008
/tool sniffer start
```

## Uninstall

```bash
sudo ./uninstall.sh
```

Stops and disables the service, and removes the installed binaries and
service file.

## Status

This service is being superseded by
[alfiyansys/tzsp-packet-sensor](https://github.com/alfiyansys/tzsp-packet-sensor),
a Go rewrite that adds a second, concurrent consumer (live topology
reporting into [Scope](https://github.com/alfiyansys/scope)) alongside
the same `tap0` injection behavior this service provides today. This
repo remains the reference implementation and the production service
until that cutover is validated side-by-side and complete.
