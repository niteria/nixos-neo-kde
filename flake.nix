{
  description = "Standard KDE Plasma NixOS consumer and MacBook Neo installer";

  inputs = {
    nixos-neo.url = "git+ssh://git@github.com/niteria/nixos-neo?ref=main";
    nixpkgs.follows = "nixos-neo/nixpkgs";
  };

  outputs =
    {
      self,
      nixos-neo,
      nixpkgs,
    }:
    let
      configuration = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixos-neo.nixosModules.macbookNeo
          nixos-neo.nixosModules.image
          nixos-neo.nixosModules.firstLogin
          ./configuration.nix
        ];
      };
    in
    {
      nixosConfigurations.neo = configuration;
      packages.x86_64-linux = {
        default = self.packages.x86_64-linux.installer;
        installer = configuration.config.system.build.neoInstaller;
        system = configuration.config.system.build.toplevel;
        root-image = configuration.config.system.build.neoRootImage;
        boot-bundle = configuration.config.system.build.neoBootBundle;
      };
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;
      checks.x86_64-linux.configuration =
        let
          cfg = configuration.config;
          console = cfg.specialisation.console.configuration;
          software = cfg.specialisation.software.configuration;
          hardware = cfg.hardware.macbookNeo;
          kernel = cfg.boot.kernelPackages.kernel;
        in
        assert builtins.all (item: item.assertion) cfg.assertions;
        assert cfg.services.desktopManager.plasma6.enable;
        assert cfg.services.displayManager.sddm.enable;
        assert cfg.hardware.macbookNeo.wifi.enable;
        assert cfg.hardware.macbookNeo.boot.backend == "systemd-boot";
        assert hardware.platform == "aurora-wip";
        assert hardware.display.mode == "native";
        assert hardware.gpu.mode == "enabled";
        assert hardware.gpu.package.outPath == hardware.packages.mesa-agx3.outPath;
        assert hardware.gpu.package.neoGpu.kernelSourceRevision == kernel.src.rev;
        assert hardware.gpu.package.neoGpu.mesaSourceRevision == nixos-neo.inputs.aurora-mesa-agx3.rev;
        assert hardware.audio.enable && kernel.neoAudio.speakerInterlock;
        assert kernel.neoAudio.sourceRevision == nixos-neo.inputs.aurora-linux-wip.rev;
        assert kernel.modDirVersion == "7.1.12-neo-aurora-wip-audio-dcp";
        assert kernel.src.rev == nixos-neo.inputs.aurora-linux-wip.rev;
        assert hardware.packages.fuse-module.kernel.outPath == kernel.outPath;
        assert cfg.system.build.neoAveModule.kernelSourceRevision == kernel.src.rev;
        assert !(builtins.elem "module_blacklist=asahi" cfg.boot.kernelParams);
        assert builtins.elem "asahi" cfg.boot.kernelModules;
        assert builtins.elem "appledrm" cfg.boot.kernelModules;
        assert cfg.environment.sessionVariables.GALLIUM_DRIVER == "zink";
        assert cfg.environment.sessionVariables.MESA_LOADER_DRIVER_OVERRIDE == "zink";
        assert !(cfg.environment.sessionVariables ? LIBGL_ALWAYS_SOFTWARE);
        assert hardware.power.suspend == "disabled" && !kernel.neoCapabilities.suspendToIdle;
        assert !cfg.systemd.targets.sleep.enable && !cfg.systemd.targets.suspend.enable;
        assert !cfg.systemd.targets.hibernate.enable && !cfg.systemd.targets.hybrid-sleep.enable;
        assert hardware.bluetooth.enable && hardware.bluetooth.automaticAdmission;
        assert hardware.avd.enable && hardware.ave.enable && hardware.ave.ffmpeg.enable;
        assert cfg.services.pipewire.enable && cfg.services.pipewire.wireplumber.enable;
        assert builtins.elem hardware.audio.guardPackage cfg.services.udev.packages;
        assert
          cfg.systemd.services.speakerguardd.serviceConfig.ExecStart
          == "${hardware.audio.guardPackage}/bin/speakerguardd -C AppleJ700 -c ${hardware.audio.guardPackage}/share/speakerguardd";
        assert
          cfg.systemd.user.services.wireplumber.environment.ALSA_CONFIG_UCM2
          == "${hardware.audio.ucmPackage}/share/alsa/ucm2";
        assert builtins.elem "nixos-neo-ave-provision.service" cfg.systemd.services.neo-ave.requires;
        assert builtins.elem "video" cfg.users.users.neo.extraGroups;
        assert cfg.services.nscd.debounceResolvconf;
        assert cfg.zramSwap.enable && cfg.zramSwap.memoryPercent == 25;
        assert
          cfg.boot.kernelPackages.kernel.mtpHandoff.abi
          == cfg.hardware.macbookNeo.packages.uboot.mtpHandoff.abi;
        assert !cfg.services.openssh.enable;
        assert cfg.users.users.root.openssh.authorizedKeys.keys == [ ];
        assert cfg.users.users.neo.openssh.authorizedKeys.keys == [ ];
        assert cfg.security.sudo.wheelNeedsPassword;
        assert builtins.elem "getty@tty1.service" cfg.systemd.services.neo-initial-password.before;
        assert builtins.elem "display-manager.service" cfg.systemd.services.neo-initial-password.before;
        assert !console.services.displayManager.sddm.enable;
        assert console.systemd.defaultUnit == "multi-user.target";
        assert console.hardware.macbookNeo.gpu.mode == "enabled";
        assert console.hardware.macbookNeo.audio.enable;
        assert console.boot.kernelPackages.kernel.outPath == kernel.outPath;
        assert console.system.build.neoAveDeviceTree.outPath == cfg.system.build.neoAveDeviceTree.outPath;
        assert software.hardware.macbookNeo.gpu.mode == "prepare";
        assert software.hardware.macbookNeo.display.mode == "native";
        assert software.boot.kernelPackages.kernel.outPath == kernel.outPath;
        assert software.system.build.neoAveDeviceTree.outPath == cfg.system.build.neoAveDeviceTree.outPath;
        assert builtins.elem "module_blacklist=asahi" software.boot.kernelParams;
        assert !(builtins.elem "asahi" software.boot.kernelModules);
        assert software.environment.sessionVariables.GALLIUM_DRIVER == "llvmpipe";
        assert !(software.environment.sessionVariables ? MESA_LOADER_DRIVER_OVERRIDE);
        assert !software.systemd.targets.suspend.enable && !console.systemd.targets.suspend.enable;
        nixpkgs.legacyPackages.x86_64-linux.runCommand "nixos-neo-kde-composition" { } "touch $out";
      checks.x86_64-linux.portable-bundle =
        nixpkgs.legacyPackages.x86_64-linux.runCommand "nixos-neo-kde-portable-bundle-check"
          { nativeBuildInputs = [ nixpkgs.legacyPackages.x86_64-linux.python3 ]; }
          ''
            mkdir -p $out
            python3 -B ${nixos-neo}/tests/check_bundle.py \
              ${self.packages.x86_64-linux.installer}/nixos-neo --report $out/report.json
          '';
    };
}
