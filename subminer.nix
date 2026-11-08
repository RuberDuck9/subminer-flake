{ fetchurl, appimageTools, lib }: 

let
  pname = "subminer";
  version = "0.22.0";

  src = fetchurl {
    url = "https://github.com/ksyasuda/SubMiner/releases/download/v${version}/SubMiner.AppImage";
    sha256 = "nZ6aT6nirUwlEW5rOLoxxDAx9jH5/0slIZTRsawOkwE=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    desktopFile=$(find ${appimageContents} -name "*.desktop" | head -n 1)
    if [ -n "$desktopFile" ]; then
      mkdir -p $out/share/applications
      install -D -m444 "$desktopFile" $out/share/applications/subminer.desktop
      substituteInPlace $out/share/applications/subminer.desktop --replace "AppRun" "${pname}"
    fi

    if [ -d "${appimageContents}/usr/share/icons" ]; then
      cp -r ${appimageContents}/usr/share/icons $out/share/
    fi
  '';

  meta = with lib; {
    description = "Integrates Yomitan with MPV - featuring one click Anki mining, realtime subtitle annotations, and immersion tracking. No browser or texthooker required";
    homepage = "https://github.com/ksyasuda/SubMiner";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
    mainProgram = "subminer";
  };
}

