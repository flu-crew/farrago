{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  jre,
  libcanberra-gtk3,
  makeBinaryWrapper,
  makeDesktopItem,
  copyDesktopItems,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "figtree";
  version = "1.4.5pre";

  src = fetchurl {
    url = "https://github.com/rambaut/figtree/releases/download/v${finalAttrs.version}/FigTree_v1.4.5_pre.tgz";
    hash = "sha256-7HuTpFTHHJ0LAjSR4LVElFJd8/LOzA/r2Rmg+c5OdeU=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    copyDesktopItems
  ];

  # Nothing to compile; the tarball is a jar plus data files.
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 lib/figtree.jar $out/share/figtree/figtree.jar
    install -Dm644 images/figtree.png $out/share/icons/hicolor/128x128/apps/figtree.png
    install -Dm644 -t $out/share/figtree/examples carnivore.tree influenza.tree
    install -Dm644 README.txt $out/share/doc/figtree/README.txt

    makeWrapper ${lib.getExe' jre "java"} $out/bin/figtree \
      --add-flags "-Xms64m -Xmx512m -jar $out/share/figtree/figtree.jar" \
      ${lib.optionalString stdenv.hostPlatform.isLinux ''--suffix GTK_PATH : "${libcanberra-gtk3}/lib/gtk-3.0"''}

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "figtree";
      exec = "figtree %F";
      icon = "figtree";
      desktopName = "FigTree";
      comment = "Graphical viewer of phylogenetic trees";
      categories = [
        "Science"
        "Biology"
      ];
    })
  ];

  meta = {
    description = "Graphical viewer of phylogenetic trees and program for producing publication-ready figures";
    homepage = "https://github.com/rambaut/figtree";
    # No LICENSE file upstream
    license = lib.licenses.gpl2Plus;
    mainProgram = "figtree";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = jre.meta.platforms;
  };
})
