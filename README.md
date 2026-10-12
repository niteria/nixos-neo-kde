# NixOS Neo KDE

A graphical consumer of `nixos-neo`: KDE Plasma 6, SDDM, NetworkManager,
Firefox, Brave and mpv. The configuration selects the matched Aurora-WIP native
display and **AGX3 GPU stack: Zink OpenGL and Honeykrisp Vulkan**,
automatic Wi-Fi/Bluetooth provisioning, hardware video decoding, native FFmpeg
AVE encoders, protected speakers/headphones, built-in microphone capture and 25%
zstd zram. Hardware support, the matched built-in boot keyboard and EFI
generation/specialisation menus come from `nixos-neo`.

The kernel and Mesa are selected together with source/UAPI/USC/HAL checks.
The EFI menu provides an accelerated **console** specialisation and a
same-kernel/DTB **software** desktop fallback using llvmpipe with Asahi blocked.
Suspend remains disabled by default while the observed extended-sleep restart
is investigated.

There are no personal SSH keys, network credentials, unit calibration files or
partition UUIDs in this configuration. The installer discovers installation
identities and collects the target Neo's original radio inputs and private AVE
reference locally in macOS.

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

The October12 GPU upgrade pins support
[`327121a`](https://github.com/niteria/nixos-neo/commit/327121a61916baea93a8bf432a339f6f05fec500)
in `flake.lock`,
with Linux `3b2bd35a8591bcad766c60d0681e7f060cfd8cc7` and Mesa
`c12cdb32f7d052f9c1ddce2ac4b0049b92e2f3f1`.
To build the installed generation and boot bundle independently of the installer:

```sh
nix build .#system .#boot-bundle
nix flake check
```

The checks cover parent/console/software kernel and DTB consistency, FUSE/AVE
contracts, explicit Zink selection, the llvmpipe fallback, disabled sleep and
speaker guard/routing, plus the exact KDE installer's
integrity and file-backed write/readback with synthetic Wi-Fi/Bluetooth and AVE
provisioning inputs.

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
Bluetooth is admitted automatically after the matching private bundle is imported.
The KDE configuration requires at least a 16 GiB root; a larger allocation leaves
more room for applications and retained generations.

The EFI menu includes each retained generation and its **console** and **software**
specialisations. The normal desktop uses the matched accelerated Mesa package;
the software fallback retains the same native display driver and shared DTB.
Changing the display backend requires the corresponding full boot-state update
or rollback. Physical KDE
acceptance and new native installer acceptance are recorded separately from
build and file-backed tests; the existing Neo deployment is not changed by a build.

## Video setup

AVD hardware decoding uses the support module's V4L2-request VA-API backend; see
the pinned support repository's [AVD guide](https://github.com/niteria/nixos-neo/blob/327121a61916baea93a8bf432a339f6f05fec500/docs/AVD.md)
for the qualified mpv command.

The installer prepares AVE's **one-time private reference** alongside radio inputs
on the supported Mac17,5/macOS 26.6.2 build 25G83. It collects synthetic encoder
sessions, independently decodes them, indexes the matching native code and caches
the verified reference. The first-boot importer installs the bound private seed
at `/var/lib/nixos-neo/ave-reference` before encoder use. Original code and captures
remain local private data. Existing/custom installations also have a manual route
in the [AVE setup guide](https://github.com/niteria/nixos-neo/blob/327121a61916baea93a8bf432a339f6f05fec500/docs/AVE.md).
The `neo` user has access through the `video` group:

```sh
ffmpeg -i input.mp4 -c:v h264_neo_ave -c:a copy output.mp4
ffmpeg -i another.mp4 -c:v hevc_neo_ave -c:a copy another-output.mp4
```

The first encoder request starts the socket-activated service. Clean sessions
reuse one firmware instance. Parameters and frames are supplied directly by
FFmpeg, with no per-video preparation. The support guide records provenance,
qualified formats and the current lifecycle limits.

## Sound and microphones

`hardware.macbookNeo.audio.enable` selects the matched audio kernel, UCM routing,
PipeWire/WirePlumber profiles, J700 speaker DSP and speaker-protection daemon. Use
the **MacBook Neo J700 Speakers** desktop sink or detected headphones for playback.
The guard retains conservative gain while speaker-sense data is unavailable; the
kernel also enforces a renewable volume lease.

The standard built-in microphone is available through PipeWire. The high-quality
48 kHz interface was qualified through direct ALSA; a separate desktop profile
and default microphone gain/AGC tuning remain pending. Raw capture levels were low;
the attended voice previews used measured normalization. See the
[audio guide](https://github.com/niteria/nixos-neo/blob/327121a61916baea93a8bf432a339f6f05fec500/docs/AUDIO.md)
for device names, source pins, protection details and exact test scope.

## Acceptance status

### October11–12 GPU and power work

The matched support stack passed native Asahi and explicit Zink/Honeykrisp
1,024-pixel rendering checks. KWin6.7.4 used Zink/Vulkan1.4 on the2408×1506 internal
panel, and the operator confirmed desktop redraw, three brightness levels and
five display-off/on cycles. Wi-Fi-only management survived Ethernet removal and
reboot. The upgrade includes the GPU crash-log mapping correction, upstream DART
changes, Wi-Fi-first modular Bluetooth admission, and the existing AVE Rust/frame-
feedback and protected-audio work.

Two reliability items remain open: an intermittent display-DART startup timeout
and an unrequested restart after roughly37minutes of experimental idle sleep.
The support library's explicit s2idle option passed short console/KDE wake tests
and the bound-AVE kernel sleep veto, but these do not qualify everyday suspend.
**This consumer keeps suspend disabled.** Hibernation and kexec also remain disabled.
The GPU/desktop results are bounded hardware checks, not a performance claim or
new media-codec/physical-installer acceptance.
The pinned [GPU qualification record](https://github.com/niteria/nixos-neo/blob/327121a61916baea93a8bf432a339f6f05fec500/docs/GPU-INTEGRATION.md)
and [power experiment](https://github.com/niteria/nixos-neo/blob/327121a61916baea93a8bf432a339f6f05fec500/docs/POWER.md)
describe the exact scope. All41 support-library release checks passed before this pin.

### Earlier AVE/audio and installer checkpoints

The October8 AVE/audio support checkpoint passed all28 offline checks. The native AVE
installer passed fresh/cached preparation; generation 15 automatically imported
its new reference and reproduced both 120-frame 1080p encoder outputs. Generation
16 then passed normal boot/platform checks, real speaker-interlock stop/lease
tests, operator-confirmed left/right speaker/headphone playback and both visible,
user-started microphone voice tests. The packaged audio kernel Image is identical
to the tested kernel; guard/UCM/DSP packages are the exact qualified artifacts.
The AVE module is bound to that Image, but encoding was last hardware-tested on
generation 15 before the audio kernel change.

The October 7 prepared stack passed a direct generation14 boot with matched
PR171 kernel/FUSE/AVE, GPU/UAT handoff, identity/persistence/input checks,
automatic radios, KDE and NSS. Both 120-frame 1080p AVE encoders passed first-use
socket activation and exact prior decoded-pixel comparison. The prepared kernel
also passed nine AVD cases/300 exact frames. The limiter-aware NSS fix passed its
three-guest regression and physical boot/network checks; all 23 support flake
checks passed before publication. See the [GPU integration record](https://github.com/niteria/nixos-neo/blob/c7a9e1bc304de106d218a8da6a2609ea69bd7699/docs/GPU-INTEGRATION.md).
New installer artifacts retain separate native macOS/installation acceptance.
That older checkpoint predated the accelerated GPU results above.

The October 3 release at consumer `1a4e9ee` / support `e66d4d7` passed native macOS
existing-stub reinstallation, first-boot private firmware import, local password
setup, Plasma 6.7.4 Wayland/llvmpipe login and three Wi-Fi-bound IPv4/IPv6 DNS/TLS
rounds. Password, identities, filesystem/Nix probes and saved networking persisted
across a console-specialisation boot.

That console-selected boot exposed MTP command timeouts and missing built-in
keyboard registration; USB input recovered access. Returning to KDE restored
Linux input, but its menu countdown was slow and built-in menu input failed with
USB input working. The separate nscd startup restart-limit failure now has a
resolver-update debounce fix, initially verified by a two-guest VM reproducer and by the
physical generation-2 cold boot and ordinary reboot on October 4. Both boots
had zero failed units; saved networking and persistence checks passed.
The later spaced-update recurrence is covered by the October 7 limiter-aware fix.
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
