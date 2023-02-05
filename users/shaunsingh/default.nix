{ pkgs
, lib
, inputs
, config
, ...
}: {
  imports = [
    ./locale.nix
  ];

  users.users.shauryasingh = {
    isNormalUser = true;
    home = "/home/shauryasingh";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "render"
      "docker"
    ];
    shell = pkgs.fish;
  };
}
