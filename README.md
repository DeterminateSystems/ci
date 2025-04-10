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

## Configuration options

| Parameter          | Description                                                                                                                                           | Default                                                                                                                                                                   |
| :----------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `visibility`       | `public`, `unlisted`, or `private` ([private flakes][private-flakes] are available only on a [FlakeHub paid plan][signup])                            |                                                                                                                                                                           |
| `default-branch`   | The [default Git branch][default-branch] for the repository                                                                                           | `${{ github.event.repository.default_branch }}`                                                                                                                           |
| `enable-ssh-agent` | Whether to enable [`webfactory/ssh-agent`][ssh-agent] in the workflow. If you set this to `true` you need to supply a secret named `ssh-private-key`. | `false`                                                                                                                                                                   |
| `directory`        | The root directory of your flake.                                                                                                                     | `.`                                                                                                                                                                       |
| `fail-fast`        | Whether to cancel all in-progress jobs if any matrix job fails                                                                                        | `true`                                                                                                                                                                    |
| `runner-map`       | A custom mapping of [Nix system types][nix-system] to desired Actions runners                                                                         | `{ "aarch64-darwin": "macos-latest", "x86_64-darwin": "macos-latest", "x86_64-linux": "ubuntu-latest", "i686-linux": "ubuntu-latest", "aarch64-linux": "ubuntu-latest" }` |

## Example configurations

The sections below show configurations for some common use cases.

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

#### GitHub Actions Runners

##### Standard and larger runners

By default, the CI maps the Nix systems to their equivalent GitHub-hosted runners:

|                                                   | macOS (Apple Silicon)                | ARM Linux                   | macOS (Intel)                        | x86 Linux                   |
| ------------------------------------------------- | ------------------------------------ | --------------------------- | ------------------------------------ | --------------------------- |
| Flake `system` (Nix build platform)               | `aarch64-darwin`                     | `aarch64-linux`             | `x86_64-darwin`                      | `x86_64-linux`              |
| [GitHub Actions Runner][runners] (workflow label) | `macos-latest` (using Apple Silicon) | `ubuntu-latest` (using x86) | `macos-latest` (using Apple Silicon) | `ubuntu-latest` (using x86) |

> [!NOTE]
> There is also a [standard ARM Linux runner][runners-linux-arm] `ubuntu-24.04-arm`, currently in public preview and only supported on public repositories.
> To use it, supply your own runner map as shown below.
> To use ARM Linux runners on private repositories, you need non-standard runners, as shown below.

##### Non-standard runners

You can also use several types of non-standard runners by providing a custom runner map.
For example, this runner map enables the [larger GitHub runners for macOS][runners-large-macos]:

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
          "x86_64-darwin": "macos-latest-large"
        }
```

> [!TIP]
> Using `macos-latest-large` is currently the only way to run _current_ macOS on Intel architecture.

The other two types of runners are those provisioned on your own infrastructure, and [larger Ubuntu (not macOS) runners][runners-large] with bespoke specs (for example, 64 CPUs, 128GB RAM) hosted by GitHub.
Confusingly, GitHub sometimes refers to both of these as "self-hosted" runners.

> [!IMPORTANT]
> Shared workflows such as the one used in this repo [can only access][workflow-access] non-standard runners if the workflow repo (this one) is owned by the same organisation (`DeterminateSystems`) or user.
> To use this repo with non-standard runners if you are not `DeterminateSystems`, fork the repository and replace the upstream workflow with your fork.
>
> ```diff
> jobs:
>   DeterminateCI:
> -    uses: DeterminateSystems/ci/.github/workflows/workflow.yml@main
> +    uses: $YOURORG/ci/.github/workflows/workflow.yml@main
> ```
>
> Replace `$YOURORG` with your own organisation or user.
>
> This limitation does not apply to larger macOS runners hosted by GitHub.

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

## Workflow outputs

The `DeterminateSystems/ci` workflow provides a number of outputs that you can use in dependent workflows.

| Output              | Description                                                                                                                                                                                                                  | Example                                                                                 |
| :------------------ | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| `flake_name`        | The name of the flake                                                                                                                                                                                                        | `DeterminateSystems/flakehub-push`                                                      |
| `flake_version`     | The version of the published flake                                                                                                                                                                                           | `0.1.99+rev-2075013a3f3544d45a96f4b35df4ed03cd53779c`                                   |
| `flakeref_exact`    | A precise flake reference that always resolves to this to this exact release.                                                                                                                                                | `DeterminateSystems/flakehub-push/=0.1.99+rev-2075013a3f3544d45a96f4b35df4ed03cd53779c` |
| `flakeref_at_least` | A loose reference to this release. Depending on this reference will require at least this version, and will also resolve to newer releases. This output is not sufficient for deployment pipelines, use flake_exact instead. | ``DeterminateSystems/flakehub-push/0.1.99+rev-2075013a3f3544d45a96f4b35df4ed03cd53779c` |

## Notes

This workflow uses a collection of GitHub Actions by Determinate Systems, all of which are covered by the Determinate Systems [privacy policy][privacy] and [terms of service][tos].

[binary-cache]: https://zero-to-nix.com/concepts/caching
[cache]: https://flakehub.com/cache
[default-branch]: https://docs.github.com/repositories/configuring-branches-and-merges-in-your-repository/managing-branches-in-your-repository/changing-the-default-branch
[flake-schemas]: https://github.com/DeterminateSystems/flake-schemas
[flakehub]: https://flakehub.com/
[discord]: https://determinate.systems/discord
[nix]: https://zero-to-nix.com
[nix-system]: https://zero-to-nix.com/concepts/system-specificity
[privacy]: https://determinate.systems/policies/privacy
[private-flakes]: https://docs.determinate.systems/flakehub/private-flakes
[publishing]: https://docs.determinate.systems/flakehub/publishing
[runners]: https://docs.github.com/en/actions/using-github-hosted-runners
[runners-large]: https://docs.github.com/en/actions/using-github-hosted-runners/using-larger-runners/about-larger-runners
[runners-large-macos]: https://docs.github.com/en/actions/using-github-hosted-runners/using-larger-runners/about-larger-runners#about-macos-larger-runners
[runners-linux-arm]: https://github.blog/changelog/2025-01-16-linux-arm64-hosted-runners-now-available-for-free-in-public-repositories-public-preview/
[signup]: https://flakehub.com/signup
[ssh-agent]: https://github.com/webfactory/ssh-agent
[tos]: https://determinate.systems/policies/terms-of-service
[visibility]: https://docs.determinate.systems/flakehub/concepts/visibility
[workflow-access]: https://docs.github.com/en/actions/sharing-automations/reusing-workflows#using-self-hosted-runners
