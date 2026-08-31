{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  python3,
  blast,
}:

let
  pythonEnv = python3.withPackages (
    ps: with ps; [
      pandas
      biopython
      openpyxl
    ]
  );
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "genoflu";
  version = "1.07";

  src = fetchFromGitHub {
    owner = "USDA-VS";
    repo = "GenoFLU";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EFLtx+x90zHnqIkYmXQ5Oanni1r28/mMeeiP0qXVyZg=";
  };

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    substituteInPlace bin/genoflu.py \
      --replace-fail '#!/usr/bin/env python' '#!${pythonEnv}/bin/python'
  '';

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # genoflu.py locates its reference data relative to its own realpath:
    #   os.path.realpath(__file__)/../dependencies/{fastas,genotype_key.xlsx}
    # so bin/ and dependencies/ have to stay adjacent.
    mkdir -p $out/share/genoflu
    cp -r bin dependencies $out/share/genoflu/
    chmod +x $out/share/genoflu/bin/genoflu.py

    # Keep the .py suffix — misc/gen-genoflu-report.sh:27 invokes `genoflu.py` literally.
    # makeWrapper execs the real path, so __file__ still resolves inside share/genoflu/bin.
    makeWrapper $out/share/genoflu/bin/genoflu.py $out/bin/genoflu.py \
      --prefix PATH : ${lib.makeBinPath [ blast ]}
    ln -s genoflu.py $out/bin/genoflu

    runHook postInstall
  '';

  meta = {
    description = "Influenza A genotyping tool for the US H5 2.3.4.4b lineage";
    homepage = "https://github.com/USDA-VS/GenoFLU";
    license = lib.licenses.unlicense; # Repo uses a public-domain dedication
    mainProgram = "genoflu.py";
    platforms = lib.platforms.unix;
  };
})
