{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, numpy
, versioneer
, cython
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "amulet-map-editor";
  version = "0.10.11";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "Amulet-Team";
    repo = "Amulet-Map-Editor";
    rev = version;
    sha256 = "sha256-PSeOq4H6pcgBRqHKlOYvN4IqZhpsVqL/0zXjJyJNwnw=";
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
