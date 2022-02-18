{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, cmake
, yasm
, nasm
, zip
, pkg-config
, clang
, gtk3
, xdotool
, libxcb
, libXfixes
, alsa-lib
, pulseaudio
, libXtst
, libvpx
, libyuv
, libopus
, libsciter-gtk
, llvmPackages
}:

rustPlatform.buildRustPackage rec {
  pname = "rustdesk";
  version = "1.1.8";

  src = fetchFromGitHub {
    owner = pname;
    repo = pname;
    rev = "0325500ebf331b66220cec6e9078afb83b0e98a7";
    sha256 = "sha256-xglyyoiAjJx3y8+A2OYHZffjqjDkcTjIluPA/J42VVg=";
  };

  cargoSha256 = "sha256-4MQKa54f3X7IHGd29H6RY7v2toeHvTHInIpgXjdotjw=";

  LIBCLANG_PATH="${llvmPackages.libclang.lib}/lib";

  # Change magnus-opus version to upstream so that it does not use
  # vcpkg for libopus since it does not work.
  cargoPatches = [
    ./cargo.patch
  ];

  # Manually simulate a vcpkg installation so that it can link the libaries
  # properly.
  VCPKG_ROOT = "/build/source/vcpkg";
  postUnpack = let
    target_arch = if stdenv.isx86_64 then "x64"
      else if stdenv.isx86_32 then "x32"
      else throw "Unsupported architecture";

    target_os = if stdenv.isLinux then "linux"
      else if stdenv.isDarwin then "osx"
      else throw "Unsupported system";

    vcpkg_target = "${target_arch}-${target_os}";
  in ''
    mkdir -p ${VCPKG_ROOT}/installed/${vcpkg_target}/lib

    ln -s ${libvpx.out}/lib/* ${VCPKG_ROOT}/installed/${vcpkg_target}/lib/
    ln -s ${libyuv.out}/lib/* ${VCPKG_ROOT}/installed/${vcpkg_target}/lib/
  '';

  nativeBuildInputs = [ pkg-config cmake yasm nasm clang ];
  buildInputs = [ alsa-lib pulseaudio libXfixes libxcb xdotool gtk3 libvpx libopus libXtst libyuv ];

  # Checks require an active X display.
  doCheck = false;

  # Add static ui resources and libsciter to same folder as binary so that it
  # can find them.
  postInstall = ''
    ln -s ${libsciter-gtk}/lib/libsciter-gtk.so $out/bin/

    mkdir -p $out/share/src
    cp -a $src/src/ui $out/share/src

    mv $out/bin/rustdesk{,-unwrapped}
    install -Dm0777 /dev/stdin $out/bin/rustdesk << EOF
    #!/usr/bin/env bash
    cd $out/share
    exec $out/bin/rustdesk-unwrapped "\$@"
    EOF

    install -Dm0644 $src/logo.svg $out/share/icons/hicolor/scalable/apps/rustdesk.svg

    install -Dm0644 /dev/stdin "$out/share/applications/rustdesk.desktop"  << EOF
    [Desktop Entry]
    Version=${version}
    Name=RustDesk
    GenericName=Remote Desktop
    GenericName[zh_CN]=远程桌面
    Comment=Remote Desktop
    Comment[zh_CN]=远程桌面
    Exec=$out/bin/rustdesk %u
    Icon=rustdesk.svg
    Terminal=false
    Type=Application
    MimeType=text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;text/mml;x-scheme-handler/http;x-scheme-handler/https;
    StartupNotify=true
    Categories=Other;
    Keywords=internet;
    Actions=new-window;

    X-Desktop-File-Install-Version=0.23

    [Desktop Action new-window]
    Name=Open a New Window
    EOF
  '';

  meta = with lib; {
    description = "Yet another remote desktop software";
    homepage = "https://rustdesk.com";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ leixb ];
    platforms = platforms.unix;
    mainProgram = "rustdesk";
  };
}
