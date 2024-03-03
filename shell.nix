{ pkgs ? import <nixpkgs> {
    config.allowUnfree = true;
  }
}:

with pkgs;

pkgs.mkShell {
  buildInputs = [
    elixir_1_15
    erlang
    flyctl
    inotify-tools
  ];
}
