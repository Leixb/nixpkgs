{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  boost,
  gtest,
  ocl-icd,
  opencl-headers,
  opencl-clhpp,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "clsparse";
  version = "0.10.2.0";

  src = fetchFromGitHub {
    owner = "clMathLibraries";
    repo = "clSPARSE";
    rev = "v${version}";
    hash = "sha256-jIauCtUyPEIx7pFI3qH0WagV+t/fvro0OsGgONBJm0s=";
  };

  patches = [
    ./pass_include_dir.patch
    ./install_target.patch
    (fetchpatch {
      name = "remove-gettypecode.patch";
      url = "https://patch-diff.githubusercontent.com/raw/clMathLibraries/clSPARSE/pull/210.patch";
      hash = "sha256-9Q+tk7RMdWE4MCnbvWlsI0MIgBYKIWR2jIC1bICtIjU=";
    })
  ];

  postInstallPhase = ''
    mv $installDir/lib64 lib
    ln -s lib/ lib64
  '';

  env.NIX_CFLAGS_COMPILE = "-std=c++17";

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    boost
    ocl-icd
    opencl-headers
    opencl-clhpp
  ];

  cmakeFlags = [
    "-DBUILD_Boost=OFF"
    "-DBUILD_gMock=OFF"
    "-DBUILD_MTX=OFF"
    "-DBUILD_SAMPLES=OFF"
    "-DUSE_SYSTEM_CL2HPP=ON"
    "-DGMOCK_ROOT=${gtest}"
    "-DGTEST_INCLUDE_DIR=${gtest.src}/googletest/include"
  ];

  meta = {
    description = "A software library containing Sparse functions written in OpenCL";
    homepage = "https://github.com/clMathLibraries/clSPARSE";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ leixb ];
    platforms = lib.platforms.all;
  };
}
