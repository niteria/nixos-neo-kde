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
  system.nixos.tags = [ "gpu-prepared" ];
  networking.hostName = "nixos-neo";
  hardware.macbookNeo = {
    boot.backend = "systemd-boot";
    gpu.mode = "prepare";
    wifi.enable = true;
    bluetooth = {
      enable = true;
      automaticAdmission = true;
    };
    avd.enable = true;
    ave = {
      enable = true;
      ffmpeg.enable = true;
      healthUnits = [ "bluetooth.service" ];
    };
    installer.name = "NixOS Neo KDE";
    installer.minimumRootBytes = 16 * 1024 * 1024 * 1024;
  };

  networking.networkmanager.enable = true;
  hardware.graphics.enable = true;
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
    priority = 100;
  };
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
      "video"
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
    pkgs.brave
    pkgs.mpv
  ];

  specialisation.console.configuration = {
    services.xserver.enable = lib.mkForce false;
    services.displayManager.sddm.enable = lib.mkForce false;
    services.desktopManager.plasma6.enable = lib.mkForce false;
    systemd.defaultUnit = lib.mkForce "multi-user.target";
    system.nixos.tags = [ "console" ];
  };
}
