# OxCaml prebuilt devcontainer proof

This proof points Codespaces at a prebuilt image instead of compiling OxCaml
while the codespace starts.

After the image workflow publishes a tag, update `devcontainer.json` from the
temporary `proof` tag to the verified release or proof tag:

```json
{
  "image": "ghcr.io/cezarc1/oxcaml-dev:<verified-tag>"
}
```

The expected first-start path is:

```sh
ocamlopt -version
opam switch show
dune --version
```

Those commands should work immediately after the container starts. They should
not trigger a compiler build.
