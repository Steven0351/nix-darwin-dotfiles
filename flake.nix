{
  description = "Nix Environment";

  inputs = {
    ### --- nixpkgs

    # hydra.nixos.org/jobset/mobile-nixos/unstable/evals
    # these evals have a cross-compiled stdenv available
    mobile.url =
      "github:nixos/nixpkgs/9b97ad7b4330aacda9b2343396eb3df8a853b4fc";

    # other nixpkgs branches
    master.url = "github:nixos/nixpkgs/master";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    stable.url = "github:nixos/nixpkgs/nixos-21.11";
    nur.url = "github:nix-community/NUR";

    # Default Nixpkgs for packages and modules
    nixpkgs.follows = "mobile";

    ### --- flakes

    # manage home env
    home-manager.url = "github:nix-community/home-manager";

    # secrets
    agenix.url = "github:ryantm/agenix";

    # formatting
    nixpkgs-fmt.url = "github:nix-community/nixpkgs-fmt";

    # platform support
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nix-darwin.url = "github:lnl7/nix-darwin";
    nixos-apple-silicon.url = "github:tpwrules/nixos-apple-silicon";

    # overlays
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    rust-overlay.url = "github:oxalica/rust-overlay";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    # window management
    swayfx.url = "github:WillPower3309/swayfx";

    # bar
    eww.url = "github:elkowar/eww";

    ### --- de-duplicate flake inputs

    agenix.inputs.nixpkgs.follows = "nixpkgs";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixos-apple-silicon.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";
    swayfx.inputs.nixpkgs.follows = "nixpkgs";
    eww.inputs.nixpkgs.follows = "nixpkgs";
    eww.inputs.rust-overlay.follows = "rust-overlay";

    ### --- theme

    base16 = {
      url = "github:shaunsingh/base16.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    base16-oxocarbon = {
      url = "github:nyoom-engineering/base16-oxocarbon";
      flake = false;
    };
  };

  outputs =
    { self, nixpkgs, home-manager, nur, agenix, nix-darwin, ... }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      versionOf = input: input.rev;
      filterNixFiles = k: v: v == "regular" && nixpkgs.lib.hasSuffix ".nix" k;
      importNixFiles = path: with nixpkgs.lib; (lists.forEach (mapAttrsToList (name: _: path + ("/" + name))
        (filterAttrs filterNixFiles (builtins.readDir path)))) import;

      config = {
        allowBroken = true;
        allowUnfree = true;
        allowUnfreePredicate = _: true;
        tarball-ttl = 0;
        contentAddressedByDefault = false;
      };

      overlays = with inputs;
        [
          (final: _:
            let inherit (final) system;
            in {
              eww-wayland-git = inputs.eww.packages.${system}.eww-wayland;
              swayfx-unwrapped-git = inputs.swayfx.packages.${system}.swayfx-unwrapped; 
              } // {
              /* one can access these branches like so:

                 `pkgs.stable.mpd'
                 `pkgs.master.linuxPackages_xanmod'
              */
              master = import master { inherit config system; };
              unstable = import unstable { inherit config system; };
              stable = import stable { inherit config system; };
              mobile = import mobile { inherit config system; };
            })

          rust-overlay.overlays.default
          neovim-nightly-overlay.overlay
          nixpkgs-wayland.overlay
        ] ++ (importNixFiles ./overlays);

      mkSystemConfig =
        { system
        , modules
        , hm-modules
        , useNur ? true
        , useHomeManager ? true
        , isDarwin ? nixpkgs.lib.hasSuffix "-darwin" system
        , ...
        }:
        (if isDarwin then
          nix-darwin.lib.darwinSystem
        else
          nixpkgs.lib.nixosSystem) {
          inherit system;
          specialArgs = { inherit nixpkgs overlays inputs isDarwin; };
          modules = modules ++ [
            agenix.nixosModules.default
            ./users/shared
            {
              nix = import ./nix-settings.nix {
                inherit inputs system nixpkgs;
                max-jobs = 4;
              };
              nixpkgs = { inherit config overlays; };
            }
          ] ++ (if isDarwin then
            [
              ./users/shared/darwin
            ] else
            [
              ./users/shared/nixos
            ])
            ++ nixpkgs.lib.lists.optionals useNur [ nur.nixosModules.nur ]
            ++ nixpkgs.lib.lists.optionals useHomeManager [
            ./users/shaunsingh
            (if isDarwin then
              home-manager.darwinModules.home-manager
            else
              home-manager.nixosModules.home-manager)
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.shauryasingh = {
                imports = hm-modules ++ [ ./home ] ++ nixpkgs.lib.lists.optionals useNur [ nur.hmModules.nur ];
              };
              home-manager.extraSpecialArgs = {
                inherit nixpkgs inputs;
              };
            }
          ];
        };
    in
    {
      ### --- linux configurations

      nixosConfigurations = {
        # macbook via UTM virtual machine
        nixos-utm-aarch64 = mkSystemConfig {
          system = "aarch64-linux";
          modules = [ ./hosts/nixos-utm-aarch64 ];
          hm-modules = [ ];
        };

        # VMWare guest (windows 11 host)
        nixos-virtualboy-x86_64 = mkSystemConfig {
          system = "x86_64-linux";
          modules = [ ./hosts/nixos-virtualboy-x86_64 ];
          hm-modules = [ ];
        };

        # asahi on M1 Macbook pro
        nixos-asahi-aarch64 = mkSystemConfig {
          system = "aarch64-linux";
          modules = [ ./hosts/nixos-asahi-aarch64 ];
          hm-modules = [
            inputs.base16.hmModule
            ./home/themes/oxocarbon.nix

            ./home/cli

            ./home/desktop/cursor.nix
            ./home/desktop/gtk.nix
            ./home/desktop/kanshi.nix
            ./home/desktop/swaybg.nix
            ./home/desktop/bars/eww.nix
            ./home/desktop/browsers/firefox.nix
            ./home/desktop/browsers/nyxt.nix
            ./home/desktop/notifications/dunst.nix
            ./home/desktop/term/foot.nix

            ./home/launchers/rofi.nix

            ./home/wm/swayfx.nix
          ];
        };

        # WSL2 on Win11
        nix-wsl-x86_64 = mkSystemConfig {
          system = "x86_64-linux";
          modules = [ ./hosts/nix-wsl-x86_64 ];
          hm-modules = [ ];
        };
      };

      ### --- darwin configurations

      darwinConfigurations = {
        nix-darwin-aarch64 = mkSystemConfig {
          system = "aarch64-darwin";
          modules = [ ./hosts/nix-darwin-aarch64 ];
          hm-modules = [ ];
        };
      };

      ### --- stuff I should probably upstream but don't

      overlays = overlays;

      ### --- make it easy to bootstrap my config

      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in import ./shell.nix { inherit pkgs; });

      ### --- formatting

      formatter =
        forAllSystems (system: inputs.nixpkgs-fmt.defaultPackage.${system});

      ### --- make it easier to `nix build *` linux machines

      utm =
        self.nixosConfigurations.nixos-utm-aarch64.config.system.build.toplevel;
      virtualboy =
        self.nixosConfigurations.nixos-virtualboy-x86_64.config.system.build.toplevel;
      wsl2 =
        self.nixosConfigurations.nix-wsl-x86_64.config.system.build.toplevel;
      asahi =
        self.nixosConfigurations.nixos-asahi-aarch64.config.system.build.toplevel;

    };

  nixConfig = {
    commit-lockfile-summary = "flake: bump inputs";
    substituters = [
      "https://cache.nixos.org?priority=10"
      "https://cache.ngi0.nixos.org/"
      "https://nix-community.cachix.org?priority=5"
      "https://nixpkgs-wayland.cachix.org"
    ];
  };
}
