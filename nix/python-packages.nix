{ lib }:

pyfinal: pyprev:

{
  # Only needed as a smot dependency.
  parsec = pyfinal.buildPythonPackage {
    pname = "parsec";
    version = "3.17";
    pyproject = true;

    src = pyfinal.fetchPypi {
      pname = "parsec";
      version = "3.17";
      hash = "sha256-l0jWSvQxhMLliHuI+fykUGXfK/AKGOQt8YXrsskq6lM=";
    };

    build-system = [ pyfinal.setuptools ];

    doCheck = false;
    pythonImportsCheck = [ "parsec" ];

    meta = {
      description = "Universal Python parser combinator library inspired by Haskell's Parsec";
      homepage = "https://github.com/sighingnow/parsec.py";
      license = lib.licenses.mit;
    };
  };

  # simple manipulation of fasta
  smof = pyfinal.buildPythonPackage {
    pname = "smof";
    version = "2.22.4";
    pyproject = true;

    src = pyfinal.fetchPypi {
      pname = "smof";
      version = "2.22.4";
      hash = "sha256-D1ln6nP9cDHwoPDjbDBUbRIJCgw1SY152/OmwZo71xc=";
    };

    build-system = [ pyfinal.setuptools ];

    doCheck = false;
    pythonImportsCheck = [ "smof" ];

    meta = {
      description = "UNIX-style utilities for FASTA file exploration";
      homepage = "https://github.com/incertae-sedis/smof";
      license = lib.licenses.mit;
      mainProgram = "smof";
    };
  };

  # simple manipulation of trees
  smot = pyfinal.buildPythonPackage {
    pname = "smot";
    version = "1.1.0";
    pyproject = true;

    src = pyfinal.fetchPypi {
      pname = "smot";
      version = "1.1.0";
      hash = "sha256-KV4oMmFwWDdxvqGxr9E6h9WewaDg7TCE1IP08/eRrJM=";
    };

    postPatch = ''
      printf 'parsec\nclick\n' > requirements.txt
    '';

    build-system = [ pyfinal.setuptools ];

    dependencies = [
      pyfinal.parsec
      pyfinal.click
    ];

    doCheck = false;
    pythonImportsCheck = [ "smot" ];

    meta = {
      description = "Simple manipulation of trees";
      homepage = "https://github.com/flu-crew/smot";
      license = lib.licenses.mit;
      mainProgram = "smot";
    };
  };

  ete4 = pyfinal.buildPythonPackage {
    pname = "ete4";
    version = "4.4.0";
    pyproject = true;

    src = pyfinal.fetchPypi {
      pname = "ete4";
      version = "4.4.0";
      hash = "sha256-AwarZsKhaFlG+UpJEnGKWBLfwwWQcDAPwl0OK4gbuNE=";
    };

    build-system = [
      pyfinal.setuptools
      pyfinal.cython
    ];

    dependencies = [
      pyfinal.bottle
      pyfinal.cheroot
      pyfinal.brotli
      pyfinal.numpy
      pyfinal.scipy
      pyfinal.requests
    ];

    doCheck = false;
    pythonImportsCheck = [ "ete4" ];

    meta = {
      description = "Python environment for phylogenetic tree exploration";
      homepage = "http://etetoolkit.org";
      license = lib.licenses.gpl3Plus;
      mainProgram = "ete4";
    };
  };

  # Imported by workflow_scripts/calc_tree_distances.py.
  cluster-affinity = pyfinal.buildPythonPackage {
    pname = "cluster-affinity";
    version = "0.7.4";
    pyproject = true;

    src = pyfinal.fetchPypi {
      pname = "cluster_affinity";
      version = "0.7.4";
      hash = "sha256-GtsrxzOoJbx6Ar11nI28hEVwv3uSPnLcL62DEcaUW6I=";
    };

    build-system = [ pyfinal.setuptools ];

    dependencies = [
      pyfinal.ete4
      pyfinal.matplotlib
      pyfinal.alive-progress
    ];

    doCheck = false;
    pythonImportsCheck = [ "cluster_affinity" ];

    meta = {
      description = "Calculate the cluster affinity distance between two trees";
      homepage = "https://github.com/swagle8987/cluster_affinity";
      license = lib.licenses.mit;
    };
  };

  # Provides the `treetime` binary that workflow_scripts/treetimeRuns.sh drives.
  phylo-treetime = pyfinal.buildPythonPackage {
    pname = "phylo-treetime";
    version = "0.12.1";
    pyproject = true;

    src = pyfinal.fetchPypi {
      # PyPI normalises the sdist filename to an underscore; the project name does not.
      pname = "phylo_treetime";
      version = "0.12.1";
      hash = "sha256-/eOAoxY+xE+bTMFu7VicuEdiHvGvM37agvJ3+6ZZNZU=";
    };

    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace-fail 'setuptools>=40.8.0,<70' 'setuptools>=40.8.0'
    '';

    build-system = [ pyfinal.setuptools ];

    dependencies = [
      pyfinal.biopython
      pyfinal.numpy
      pyfinal.pandas
      pyfinal.scipy
      pyfinal.matplotlib
    ];

    doCheck = false;
    pythonImportsCheck = [ "treetime" ];

    meta = {
      description = "Maximum-likelihood phylodynamic inference";
      homepage = "https://github.com/neherlab/treetime";
      license = lib.licenses.mit;
      mainProgram = "treetime";
    };
  };

  parnas = pyfinal.buildPythonPackage {
    pname = "parnas";
    version = "0.1.7-unstable-2026-07-02";
    pyproject = true;

    # The python set re-exports fetchPypi but not the git fetchers, hence pyfinal.pkgs.
    src = pyfinal.pkgs.fetchFromGitHub {
      owner = "flu-crew";
      repo = "parnas";
      rev = "16c2a858394f194c78f130cd6b16e532943f63a7";
      hash = "sha256-BLPttSj4SLng2g9VUQu95JWzqcms8kYCV4mGcf+2EK0=";
    };

    postPatch = ''
      substituteInPlace pyproject.toml \
        --replace-fail 'parnas = ["web/*.html"]' 'parnas = ["web/*.html", "web/js/*.js"]'
    '';

    build-system = [ pyfinal.setuptools ];

    dependencies = [
      pyfinal.numpy
      pyfinal.numba
      pyfinal.biopython
      pyfinal.dendropy
      pyfinal.phylo-treetime
      pyfinal.scipy
      pyfinal.flask

      pyfinal.levenshtein

      pyfinal.psutil
      pyfinal.requests
      pyfinal.matplotlib
    ];

    doCheck = false;
    pythonImportsCheck = [ "parnas" ];

    meta = {
      description = "Representative taxon sampling from phylogenetic trees";
      homepage = "https://github.com/flu-crew/parnas";
      license = lib.licenses.mit;
      mainProgram = "parnas";
    };
  };
}
