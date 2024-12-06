# Determinate CI

The one-stop shop for effortless Nix CI in GitHub Actions.

- Automatically builds on all the architectures your flake supports.
- Built-in, free caching using [Magic Nix Cache][magic-nix-cache] and optionally [FlakeHub Cache][flakehub-cache].
- Discovers and builds your entire flake using [Flake Schemas][flake-schemas].
- Easily opt-in to publishing to [FlakeHub][flakehub].

**Status:** The Determinate CI workflow is an experiment.
It may change significantly without warning.
Please feel free to try it out, report bugs, and [let us know how it goes in our Discord][discord]!
Stabilization to follow.

## Usage

Create a workflow in your project at `.github/workflows/ci.yml`, and copy in this text:

```yaml
on:
  pull_request:
  workflow_dispatch:
  push:
    branches:
      - main
      - master
    tags:
      - "v?[0-9]+.[0-9]+.[0-9]+*"

concurrency:
  group: ${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
  cancel-in-progress: true

jobs:
  DeterminateCI:
    uses: DeterminateSystems/ci/.github/workflows/workflow.yml@main
    permissions:
      id-token: "write"
      contents: "read"
```

and you're done, you'll get something like this:

<img width="1140" alt="image" src="https://github.com/DeterminateSystems/ci/assets/76716/c2c6aa07-3fd3-4e66-9440-bef264b472da">

### Publishing to FlakeHub

Publish to FlakeHub on every push to the default branch, and every tag.
Specify the flake's visibility:

```yaml
on:
  pull_request:
  workflow_dispatch:
  push:
    branches:
      - main
      - master
    tags:
      - "v?[0-9]+.[0-9]+.[0-9]+*"

concurrency:
  group: ${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
  cancel-in-progress: true

jobs:
  DeterminateCI:
    uses: DeterminateSystems/ci/.github/workflows/workflow.yml@main
    permissions:
      id-token: "write"
      contents: "read"
    with:
      visibility: public
```

### Advanced Usage

#### Custom Runner Types

The default runner map uses `ubuntu-latest` for x86 Linux, and `macos-latest` for macOS.
Take advantage of [larger GitHub runners][runners] by providing a custom runner map:

```yaml
jobs:
  DeterminateCI:
    uses: DeterminateSystems/ci/.github/workflows/workflow.yml@main
    permissions:
      id-token: "write"
      contents: "read"
    with:
      runner-map: |
        {
          "aarch64-darwin": "macos-latest-xlarge",
          "aarch64-linux": "UbuntuLatest32Cores128GArm",
          "i686-linux": "UbuntuLatest32Cores128G",
          "x86_64-darwin": "macos-latest-xlarge",
          "x86_64-linux": "UbuntuLatest32Cores128G"
        }
```

#### SSH Private Keys

Configure an SSH agent with a secret private key for private repository support.

```yaml
jobs:
  DeterminateCI:
    uses: DeterminateSystems/ci/.github/workflows/workflow.yml@main
    permissions:
      id-token: "write"
      contents: "read"
    with:
      enable-ssh-agent: true
    secrets:
      ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}
```

## Notes

Use of this workflow uses a collection of GitHub Action by Determinate Systems, which are covered by the Determinate Systems [privacy policy][privacy policy] and [terms of service][tos].

[flake-schemas]: https://determinate.systems/posts/flake-schemas/
[magic-nix-cache]: https://github.com/determinateSystems/magic-nix-cache-action
[flakehub]: https://flakehub.com/
[runners]: https://docs.github.com/en/actions/using-github-hosted-runners/about-larger-runners
[discord]: https://determinate.systems/discord
[privacy policy]: https://determinate.systems/policies/privacy/
[tos]: https://determinate.systems/policies/terms-of-service/
[flakehub-cache]: https://determinate.systems/posts/flakehub-cache-beta/
