{ lib
, buildPythonPackage
, fetchFromGitHub
, setuptools
, numpy
, versioneer
, amulet-nbt
, pillow
, cython
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "minecraft-resource-pack";
  version = "1.3.3";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "gentlegiantJGC";
    repo = "Minecraft-Model-Reader";
    rev = version;
    sha256 = "sha256-CpspDffxcSuZ5YyYqjKx5+XDa5i9EmIHPpZLyZkbJdk=";
  };

  patches = [
    # Remove coverage
    ./resource_path_xdg_data.patch
  ];

  # postPatch = ''
  #   substituteInPlace pytest.ini \
  #     --replace "--cov=kneed" ""
  # '';

  nativeBuildInputs = [
    setuptools
    cython
  ];

  propagatedBuildInputs = [
    amulet-nbt
    pillow
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
