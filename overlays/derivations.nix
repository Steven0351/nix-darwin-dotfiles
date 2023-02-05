final: prev: {
  kickoff = prev.callPackages ../derivations/kickoff.nix { };
  kickoff-dot-desktop = prev.callPackages ../derivations/kickoff-dot-desktop.nix { };
  otf-apple = prev.callPackages ../derivations/otf-apple.nix { };
  phocus-oxocarbon = prev.callPackages ../derivations/phocus-oxocarbon.nix { };
  sf-mono-liga-bin = prev.callPackages ../derivations/sf-mono-liga-bin.nix { };
}
