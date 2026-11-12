{ pkgs, lib, fetchurl, appimageTools, symlinkJoin, writeShellScriptBin }: 

let
  version = "0.22.0";

  src = fetchurl {
    url = "https://github.com/ksyasuda/SubMiner/releases/download/v${version}/SubMiner.AppImage";
    sha256 = "nZ6aT6nirUwlEW5rOLoxxDAx9jH5/0slIZTRsawOkwE=";
  };

  appimageContents = appimageTools.extractType2 { pname = "subminer"; inherit version src; };

  runtimeDeps = with pkgs; [
    coreutils mpv ffmpeg mecab yt-dlp xz python314Packages.guessit 
    ffsubsync fzf rofi chafa ffmpegthumbnailer whisper-cpp
  ];

  app = appimageTools.wrapType2 {
    pname = "subminer-app";
    inherit version src;

    extraPkgs = _: runtimeDeps;

    extraInstallCommands = ''
      desktopFile=$(find ${appimageContents} -name "*.desktop" | head -n 1)
      if [ -n "$desktopFile" ]; then
        mkdir -p $out/share/applications
        install -D -m444 "$desktopFile" $out/share/applications/subminer.desktop
        substituteInPlace $out/share/applications/subminer.desktop --replace-quiet "AppRun" "subminer-app"
      fi

      if [ -d "${appimageContents}/usr/share/icons" ]; then
        cp -r ${appimageContents}/usr/share/icons $out/share/
      fi
    '';

  };

  launcher = writeShellScriptBin "subminer" ''
    export PATH=${lib.makeBinPath runtimeDeps}:$PATH
    export SUBMINER_BINARY_PATH=${app}/bin/subminer-app
    export SUBMINER_MANAGED_LAUNCHER=1
    export SUBMINER_LAUNCHER_PATH="$0"
    exec ${pkgs.bun}/bin/bun ${appimageContents}/resources/launcher/subminer.js "$@"
  '';
in
symlinkJoin {
  name = "subminer-${version}";
  paths = [ launcher app ];

  meta = with lib; {
    description = "Integrates Yomitan with MPV - featuring one click Anki mining, realtime subtitle annotations, and immersion tracking. No browser or texthooker required";
    homepage = "https://github.com/ksyasuda/SubMiner";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
    mainProgram = "subminer";
  };
}
