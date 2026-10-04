# NixOS Neo KDE

A small, standard graphical consumer of `nixos-neo`: KDE Plasma 6, SDDM,
NetworkManager and Firefox. Hardware support, the matched built-in boot keyboard,
Wi-Fi provisioning and EFI generation/specialisation menus come from `nixos-neo`.

There are no personal SSH keys, network credentials, unit calibration files or
partition UUIDs in this configuration. The installer discovers installation
identities and collects the target Neo's original radio inputs locally in macOS.

## Build

```sh
nix build .#installer
```

The output contains `nixos-neo-installer.tar.gz` and its checksum. The complete
Linux payload and native ARM64 macOS runtime are bundled; Apple recovery assets
are obtained by the installer. Native ARM package builds need an ARM builder or
configured emulation on the x86_64 build controller.

The support repository is currently private. Build access uses ordinary GitHub
SSH authentication; no GitHub credential is needed to run the resulting installer.
`flake.lock` pins the exact support revision.

For support-library development before publishing a new revision:

```sh
nix build .#installer --override-input nixos-neo path:/path/to/nixos-neo
```

## Installation and first login

Extract the archive on a supported MacBook Neo and run `nixos-neo/Install.command`.
Its menu can discover existing installations, present compatible named targets,
create private run directories and resume saved plans. Use the guided fresh-space
or replacement workflow; explicit `check`, `plan` and `reinstall` commands remain
available for automation. The support repository documents the full workflow.

First boot asks for the `neo` account's password on the local console, then starts
the standard KDE login screen. The shared first-login module temporarily mutes
kernel/service-manager console output during password entry and restores it
afterward; messages remain in the journal. The installer-provided private radio bundle is
validated/imported before automatic radio admission. Choose a network in KDE;
the password stays in the target's NetworkManager profile.
The KDE configuration requires at least a 16 GiB root; a larger allocation leaves
more room for applications and retained generations.

The EFI menu includes each retained generation and a **console** specialisation.
Graphics use the support module's software-rendering fallback. Physical KDE
acceptance and new native installer acceptance are recorded separately from
build and file-backed tests; the existing Neo deployment is not changed by a build.

## Acceptance status

The October 3 release at consumer `1a4e9ee` / support `e66d4d7` passed native macOS
existing-stub reinstallation, first-boot private firmware import, local password
setup, Plasma 6.7.4 Wayland/llvmpipe login and three Wi-Fi-bound IPv4/IPv6 DNS/TLS
rounds. Password, identities, filesystem/Nix probes and saved networking persisted
across a console-specialisation boot.

That console-selected boot exposed MTP command timeouts and missing built-in
keyboard registration; USB input recovered access. Returning to KDE restored
Linux input, but its menu countdown was slow and built-in menu input failed with
USB input working. The separate nscd startup restart-limit failure now has a
resolver-update debounce fix verified by a two-guest VM reproducer and by the
physical generation-2 cold boot and ordinary reboot on October 4. Both boots
had zero failed units; saved networking and persistence checks passed.
See the support repository's `docs/INSTALLER-INTEGRATION.md` and `docs/TODO.md`.

The support pin includes the October 4 USB-menu correction: asynchronous xHCI
interrupt polling with pending-request quiesce before Linux handoff. Physical
mixed USB/built-in arrow and Enter tests, extra USB navigation, normal KDE,
Ethernet/Wi-Fi and persistence checks passed. Its integrated U-Boot binary is
byte-identical to the accepted hardware build. See the support repository's
`docs/USB-KEYBOARD-POLLING.md`. The separate intermittent Linux MTP timeout
remains under investigation.

The guided installer menu also passed native macOS target discovery, small-root
filtering and cancellation after correcting Apple's `Unknown` physical-kind
reporting. The explicit physical-disk inventory identifies the internal SSD.

The newer quiet-password setup passes protocol and real NixOS VM tests; physical
fresh-password acceptance remains pending because existing accounts skip setup.
