# LaTeX Coder Dev Container

TeX Live for pdfLaTeX and BibTeX on Debian slim, built for the LaTeX Coder VS Code extension
(`hasitha-gallella.latex-coder`). It compiles conference papers, CVs and proposals with nothing to
install on your machine but Docker.

```
ghcr.io/hasithagallella/latex-coder:basic
```

For Apple Silicon (`linux/arm64`) and Intel (`linux/amd64`); about 140 MB to download.

## What's inside

- Debian `trixie-slim`, the official minimal image.
- TeX Live, installed from CTAN with TeX Live's own installer: pdfLaTeX, BibTeX, `latexmk` and
  SyncTeX, plus the LaTeX packages in [`packages.txt`](packages.txt). No XeLaTeX or LuaLaTeX.
- Perl, for `latexmk`.
- A `vscode` user (UID 1000), with `/workspace` as the working folder.

It is built from scratch on Debian, not from another LaTeX image.

## Use it as a dev container

`.devcontainer/devcontainer.json` in your project:

```jsonc
{
  "name": "LaTeX Coder",
  "image": "ghcr.io/hasithagallella/latex-coder:basic",
  // The image has no git; this adds Debian's git when the container is created.
  "features": {
    "ghcr.io/devcontainers/features/git:1": { "version": "os-provided" }
  }
}
```

Then run **Dev Containers: Reopen in Container** in VS Code.

## Compile without VS Code

```
docker run --rm --network none -v "$PWD":/workspace ghcr.io/hasithagallella/latex-coder:basic \
  latexmk -pdf main.tex
```

## Build it yourself

```
docker build -t latex-coder:basic .
```

## Licence

The files in this repository are under the [MIT License](LICENSE). The image also contains Debian
and TeX Live, which keep their own licences; TeX Live's are in `/usr/local/texlive` inside the
image, and this repository's MIT licence is at `/usr/share/doc/latex-coder/LICENSE`.
