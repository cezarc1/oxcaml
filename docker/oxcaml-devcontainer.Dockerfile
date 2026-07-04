# syntax=docker/dockerfile:1.7

ARG OCAML_BASE_IMAGE=ocaml/opam:debian-12-ocaml-5.4
ARG DEBIAN_FRONTEND=noninteractive

FROM ${OCAML_BASE_IMAGE} AS build

ARG DEBIAN_FRONTEND
ARG BUILD_JOBS=4
ARG OXCAML_SWITCH=oxcaml-dev
ARG OXCAML_COMPILER_VERSION=5.4.0+oxcaml
ARG OCAML_VERSION=5.4.0

USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    autoconf \
    build-essential \
    ca-certificates \
    git \
    m4 \
    parallel \
    pkg-config \
    rsync \
    zlib1g-dev \
 && rm -rf /var/lib/apt/lists/*

USER opam
WORKDIR /home/opam/oxcaml-src
COPY --chown=opam:opam . .

RUN set -eux; \
    boot_switch="$(opam switch show)"; \
    opam update --yes; \
    opam switch create "${OXCAML_SWITCH}" --empty \
      --repositories="local=file:///home/opam/oxcaml-src/tools/ci/local-opam,default"; \
    opam switch set "${boot_switch}"; \
    eval "$(opam env --switch="${boot_switch}")"; \
    opam pin add -ny oxcaml-dev .; \
    opam install --yes --deps-only oxcaml-dev; \
    switch_prefix="$(opam var --switch="${OXCAML_SWITCH}" prefix)"; \
    autoconf; \
    ./configure --prefix="${switch_prefix}"; \
    make -j"${BUILD_JOBS}" _install; \
    eval "$(opam env --switch="${OXCAML_SWITCH}")"; \
    opam install --yes --switch "${OXCAML_SWITCH}" --fake "ocaml-base-compiler.${OXCAML_COMPILER_VERSION}"; \
    make install_for_opam; \
    opam install --yes --switch "${OXCAML_SWITCH}" "ocaml.${OCAML_VERSION}"; \
    opam install --yes --switch "${OXCAML_SWITCH}" \
      dune menhir.20231231 ocamlformat.0.29.0 merlin ocaml-lsp-server utop; \
    opam switch set "${OXCAML_SWITCH}"; \
    opam switch remove --yes "${boot_switch}"; \
    opam clean --yes --all; \
    rm -rf /home/opam/oxcaml-src

FROM ${OCAML_BASE_IMAGE}

ARG DEBIAN_FRONTEND
ARG OXCAML_SWITCH=oxcaml-dev
ARG OCI_SOURCE=https://github.com/oxcaml/oxcaml
ARG OCI_DESCRIPTION="Prebuilt OxCaml development container proof"

LABEL org.opencontainers.image.source="${OCI_SOURCE}" \
      org.opencontainers.image.description="${OCI_DESCRIPTION}" \
      org.opencontainers.image.licenses="LGPL-2.1-or-later WITH OCaml-LGPL-linking-exception"

USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    less \
    sudo \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /home/opam/.opam \
 && echo "opam ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/opam \
 && chmod 0440 /etc/sudoers.d/opam

COPY --from=build --chown=opam:opam /home/opam/.opam /home/opam/.opam

USER opam
WORKDIR /workspace

ENV OPAM_SWITCH_PREFIX=/home/opam/.opam/oxcaml-dev
ENV CAML_LD_LIBRARY_PATH=/home/opam/.opam/oxcaml-dev/lib/stublibs:/home/opam/.opam/oxcaml-dev/lib/ocaml/stublibs:/home/opam/.opam/oxcaml-dev/lib/ocaml
ENV OCAML_TOPLEVEL_PATH=/home/opam/.opam/oxcaml-dev/lib/toplevel
ENV OCAMLTOP_INCLUDE_PATH=/home/opam/.opam/oxcaml-dev/lib/toplevel
ENV PATH=/home/opam/.opam/oxcaml-dev/bin:${PATH}

RUN opam switch set "${OXCAML_SWITCH}" \
 && ocamlopt -version \
 && dune --version \
 && ocamllsp --version

CMD ["/bin/bash"]
