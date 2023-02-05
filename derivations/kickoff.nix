{ lib
, rustPlatform
, fetchFromGithub
, pkg-config
, fontconfig
, libxkbcommon
}: {
  kickoff = rustPlatform.buildRustPackage {
    pname = "kickoff";
    verson = "0.6.1";

    src = fetchFromGitHub {
      owner = "j0ru";
      repo = "kickoff";
      rev = version;
      sha256 = "sha256-CcBiCcfOJzuq0DnokTUHpMdo7Ry29ugQ+N7Hk0R+cQE=";
    };

    cargoSha256 = "sha256-bS7yBnxAWPoTTabxI6W5Knl1DFiDztYSkEPJMa8bqlY=";

    nativeBuildInputs = [ pkg-config ];
    buildInputs = [ fontconfig libxkbcommon wayland ];

    postFixup = ''
      patchelf $out/bin/kickoff --add-rpath ${lib.makeLibraryPath buildInputs}
    '';
  };
}
