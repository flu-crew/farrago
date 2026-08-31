# Supported: Linux/WSL and (maybe!!) Apple Silicon macOS 
# x86_64-darwin is not supported: nixos-unstable dropped Intel macOS in 26.11.
# IQtree3 is only on nixos-unstable, and nixpkgs marks it linux-only
{
  description = "Dev environment for the farrago";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forAllSystems =
        f:
        lib.genAttrs systems (
          system:
          f (
            import nixpkgs {
              inherit system;
              overlays = [ self.overlays.default ];
            }
          )
        );
    in
    {
      # Exposed so the hand-rolled derivations can be reused outside this repo.
      overlays.default = final: prev: {
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
          (import ./nix/python-packages.nix { inherit lib; })
        ];

        genoflu = final.callPackage ./nix/genoflu.nix { };
        figtree = final.callPackage ./nix/figtree.nix { };
        phylommand = final.callPackage ./nix/phylommand.nix { };

        # nixpkgs marks iqtree linux-only, but the derivation already handles darwin unverified but I hope this works...
        iqtree = prev.iqtree.overrideAttrs (old: {
          meta = old.meta // { platforms = old.meta.platforms ++ lib.platforms.darwin; };
        });
      };

      packages = forAllSystems (pkgs: {
        inherit (pkgs)
          genoflu
          figtree
          phylommand
          ;
        inherit (pkgs.python3Packages)
          smof
          smot
          ete4
          cluster-affinity
          parnas
          ;
        treetime = pkgs.python3Packages.phylo-treetime;
      });

      devShells = forAllSystems (
        pkgs:
        let
          pythonEnv = pkgs.python3.withPackages (
            ps: with ps; [
              pandas
              biopython
              dendropy
              ete4
              cluster-affinity
              pillow
              pyyaml

              smof
              smot
              phylo-treetime
              parnas
            ]
          );
        in
        {
          default = pkgs.mkShell {
            packages = [
              pythonEnv
              pkgs.mafft
              pkgs.iqtree
              pkgs.figtree
              pkgs.genoflu
              pkgs.blast # genoflu.py shells out to blastn/makeblastdb, so adding it in manually
              pkgs.phylommand

              # pinning base utilities so it doesn't panic if host doesn't have em
              pkgs.ncurses
              pkgs.coreutils
              pkgs.diffutils
              pkgs.gnused
              pkgs.gnugrep
            ];

            shellHook = ''
              echo "farrago dev shell"
              echo "  aligners/trees : mafft, iqtree3, treetime"
              echo "  fasta/tree cli : smof, smot"
              echo "  taxon sampling : parnas (parnas server for the web UI)"
              echo "  tree viewer    : figtree (GUI; -graphic PDF/SVG/PNG for batch export)"
              echo "  genotyping     : genoflu.py, blastn"
              echo "  phylommand     : treebender, treeator, contree, pairalign"
              echo "  python         : pandas, biopython, dendropy, ete4, cluster_affinity, pillow, yaml"
            '';
          };
        }
      );
    };
}
