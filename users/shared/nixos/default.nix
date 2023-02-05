{ pkgs
, lib
, inputs
, config
, ...
}: {
  imports = [
    ./console.nix
    ./env.nix
    ./bluetooth.nix
    ./audio.nix
    ./network.nix
    ./fonts.nix
    ./xdg.nix
  ];

  programs.dconf.enable = true;
  services.upower.enable = true;
  services.fstrim.enable = true;
  hardware.opengl.enable = true;
}
