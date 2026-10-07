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
          hardware = cfg.hardware.macbookNeo;
          kernel = cfg.boot.kernelPackages.kernel;
        in
        assert builtins.all (item: item.assertion) cfg.assertions;
        assert cfg.services.desktopManager.plasma6.enable;
        assert cfg.services.displayManager.sddm.enable;
        assert cfg.hardware.macbookNeo.wifi.enable;
        assert cfg.hardware.macbookNeo.boot.backend == "systemd-boot";
        assert hardware.gpu.mode == "prepare";
        assert kernel.src.rev == nixos-neo.inputs.aurora-linux-gpu.rev;
        assert hardware.packages.fuse-module.kernel.outPath == kernel.outPath;
        assert cfg.system.build.neoAveModule.kernelSourceRevision == kernel.src.rev;
        assert builtins.elem "module_blacklist=asahi" cfg.boot.kernelParams;
        assert !(builtins.elem "asahi" cfg.boot.kernelModules);
        assert cfg.environment.sessionVariables.GALLIUM_DRIVER == "llvmpipe";
        assert hardware.bluetooth.enable && hardware.bluetooth.automaticAdmission;
        assert hardware.avd.enable && hardware.ave.enable && hardware.ave.ffmpeg.enable;
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
        assert console.hardware.macbookNeo.gpu.mode == "prepare";
        assert console.system.build.neoAveDeviceTree.outPath == cfg.system.build.neoAveDeviceTree.outPath;
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
