{
  description = ''
    LaTeX Beamer Demo

    Based on https://ubikium.gitlab.io/portfolio/2019-11-30-maintainable-markdown-beamer.html

  '';
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
    flake-utils.url = github:numtide/flake-utils;
  };
  outputs = { self, nixpkgs, flake-utils }:
  flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs {inherit system;};
    tex = pkgs.texlive.combine {
      inherit (pkgs.texlive)
      scheme-basic
      xetex
      beamer beamertheme-metropolis
      pgfopts fira xkeyval fontaxes fancyvrb
      xecjk ctex unicode-math ipaex; # Japanese
    };
    # fix from https://github.com/NixOS/nixpkgs/issues/10008
    fontsConf = pkgs.makeFontsConf {
      fontDirectories = [
        "${tex}/share/texmf/"
      ];
    };
    src = {
      header = ./header.tex;
      config = ./default.yaml;
      slides = ./slides.md;
    };
  in rec {
    packages = {
      slides = pkgs.runCommand "latex-beamer-demo" {
        buildInputs = [ pkgs.coreutils tex pkgs.pandoc ];
        FONTCONFIG_FILE = fontsConf;
      } ''
        mkdir $out
        ${pkgs.pandoc}/bin/pandoc --pdf-engine=xelatex -t beamer \
          -H ${src.header} ${src.config} ${src.slides} \
          -o $out/${packages.slides.name}.pdf
      '';
    };
    defaultPackage = packages.slides;
  });
}
