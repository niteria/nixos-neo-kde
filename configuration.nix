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
  # Generic installed-system onboarding: no shared password or operator key is
  # embedded in the image. The console prompt finishes before the display manager.
  systemd.services.neo-initial-password = {
    description = "Set the initial Neo login password";
    requiredBy = [ loginService ];
    before = [ loginService ];
    after = [ "systemd-user-sessions.service" ];
    unitConfig.ConditionPathExists = "!/var/lib/nixos-neo/account-ready";
    serviceConfig = {
      Type = "oneshot";
      StandardInput = "tty-force";
      StandardOutput = "tty";
      StandardError = "tty";
      TTYPath = "/dev/tty1";
      TTYReset = true;
    };
    path = [
      pkgs.shadow
      pkgs.coreutils
      pkgs.kbd
    ];
    script = ''
      chvt 1
      echo "Choose a password for the neo account. KDE login starts after this completes."
      passwd neo
      install -d -m 700 /var/lib/nixos-neo
      touch /var/lib/nixos-neo/account-ready
    '';
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
