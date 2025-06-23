{pkgs}:
pkgs.writeShellApplication {
  name = "dv";
  runtimeInputs = [
    pkgs.ffmpeg
    pkgs.coreutils
  ];

  text = builtins.readFile ./dv.sh;
}
