# LaTeX Coder container: pdfLaTeX and BibTeX for conference papers, CVs and proposals,
# on Debian slim. Used for compiling and as a dev container image.
#
#   docker build -t latex-coder:basic .
#
# These build files are MIT-licensed (LICENSE). The image also contains Debian and TeX Live,
# which keep their own licences.

ARG DEBIAN_IMAGE=debian:trixie-slim

# Stage 1: install TeX Live, with the tools it takes to download and verify it.
FROM ${DEBIAN_IMAGE} AS texlive
ARG TEXLIVE_MIRROR=https://mirror.ctan.org/systems/texlive/tlnet
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl gnupg perl \
 && rm -rf /var/lib/apt/lists/*
COPY texlive.profile packages.txt /tmp/
# install-tl verifies the package database signature when gpg is available.
RUN set -eux; \
    mkdir /tmp/install-tl; \
    # mirror.ctan.org sends each request to a random nearby mirror, and now and then one has a
    # broken HTTPS setup. Ask again until one works, then use that mirror for the whole install.
    url=; \
    for attempt in 1 2 3 4 5; do \
      url="$(curl -fsSL -o /tmp/install-tl-unx.tar.gz -w '%{url_effective}' "${TEXLIVE_MIRROR}/install-tl-unx.tar.gz")" && break; \
      echo "Mirror failed (attempt $attempt), asking for another"; url=; sleep 5; \
    done; \
    [ -n "$url" ]; \
    repo="${url%/install-tl-unx.tar.gz}"; \
    echo "Using $repo"; \
    tar -xzf /tmp/install-tl-unx.tar.gz -C /tmp/install-tl --strip-components=1; \
    /tmp/install-tl/install-tl -profile /tmp/texlive.profile -repository "$repo"; \
    export PATH="$(echo /usr/local/texlive/bin/*):${PATH}"; \
    tlmgr option repository "$repo"; \
    # --no-depends keeps out LuaTeX, Latin Modern and other things pdfLaTeX never uses.
    # tlmgr then exits non-zero because it cannot build the LuaLaTeX formats, and it
    # exits zero when a download fails, so its status is ignored and checked below.
    grep -v '^#' /tmp/packages.txt | grep . | sort -u > /tmp/wanted; \
    tlmgr install --no-depends $(cat /tmp/wanted) || true; \
    # A download can fail or arrive damaged from one mirror; retry what is missing before giving up.
    for attempt in 1 2 3; do \
      tlmgr info --only-installed --data name | sort > /tmp/installed; \
      missing="$(comm -23 /tmp/wanted /tmp/installed)"; \
      [ -z "$missing" ] && break; \
      echo "Retrying ($attempt): $missing"; \
      tlmgr install --no-depends $missing || true; \
    done; \
    tlmgr info --only-installed --data name | sort > /tmp/installed; \
    missing="$(comm -23 /tmp/wanted /tmp/installed)"; \
    if [ -n "$missing" ]; then echo "Not installed: $missing" >&2; exit 1; fi; \
    fmtutil-sys --byfmt pdflatex; \
    kpsewhich -engine=pdftex pdflatex.fmt; \
    # Later tlmgr runs in the image pick a mirror the usual way.
    tlmgr option repository "${TEXLIVE_MIRROR}"; \
    # pdfLaTeX never reads AFM metrics or OpenType fonts; METAFONT sources are useless without METAFONT.
    rm -rf /usr/local/texlive/texmf-dist/fonts/afm /usr/local/texlive/texmf-dist/fonts/opentype \
           /usr/local/texlive/texmf-dist/fonts/source \
           /usr/local/texlive/tlpkg/backups /usr/local/texlive/tlpkg/texlive.tlpdb.main \
           /usr/local/texlive/install-tl.log /usr/local/texlive/texmf-var/web2c/*/*.log; \
    mktexlsr

# Stage 2: the runtime image. Perl is for latexmk and tlmgr. curl, its certificates and gpg let
# tlmgr download packages and check their signatures in LaTeX Coder's package terminal; the
# containers that compile have no network.
FROM ${DEBIAN_IMAGE}
ARG USERNAME=vscode
ARG USER_UID=1000
LABEL org.opencontainers.image.title="LaTeX Coder" \
      org.opencontainers.image.source="https://github.com/HasithaGallella/latex-coder-devcontainer" \
      org.opencontainers.image.description="pdfLaTeX for conference papers, for the LaTeX Coder VS Code extension"
RUN apt-get update \
 && apt-get install -y --no-install-recommends perl ca-certificates curl gpg \
 && rm -rf /var/lib/apt/lists/* \
 && useradd --create-home --uid "${USER_UID}" --shell /bin/bash "${USERNAME}"
COPY --from=texlive /usr/local/texlive /usr/local/texlive
RUN ln -s /usr/local/texlive/bin/*/* /usr/local/bin/
# Keep TeX log lines unwrapped so file paths stay intact for the error parser.
ENV max_print_line=10000 error_line=254 half_error_line=238
# The MIT licence of these build files; TeX Live's are in /usr/local/texlive.
COPY LICENSE /usr/share/doc/latex-coder/LICENSE
USER ${USERNAME}
WORKDIR /workspace
CMD ["sleep", "infinity"]
