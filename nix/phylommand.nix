{
  lib,
  stdenv,
  fetchFromGitHub,
  nlopt,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "phylommand";
  version = "1.1-unstable-2024-09-05";

  src = fetchFromGitHub {
    owner = "RybergGroup";
    repo = "phylommand";
    rev = "a67e7b9d7a40157406e4c496a0202369656691ec";
    hash = "sha256-xD9R9ulIAkBFkEJPcuta6ry1662U8nk4yg6h/yuRkzA=";
  };

  # The Makefile lives in src/ and compiles its objects into the working directory.
  sourceRoot = "${finalAttrs.src.name}/src";

  # treeator.cpp includes <nlopt.hpp>, a header-only inline wrapper over NLopt's C API, and links
  # -lnlopt. That nixpkgs builds nlopt with clangStdenv is therefore not a C++ ABI concern.
  buildInputs = [ nlopt ];

  # Already the Makefile default. Passed explicitly so the NLopt dependency is visible next to
  # buildInputs instead of only inside the Makefile.
  makeFlags = [ "NLOPT=YES" ];

  enableParallelBuilding = true;

  # No install target upstream; the binaries are just left in the build directory.
  installPhase = ''
    runHook preInstall

    install -Dm755 -t $out/bin treebender treeator contree pairalign

    mkdir -p $out/share/phylommand
    cp -r ../example_files $out/share/phylommand/

    runHook postInstall
  '';

  meta = {
    description = "Command line software package for phylogenetics";
    homepage = "https://github.com/RybergGroup/phylommand";
    license = lib.licenses.gpl3Plus;
    mainProgram = "treebender";
    platforms = lib.platforms.unix;
  };
})
