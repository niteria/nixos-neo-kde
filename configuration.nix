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
  system.nixos.tags = [
    "aurora-wip"
    "audio"
    "gpu-agx3"
  ];
  networking.hostName = "nixos-neo";
  hardware.macbookNeo = {
    boot.backend = "systemd-boot";
    platform = "aurora-wip";
    display.mode = "native";
    gpu = {
      mode = "enabled";
      package = config.hardware.macbookNeo.packages.mesa-agx3;
    };
    # Short wake tests passed, but extended-sleep/reset reliability remains open.
    power.suspend = "disabled";
    audio.enable = true;
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
    pkgs.vulkan-tools
    pkgs.mesa-demos
    config.hardware.macbookNeo.packages.gpu-render-smoke
  ];

  specialisation.console.configuration = {
    services.xserver.enable = lib.mkForce false;
    services.displayManager.sddm.enable = lib.mkForce false;
    services.desktopManager.plasma6.enable = lib.mkForce false;
    systemd.defaultUnit = lib.mkForce "multi-user.target";
    system.nixos.tags = [ "console" ];
  };
  specialisation.software.configuration = {
    hardware.macbookNeo.gpu.mode = lib.mkForce "prepare";
    system.nixos.tags = [ "software" ];
  };
}
