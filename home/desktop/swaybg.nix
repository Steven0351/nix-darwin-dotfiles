{ pkgs
, lib
, inputs
, config
, ...
}: {
  imports = [ ../../modules/home-manager/programs/swaybg.nix ];
  programs.swaybg = {
    enable = true;
    image = ../../configs/wallpapers/IBM_Developer_Posters.jpg;
  };
}
