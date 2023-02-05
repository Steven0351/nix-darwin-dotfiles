{ pkgs
, lib
, inputs
, config
, ...
}: {
  environment.variables = {
    # defaults
    EDITOR = "nvim";
    BROWSER = "firefox";

    # enable wayland 
    NIXOS_OZONE_WL = "1";
    XDG_SESSION_TYPE = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    GDK_BACKEND = "wayland";

    # qt wayland settings
    DISABLE_QT5_COMPAT = "0";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_STYLE_OVERRIDE = "kvantum";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    # fix java stuff on wayland 
    _JAVA_AWT_WM_NONREPARENTING = "1";

    # firefox
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_USE_XINPUT2 = "1";
    MOZ_DISABLE_RDD_SANDBOX = "1";
  };
}
