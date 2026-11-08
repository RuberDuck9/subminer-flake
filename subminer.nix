{ fetchFromGitHub, appimageTools, lib }: 

let
  pname = "subminer";
  version = "0.22.0";

  src = fetchFromGitHub {
    owner = "kyasuda";
    repo = "SubMiner";
    rev = "v0.22.0";
    sha256 = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -D -m444 ${appimageContents}/subminer.desktop -t $out/share/applications/
    substituteInPlace $out/share/applications/subminer.desktop --replace-exec "AppRun" "${pname}"

    if [ -d "${appimageContents}/usr/share/icons" ]; then
      cp -r ${appimageContents}/usr/share/icons $out/share/
    fi
  '';

  meta = with lib; {
    description = "Integrates Yomitan with MPV - featuring one click Anki mining, realtime subtitle annotations, and immersion tracking. No browser or texthooker required";
    homepage = "https://github.com/ksyasuda/SubMiner";
    licnese = license.gpl3Only;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
    mainProgram = "subminer";
  };
}

