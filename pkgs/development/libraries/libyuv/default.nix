{ lib
, stdenv
, fetchgit
, cmake
}:

stdenv.mkDerivation rec {
  name = "libyuv";

  version = "1787";

  src = fetchgit {
    url = "https://chromium.googlesource.com/libyuv/libyuv.git";
    rev = "refs/heads/stable";
    sha256 = "sha256-DtRYoaAXb9ZD2OLiKbzKzH5vzuu+Lzu4eHaDgPB9hjU=";
  };

  patches = [ ./pkg-config.patch ];

  nativeBuildInputs = [
    cmake
  ];

  meta = with lib; {
    homepage = "https://chromium.googlesource.com/libyuv/libyuv";
    description = "Open source project that includes YUV scaling and conversion functionality";
    platforms = platforms.linux;
    maintainers = with maintainers; [ leixb ];
    license = licenses.bsd3;
  };
}
