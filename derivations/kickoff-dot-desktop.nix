{ rustPlatform
, fetchFromGithub
,
}: {
  kickoff-dot-desktop = rustPlatform.buildRustPackage {
    pname = "kickoff-dot-desktop";

    src = fetchFromGitHub {
      owner = "j0ru";
      repo = "kickoff-dot-desktop";
      rev = "26cf8b9e6c7dc5afde29c200e91c4108d9841f93";
      sha256 = "sha256-CcBiCcfOJzuq0DnokTUHpMdo7Ry29ugQ+N7Hk0R+cQE=";
    };

    cargoSha256 = "sha256-bS7yBnxAWPoTTabxI6W5Knl1DFiDztYSkEPJMa8bqlY=";
  };
}
