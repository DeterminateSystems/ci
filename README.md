# Determinate CI

> [!NOTE]
> This Action is intended for users of [FlakeHub Cache][cache].
> [Sign up][signup] for a FlakeHub paid plan to get started.

Your one-stop shop for effortless [Nix] CI in GitHub Actions.

- Automatically builds on all the architectures your flake supports.
- Caches all of your flake outputs using [FlakeHub Cache][cache].
- Discovers and builds your entire flake using [flake schemas][flake-schemas].
- [Publishes your flake][publishing] to [FlakeHub][flakehub] if you [opt in](#publishing-to-flakehub).

> [!WARNING]
> The Determinate CI workflow is an experiment.
> It may change significantly without warning.
> Please feel free to try it out, report bugs, and [let us know how it goes in our Discord][discord]!
> Stabilization to follow.

## Usage

Create an Actions workflow in your project at `.github/workflows/ci.yml`, copy in this text...

```yaml
on:
  pull_request:
  workflow_dispatch:
  push:
    branches:
      - main
      - master
    tags:
      - v?[0-9]+.[0-9]+.[0-9]+*

concurrency:
  group: ${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
  cancel-in-progress: true

jobs:
  DeterminateCI:
    uses: DeterminateSystems/ci/.github/workflows/workflow.yml@main
    permissions:
      id-token: write
      contents: read
```

...and you're done!
You'll see something like this when your workflow has run successfully:

![Screenshot of successful build](https://github.com/DeterminateSystems/ci/assets/76716/c2c6aa07-3fd3-4e66-9440-bef264b472da)

### Publishing to FlakeHub

Publish to FlakeHub on every push to the default branch and on every tag.
Specify the flake's [visibility]:

```yaml
on:
  pull_request:
  workflow_dispatch:
  push:
    branches:
      - main
      - master
    tags:
      - v?[0-9]+.[0-9]+.[0-9]+*

concurrency:
  group: ${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
  cancel-in-progress: true

jobs:
  DeterminateCI:
    uses: DeterminateSystems/ci/.github/workflows/workflow.yml@main
    permissions:
      id-token: write
      contents: read
    with:
      visibility: public
```

For [private flakes][private-flakes], set `visibility` to `private`.

### Caching

This workflow uses [FlakeHub Cache][cache] as a [binary cache][binary-cache].

> [!NOTE]
> FlakeHub Cache only works if you're on a paid plan.

If you're not signed up for FlakeHub, the workflow will still pass but won't cache your flake outputs.
In this case, your logs will include a warning like this:

```
ERROR magic_nix_cache: FlakeHub cache initialization failed: FlakeHub cache error: HTTP 401 Unauthorized: "User is not authorized for this resource."
```

### Advanced usage

#### Custom runner types

The default runner map uses `ubuntu-latest` for x86 Linux and `macos-latest` for macOS.
Take advantage of [larger GitHub runners][runners] by providing a custom runner map:

```yaml
jobs:
  DeterminateCI:
    uses: DeterminateSystems/ci/.github/workflows/workflow.yml@main
    permissions:
      id-token: write
      contents: read
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

#### Private SSH keys

Configure an SSH agent with a secret private key for private repository support.

```yaml
jobs:
  DeterminateCI:
    uses: DeterminateSystems/ci/.github/workflows/workflow.yml@main
    permissions:
      id-token: write
      contents: read
    with:
      enable-ssh-agent: true
    secrets:
      ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}
```

#### Continue on failure

By default, if any build in the matrix fails, the workflow will cancel all remaining in-progress jobs.
You can change this behavior by setting `fail-fast` to `false`:

```yaml
jobs:
  DeterminateCI:
    uses: DeterminateSystems/ci/.github/workflows/workflow.yml@main
    permissions:
      id-token: write
      contents: read
    with:
      fail-fast: false
```

## Notes

This workflow uses a collection of GitHub Actions by Determinate Systems, all of which are covered by the Determinate Systems [privacy policy][privacy] and [terms of service][tos].

[binary-cache]: https://zero-to-nix.com/concepts/caching
[cache]: https://flakehub.com/cache
[flake-schemas]: https://github.com/DeterminateSystems/flake-schemas
[flakehub]: https://flakehub.com/
[discord]: https://determinate.systems/discord
[nix]: https://zero-to-nix.com
[privacy]: https://determinate.systems/policies/privacy
[private-flakes]: https://docs.determinate.systems/flakehub/private-flakes
[publishing]: https://docs.determinate.systems/flakehub/publishing
[runners]: https://docs.github.com/en/actions/using-github-hosted-runners/about-larger-runners
[signup]: https://flakehub.com/signup
[tos]: https://determinate.systems/policies/terms-of-service
[visibility]: https://docs.determinate.systems/flakehub/concepts/visibility
