# open-constructs/homebrew-tap

Homebrew tap for [Open Constructs](https://github.com/open-constructs) projects.

## Note for reviewers

**This tap repository does not exist on GitHub yet** — `https://github.com/open-constructs/homebrew-tap` returns 404 as of 2026-04-20. Before users can run the `brew tap` / `brew install` commands below, someone with org permissions needs to:

1. Create the `open-constructs/homebrew-tap` repo on GitHub (public, MIT or Apache-2.0 LICENSE, the `Formula/` directory at repo root).
2. Push `Formula/cdktn.rb` and this `README.md` to its default branch.
3. Verify `brew tap open-constructs/tap` resolves (Homebrew strips the `homebrew-` prefix when mapping tap names to repos).

The formula itself has been locally audit-clean (`brew audit --new --strict --online`) and install-verified against a temporary local tap. The content in this directory is a working copy ready to push.

## Install

```sh
brew tap open-constructs/tap
brew install cdktn
```

## Formulae

### `cdktn` — [CDK Terrain](https://github.com/open-constructs/cdk-terrain) CLI

Community fork of the deprecated `cdktf` (CDK for Terraform) formula.

- **Current version:** 0.22.1 (tracks the [`cdktn-cli`](https://www.npmjs.com/package/cdktn-cli) npm release)
- **Source:** [`open-constructs/cdk-terrain`](https://github.com/open-constructs/cdk-terrain)
- **License:** MPL-2.0
- **Dependencies:** `node@20`, `terraform`, `yarn` (build-time)
- **Formula:** [`Formula/cdktn.rb`](./Formula/cdktn.rb)

**Stable** (`brew install cdktn`): installs the prebuilt [`cdktn-cli`](https://www.npmjs.com/package/cdktn-cli) npm tarball — ~400 MB, ~30 sec.

**Bleeding-edge** (`brew install --HEAD cdktn`): builds from the `cdk-terrain` main branch via `yarn build` (full monorepo, tsc + jsii) — ~1.5 GB, ~2 min.

### Migrating from `cdktf`

Homebrew's `cdktf` formula was deprecated by upstream and will be disabled on 2026-12-10. To switch:

```sh
brew uninstall cdktf
brew tap open-constructs/tap
brew install cdktn
```

The CLI binary renames `cdktf` → `cdktn`. Existing `cdktf.json` config files and `CDKTF_*` environment variables still work (see the upstream [CDKTN Rename notes](https://github.com/open-constructs/cdk-terrain/blob/main/CLAUDE.md#cdktn-rename)).

### Troubleshooting

**`brew install` fails at `brew link` with a conflict on `/opt/homebrew/bin/cdktn`:**
You have a stale global npm install of `cdktn-cli` (or the placeholder package published to npm). Remove it with:

```sh
npm uninstall -g cdktn-cli
```

Then re-run `brew link cdktn`.

**Install size feels large for a CLI.** The stable (npm) path is ~400 MB and the `--HEAD` path is ~1.5 GB. Both ship the CLI's runtime `node_modules` because the CLI is a partial esbuild bundle that loads several dependencies (`cdktn`, `@cdktn/hcl2cdk`, `constructs`, `yargs`, ...) at runtime rather than inlining them.

## Contributing

Version bumps, bug reports, and PRs welcome. To test a formula change locally:

```sh
brew audit --new --strict --online open-constructs/tap/cdktn
brew install --build-from-source open-constructs/tap/cdktn
brew test cdktn
```
