
{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, numpy
, versioneer
, cython
, mutf8
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "amulet-nbt";
  version = "2.1.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "Amulet-Team";
    repo = "Amulet-NBT";
    rev = version;
    sha256 = "sha256-oVJeXrZt95JQGzwSuhWOKqo8c5DY0BFi3iZ5K9Gm1kM=";
  };

  # postPatch = ''
  #   substituteInPlace pytest.ini \
  #     --replace "--cov=kneed" ""
  # '';

  nativeBuildInputs = [
    setuptools
    cython
  ];

  propagatedBuildInputs = [
    numpy
    versioneer
    mutf8
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
