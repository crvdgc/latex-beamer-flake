# Markdown to LaTeX Beamer Slides via `nix flake` & `pandoc`

Write Markdown, then generate beautiful and feature-rich slide shows, all in one command.

Too good to be true?
See the [demo](https://github.com/crvdgc/latex-beamer-flake/releases/download/v0.1.0/latex-beamer-demo.pdf).

![Screenshot from the demo](https://ubikium.gitlab.io/images/beamer-slide.jpg)

## Pre-requisite

We need a flake-enabled `nix`.

For non-NixOS users:

- Install `nix` from [nixos.org](https://nixos.org/download.html).
- Enable the [flake feature](https://nixos.wiki/wiki/Flakes)
  - `mkdir -p ~/.config/nix`
  - `echo 'experimental-features = nix-command flakes' > ~/.config/nix/nix.conf`

For NixOS users: refer to [the wiki](https://nixos.wiki/wiki/Flakes#NixOS).

## Usage

- Initialize the git repository
    - `git clone https://github.com/crvdgc/latex-beamer-flake.git`
    - `cd latex-beamer-flake`
    - **USE WITH CAUTION**: `rm -rf .git`
    - `git init`
- Configure (optional)
    - Modify the file name in `flake.nix`.
    - Modify [`pandoc` options](https://pandoc.org/MANUAL.html#variables) in `default.yaml`.
    - Modify LaTeX header in `header.tex`.
- Add contents
    - Write slides in `slides.md`.
    - Put assets in `assets`
- Build
    - `git add .`
    - `nix build`

The result document will be in `./result`.

## Trouble-shooting

### LaTeX missing `.sty` files and other errors

This is usually caused by missing packages.
It can happen when you add more packages or use new features not listed in the example.

In such case, you need to modify the `tex` variable in `flake.nix` and put the correct package names there, which can often be discovered by hunting down the name of the missing file.

Of course, if you don't mind the storage space and build time, you can always use a larger pre-defined scheme.
For example `tex = pkgs.texlive.combined.scheme-full;`.
All pre-defined schemes are available in [this wiki page](https://nixos.wiki/wiki/TexLive).

For a more granular approach, you can replace `scheme-basic` with a scheme from above and then add missing packages.

### Asset files not found

`nix build` needs all files to be accessible from git.
Untracked files will not be found.

A simple `git add .` (no need for `commit`) will do the trick.

## Method

For curious souls who want the know-hows and aspirational hackers who want to tweak, here is how it works.

The basic process is that [Pandoc](https://pandoc.org) converts Markdown into LaTeX, then in turns into a slide show PDF with Beamer.
It is the same as described in [a previous post](https://ubikium.gitlab.io/portfolio/maintainable-markdown-beamer.html).
The main point is that we want to separate configuration with the actual content, so that it will more maintainable.

The main improvement in this post is the use of `flake` to simplify the process.

In the [`flake.nix`](https://github.com/crvdgc/latex-beamer-flake/blob/master/flake.nix) file, we generate a custom texlive package set by selecting the packages we need:

```nix
tex = pkgs.texlive.combine {
  inherit (pkgs.texlive)
  scheme-basic
  xetex
  beamer beamertheme-metropolis
  pgfopts fira xkeyval fontaxes fancyvrb
  booktabs caption # table
  xecjk ctex unicode-math ipaex; # Japanese
};
```

Then the target package is defined as

```nix
slides = pkgs.runCommand "latex-beamer-demo" {
  buildInputs = [ pkgs.coreutils tex pkgs.pandoc ];
  FONTCONFIG_FILE = fontsConf;
  src = ./.;
} ''
  cp -r $src/* ./
  mkdir $out
  ${pkgs.pandoc}/bin/pandoc \
    --pdf-engine=xelatex \
    -t beamer \
    -H header.tex default.yaml slides.md \
    -o $out/${packages.slides.name}.pdf
'';
```

The `src` environment variable refers to a path `./.`, which will cause the content to be copied into `/nix/store`.
In the build script, the `$src` refers to the resolved path and we copy the files to the build directory.

Finally, a call to `pandoc` will actually do the conversion.

Also see [my blog post](https://ubikium.gitlab.io/portfolio/latex-beamer-flake.html). This is only possible thanks to the following posts:

- [Exploring Nix Flakes: Build LaTeX Documents Reproducibly](https://flyx.org/nix-flakes-latex/) by [flyx](https://flyx.org).
- [Easy Markdown to Beamer with Pandoc and Nix](https://qiita.com/kimagure/items/9d27015e12d4f22b53db) by [kimagure](https://qiita.com/kimagure).
- [Boilerplating Pandoc for Academic Writing](https://www.soimort.org/notes/161117/) by Mort Yao.

