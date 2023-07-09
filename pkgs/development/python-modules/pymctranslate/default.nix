{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, versioneer
, numpy
, cython
, amulet-nbt
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "PyMCTranslate";
  version = "1.2.11";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "gentlegiantJGC";
    repo = "PyMCTranslate";
    rev = version;
    sha256 = "sha256-sfhtkZqG2lOKZ9RIvvlQqqjPjz/nRSwmvkfn/jAYNNw=";
  };

  # postPatch = ''
  #   substituteInPlace pytest.ini \
  #     --replace "--cov=kneed" ""
  # '';

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    versioneer
    amulet-nbt
    numpy
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
    description = "Translation system for Minecraft blocks, block entities, entities and items";
    homepage = "https://www.amuletmc.com/";
    # license = ;
    maintainers = with maintainers; [ leixb ];
  };
}
