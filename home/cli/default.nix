{ pkgs
, lib
, inputs
, config
, ...
}: {
  imports = [
    ./bat.nix
    ./exa.nix
    ./fish.nix
    ./git.nix
    ./starship.nix
    ./zoxide.nix
  ];
}
