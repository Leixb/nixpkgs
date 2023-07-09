
{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, numpy
, versioneer
, portalocker
, amulet-leveldb
, pymctranslate
, minecraft-model-reader
, cython
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "amulet-core";
  version = "1.9.14";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "Amulet-Team";
    repo = "Amulet-Core";
    rev = version;
    sha256 = "sha256-919+WpgAGkqNsF4VvAPXzFfWjLl5tAzX5cHnR+MHd5E=";
  };

  patches = [ ./leveldb.patch ];

  # postPatch = ''
  #   substituteInPlace pytest.ini \
  #     --replace "--cov=kneed" ""
  # '';

  nativeBuildInputs = [
    setuptools
    cython
  ];

  propagatedBuildInputs = [
    portalocker
    numpy
    versioneer
    pymctranslate
    amulet-leveldb
    minecraft-model-reader
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
