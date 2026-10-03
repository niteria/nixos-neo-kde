{
  config,
  lib,
  pkgs,
  ...
}:
let
  loginService =
    if config.services.displayManager.sddm.enable then
      "display-manager.service"
    else
      "getty@tty1.service";
in
{
  system.stateVersion = "26.05";
  networking.hostName = "nixos-neo";
  hardware.macbookNeo = {
    boot.backend = "systemd-boot";
    wifi.enable = true;
    installer.name = "NixOS Neo KDE";
    installer.minimumRootBytes = 16 * 1024 * 1024 * 1024;
  };

  networking.networkmanager.enable = true;
  hardware.graphics.enable = true;
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  users.users.neo = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
  };
  services.nixosNeoFirstLogin = {
    enable = true;
    user = "neo";
    loginUnits = [ loginService ];
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };
  environment.systemPackages = [
    pkgs.firefox
    pkgs.git
  ];

  specialisation.console.configuration = {
    services.xserver.enable = lib.mkForce false;
    services.displayManager.sddm.enable = lib.mkForce false;
    services.desktopManager.plasma6.enable = lib.mkForce false;
    systemd.defaultUnit = lib.mkForce "multi-user.target";
    system.nixos.tags = [ "console" ];
  };
}
