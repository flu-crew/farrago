# farrago

Phylogenetics scripts for flu-crew analyses.

## Install Nix

One line on Linux, macOS and WSL2 (I think this is the fastest way to get going. I don't know how reliable it is on macOS and WSL2, but I expect it to work fine...):

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Flakes are enabled by default with this installer. For NixOS... do you have to ask?

## Enter the dev shell

```bash
git clone https://github.com/flu-crew/farrago
cd farrago
nix develop
```

The first run builds the toolchain and takes a while; after that it comes from the local store and is quick. Inside the shell you get:
| | |
|---|---|
| aligners / trees | `mafft`, `iqtree3`, `treetime` |
| fasta / tree CLI | `smof`, `smot` |
| taxon sampling | `parnas` (`parnas server` for the web UI) |
| tree viewer | `figtree` (GUI; `-graphic PDF/SVG/PNG` for batch export) |
| genotyping | `genoflu.py`, `blastn` |
| phylommand | `treebender`, `treeator`, `contree`, `pairalign` |
| python | pandas, biopython, dendropy, ete4, cluster_affinity, pillow, yaml |

The scripts under `workflow_scripts/`, `tree_scripts/`, `fasta_scripts/`, `seq_assembly_scripts/` and `misc/` are meant to be run from this shell. I included `pillow` and `yaml` for offlu scripts.

## Run one tool without entering the shell

```bash
nix run .#figtree
nix run .#smot -- --help
```

Works for `figtree`, `genoflu`, `phylommand` (runs `treebender`), `smof`, `smot`, `ete4`, `parnas` and `treetime`.

`cluster-affinity` ships `cluster_affinity`, `cluster_matrix` and `cluster_support` but declares no default program, so `nix run` cannot pick one. I you'll have to build it and use the built executable:

```bash
nix build .#cluster-affinity && ./result/bin/cluster_affinity --help
```

## Use it from another machine

No clone needed:

```bash
nix develop github:flu-crew/farrago/farrago-flake   # drop the branch once this is on main
```

`overlays.default` is exported too, so another flake can pull in the hand-rolled derivations (`figtree`, `genoflu`, `phylommand`, and the Python packages that are not in nixpkgs) by adding this repo as an input.

## Platform support

Its been tested on Linux and WSL2, and Apple Silicon (`aarch64-darwin`) is wired up and evaluates cleanly, but nothing has been built or run there yet (someone with MacOS please test it!). `iqtree3` in particular is only available because the flake lifts the linux-only marking nixpkgs puts on it, so treat a Mac as unverified. Intel Macs (`x86_64-darwin`) are not supported: nixos-unstable dropped that platform in 26.11.

## Updating the pinned versions

```bash
nix flake update
```

This moves `flake.lock` to a newer nixpkgs and changes tool versions for everyone, so commit it deliberately rather than as a drive-by.
