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
        in
        assert cfg.services.desktopManager.plasma6.enable;
        assert cfg.services.displayManager.sddm.enable;
        assert cfg.hardware.macbookNeo.wifi.enable;
        assert cfg.hardware.macbookNeo.boot.backend == "systemd-boot";
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
        nixpkgs.legacyPackages.x86_64-linux.runCommand "nixos-neo-kde-composition" { } "touch $out";
    };
}
