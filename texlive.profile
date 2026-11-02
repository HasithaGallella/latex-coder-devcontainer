# install-tl profile: only the TeX Live infrastructure; the Dockerfile adds packages.txt.
selected_scheme scheme-infraonly
TEXDIR /usr/local/texlive
TEXMFLOCAL /usr/local/texlive/texmf-local
TEXMFSYSCONFIG /usr/local/texlive/texmf-config
TEXMFSYSVAR /usr/local/texlive/texmf-var
TEXMFCONFIG ~/.texlive/texmf-config
TEXMFVAR ~/.texlive/texmf-var
TEXMFHOME ~/texmf
instopt_adjustpath 0
instopt_adjustrepo 1
instopt_letter 0
instopt_portable 0
instopt_write18_restricted 1
tlpdbopt_autobackup 0
tlpdbopt_install_docfiles 0
tlpdbopt_install_srcfiles 0
tlpdbopt_sys_bin /usr/local/bin
