# LaTeX beamer with `nix flake`!

This is an update to [my previous blog post](https://ubikium.gitlab.io/portfolio/2019-11-30-maintainable-markdown-beamer.html) which talks about how to combine `nix`, `pandoc`, and `beamer` to easily write slides.

This is an update with `nix flake` and Japanese (or in general CJK) support.

## Usage

- Clone the repository and remove `.git`.
- Change the file name in `flake.nix`.
- Change [`pandoc` options](https://pandoc.org/MANUAL.html#variables) in `default.yaml`.
- Add LaTeX header in `header.tex`.
- Add contents in `slides.md`.
- `nix build`

The result document will be in `./result`.

