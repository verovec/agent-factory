---
name: ci
description: Use when adding or editing GitHub Actions workflows in this workspace - the reusable trigger + building-block convention
---

# CI Workflows

Two layers under `.github/workflows/`:

- **Trigger** workflows (`pr.yml`, `terraform.yml`) -- thin, own the `on:` events, fan out to building blocks.
- **Reusable** blocks (`_lint.yml`, `_test.yml`, `_terraform.yml`) -- `on: workflow_call`, parameterized by `path` + `lang`. Filename prefix `_` marks them callable-only.

Triggers never run steps directly; they only `uses: ./.github/workflows/_*.yml` with `with:`/`secrets:`. Logic lives in the block so node/python/terraform stay single-sourced.

## Stack-gating

Jobs are gated on the chosen stack, e.g. `if: ${{ hashFiles('stack/backend/pyproject.toml') != '' }}`. The committed workflows are a **superset**: jobs for an absent stack skip. `/setup` trims CI to the selected stack -- so author new jobs gated the same way rather than unconditional.

## AWS auth

OIDC only -- no long-lived keys. `_terraform.yml` sets `permissions: { id-token: write, contents: read }`, then `aws-actions/configure-aws-credentials` assumes `AWS_ROLE_ARN` (passed as a secret, read via `env`). Gate the credential step on `env.AWS_ROLE_ARN != ''` so it no-ops when unset.

## Terraform CI

`fmt -check` + `validate` always; `plan` on PRs; `apply` only on `main` via `apply: ${{ github.ref == 'refs/heads/main' }}`.

## Conventions

- Pin third-party actions to a commit SHA (the `@v4` tags here are placeholders `/setup` resolves).
- Set least-privilege `permissions:` per workflow; never leave the default token broad.
- Pass `github.event.*` and other untrusted input through `env:`, never interpolate inline in `run:`.

## Red flags / Don't

- Steps duplicated across triggers instead of a shared `_*.yml` block.
- A new job with no `hashFiles(...)` gate.
- Long-lived `AWS_ACCESS_KEY_ID` secrets, or `apply` reachable from a PR.
- `${{ }}` from event data spliced straight into a shell command.

See `slash-commands` for `/setup`, which prunes these workflows to the chosen stack.
