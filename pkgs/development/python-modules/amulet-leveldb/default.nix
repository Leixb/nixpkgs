{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, cython
, zlib
, versioneer
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "amulet-leveldb";
  version = "1.0.0b5";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "Amulet-Team";
    repo = "Amulet-LevelDB";
    rev = version;
    fetchSubmodules = true;
    sha256 = "sha256-UBE15EhgFOi/olBMyQZOqXQB0PfKxrg4lfXezhssPTE=";
  };

  # postPatch = ''
  #   substituteInPlace pytest.ini \
  #     --replace "--cov=kneed" ""
  # '';

  nativeBuildInputs = [
    setuptools
    cython
  ];

  buildInputs = [
    zlib
  ];

  propagatedBuildInputs = [
    versioneer
  ];

  checkInputs = [
    pytestCheckHook
    # matplotlib
  ];

  doCheck = false;

  disabledTestPaths = [
    # Fails when matplotlib is installed
    # "tests/test_no_matplotlib.py"
  ];

  meta = with lib; {
    description = "The new age Minecraft world editor and converter that supports every version since Java 1.12 and Bedrock 1.7";
    homepage = "https://www.amuletmc.com/";
    # license = ;
    maintainers = with maintainers; [ leixb ];
  };
}
