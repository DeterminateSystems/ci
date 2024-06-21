# Determinate CI

The one-stop shop for effortless Nix CI in GitHub Actions.

- Automatically builds on all the architectures your flake supports.
- Built-in, free caching using [Magic Nix Cache][magic-nix-cache] and FlakeHub Cache.
- Discovers and builds your entire flake using [Flake Schemas][flake-schemas].
- Easily opt-in to publishing to [FlakeHub][flakehub].

## Usage

Create a workflow in your project at `.github/workflows/ci.yml`, and copy in this text:

```yaml
on:
  workflow_dispatch:
  push:
    branches:
      - main
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

and you're done!

### Publishing to FlakeHub

Publish to FlakeHub on every push to the default branch, and every tag.
Specify the flake owner, and visibility:

```yaml
jobs:
  DeterminateCI:
    uses: DeterminateSystems/ci/.github/workflows/workflow.yml@main
    permissions:
      id-token: "write"
      contents: "read"
    with:
      flake-owner: DeterminateSystems
      visibility: public
```

### Advanced Usage

#### Custom Runner Types

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
          "i686-linux": "UbuntuLatest32Cores128G"
          "x86_64-darwin": "macos-latest-xlarge",
          "x86_64-linux": "UbuntuLatest32Cores128G",
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

#### Publish with a Different Flake Name

Publish to FlakeHub using a different flake name by specifying the flake owner, flake name, and visibility:

```yaml
jobs:
  DeterminateCI:
    uses: DeterminateSystems/ci/.github/workflows/workflow.yml@main
    permissions:
      id-token: "write"
      contents: "read"
    with:
      flake-owner: DeterminateSystems
      flake-name: my-flake
      visibility: public
```

[flake-schemas]: https://determinate.systems/posts/flake-schemas/
[magic-nix-cache]: https://github.com/determinateSystems/magic-nix-cache-action
[flakehub]: https://flakehub.com/
[runners]: https://docs.github.com/en/actions/using-github-hosted-runners/about-larger-runners
