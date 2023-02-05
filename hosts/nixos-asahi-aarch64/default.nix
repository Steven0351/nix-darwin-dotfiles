{ pkgs
, lib
, inputs
, ...
}: {
  imports = [
    # auto generated 
    ./hardware-configuration.nix
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
  ];

  # overlay
  nixpkgs.overlays = [ inputs.nixos-apple-silicon.overlays.apple-silicon-overlay ];

  # new kernel
  hardware.asahi.addEdgeKernelConfig = true;

  # apple firmware
  hardware.asahi.peripheralFirmwareDirectory = ./firmware;

  # enable graphics acceleration 
  hardware.asahi.useExperimentalGPUDriver = true;
  hardware.asahi.experimentalGPUInstallMode = "driver";

  environment.variables = {
    MESA_GL_VERSION_OVERRIDE = "3.3";
    MESA_GLES_VERSION_OVERRIDE = "3.1";
    MESA_GLSL_VERSION_OVERRIDE = "330";
  };

  # jack volume is set to 0 by default, we probbaly need to turn that up a bit
  systemd.services.makemyheadphonejackwork = {
    script = ''
      ${pkgs.alsa-utils}/bin/amixer -c 0 cset numid=3 100%
    '';
    wantedBy = [ "multi-user.target" ];
  };

  #   # use sway by default
  #   services = {
  #     logind.lidSwitch = "ignore";
  #     greetd = {
  #       enable = true;
  #       package = pkgs.greetd.tuigreet;
  #       settings = {
  #         default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --cmd sway";
  #       };
  #     };
  #   };

  # use systemd-boot
  boot.loader.systemd-boot.enable = true;

  networking.hostName = "shaunsingh-nixos-asahi";
  system.stateVersion = "23.05";
}
