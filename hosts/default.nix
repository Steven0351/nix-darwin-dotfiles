{ ... }:

{
  # nix-darwin configurations
  parts.darwinConfigurations.m1 = {
    system = "aarch64-darwin";
    stateVersion = 4;
    modules = [ ./m1/configuration.nix ];
  };

  # NixOS configurations
  parts.nixosConfigurations = {
    c1 = {
      system = "x86_64-linux";
      stateVersion = "23.05";

      modules = [ ./c1/configuration.nix ];
    };
  };
}
