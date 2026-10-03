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
Use `check` for the native runtime/bundle preflight, then the fresh-install or
existing-stub workflow documented by `nixos-neo`.

First boot asks for the `neo` account's password on the local console, then starts
the standard KDE login screen. The installer-provided private radio bundle is
validated/imported before automatic radio admission. Choose a network in KDE;
the password stays in the target's NetworkManager profile.
The KDE configuration requires at least a 16 GiB root; a larger allocation leaves
more room for applications and retained generations.

The EFI menu includes each retained generation and a **console** specialisation.
Graphics use the support module's software-rendering fallback. Physical KDE
acceptance and new native installer acceptance are recorded separately from
build and file-backed tests; the existing Neo deployment is not changed by a build.
