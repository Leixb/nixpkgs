{ lib, rel, buildKodiBinaryAddon, fetchFromGitHub }:
buildKodiBinaryAddon rec {
  pname = "pvr-hts";
  namespace = "pvr.hts";
  version = "20.6.0";

  src = fetchFromGitHub {
    owner = "kodi-pvr";
    repo = "pvr.hts";
    rev = "${version}-${rel}";
    sha256 = "sha256-D6t61/KUEQBMw5WrCfiWyFHnGbnpHWVKzzdgiRpviig=";
  };

  meta = with lib; {
    homepage = "https://github.com/kodi-pvr/pvr.hts";
    description = "Kodi's Tvheadend HTSP client addon";
    platforms = platforms.all;
    license = licenses.gpl2Only;
    maintainers = teams.kodi.members;
  };
}
