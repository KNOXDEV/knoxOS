{pkgs}:
pkgs.writeShellApplication {
  name = "fftrim";
  runtimeInputs = [
    pkgs.ffmpeg
  ];

  text = builtins.readFile ./fftrim.sh;
}
