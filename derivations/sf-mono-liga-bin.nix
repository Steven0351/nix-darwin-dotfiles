{ stdenvNoCC
, fetchFromGithub
,
}: {
  sf-mono-liga-bin = stdenvNoCC.mkDerivation {
    pname = "sf-mono-liga-bin";

    src = fetchFromGitHub {
      owner = "shaunsingh";
      repo = "SFMono-Nerd-Font-Ligaturized";
      rev = "7723040ef50633da5094f01f93b96dae5e9b9299";
      sha256 = "sha256-CcBiCcfOJzuq0DnokTUHpMdo7Ry29ugQ+N7Hk0R+cQE=";
    };

    dontConfigure = true;
    installPhase = ''
      mkdir -p $out/share/fonts/opentype
      cp -R $src/*.otf $out/share/fonts/opentype/
    '';
  };
}
