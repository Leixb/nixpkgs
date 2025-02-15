{ curl
, dbus
, fetchFromGitHub
, fetchpatch
, glib
, json-glib
, lib
, nix-update-script
, openssl
, pkg-config
, stdenv
, meson
, ninja
, util-linux
, libnl
, systemd
}:

stdenv.mkDerivation rec {
  pname = "rauc";
  version = "1.9";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-VpHcJUTRZ5aJyfYypjVsYyRNrK0+9ci42mmlZQSkWAk=";
  };

  patches = [
    (fetchpatch {
      # Patch to install the man page when using meson, remove on package bump
      url = "https://github.com/rauc/rauc/commit/756c677d031c435070a6900e6778d06961822261.patch";
      hash = "sha256-QgIUagioRo61PeC0JyKjZtnauFiYP1Fz9wrxGEikBGI=";
    })
  ];
  passthru = {
    updateScript = nix-update-script { };
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [ pkg-config meson ninja ];

  buildInputs = [ curl dbus glib json-glib openssl util-linux libnl systemd ];

  mesonFlags = [
    "--buildtype=release"
    (lib.mesonOption "systemdunitdir" "${placeholder "out"}/lib/systemd/system")
    (lib.mesonOption "dbusinterfacesdir" "${placeholder "out"}/share/dbus-1/interfaces")
    (lib.mesonOption "dbuspolicydir" "${placeholder "out"}/share/dbus-1/system.d")
    (lib.mesonOption "dbussystemservicedir" "${placeholder "out"}/share/dbus-1/system-services")
  ];

  meta = with lib; {
    description = "Safe and secure software updates for embedded Linux";
    homepage = "https://rauc.io";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ emantor ];
    platforms = with platforms; linux;
  };
}
