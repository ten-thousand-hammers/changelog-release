# changelog-release

Cuts a release from a prepared changelog body: computes the next
[CalVer](https://calver.org/) version (`YYYY.MM.DD+N`), inserts the notes into
`CHANGELOG.md`, deletes the consumed fragments, commits + tags, and creates a
GitHub Release.

Part of the changelog actions suite:
`changelog-generate` → `changelog-merge` → **`changelog-release`** → `changelog-notify`.

## Usage

```yaml
- uses: ten-thousand-hammers/changelog-merge@v1
  id: merge

- uses: mindsers/changelog-reader-action@v2
  id: reader
  with:
    validation_level: none
    version: "Unreleased"
    path: ./CHANGES_COMBINED.md

- uses: ten-thousand-hammers/changelog-release@v1
  id: release
  with:
    changes: ${{ steps.reader.outputs.changes }}
    version-file: config/version
    token: ${{ secrets.CHANGELOG_TOKEN }}
```

## Versioning

When `version` is empty, the bundled `next_version.sh` derives the next version
from the latest tag on `main`: same calendar day → bump the `+N` counter, new day
→ reset to `+1`. This needs the `main` branch and tags available, so the caller
must check out with `fetch-depth: 0`.

## Inputs

| Name | Default | Description |
| --- | --- | --- |
| `changes` | _(required)_ | Release notes body to insert and publish. |
| `version` | `""` | Explicit version; empty computes the next CalVer version. |
| `changelog-file` | `CHANGELOG.md` | Cumulative changelog to insert into. |
| `insert-line` | `7` | 1-based line to insert the new entry at (matches the Keep-a-Changelog header). |
| `fragments-dir` | `changelog` | Directory of consumed fragments to delete. |
| `combined-file` | `CHANGES_COMBINED.md` | Transient merged file to delete. |
| `version-file` | `""` | Optional file to write the version into (e.g. `config/version`). |
| `extra-add` | `""` | Extra space-separated paths to include in the release commit. |
| `commit-message-prefix` | `chore: Release` | Commit message prefix. |
| `skip-ci` | `"true"` | Append `[skip ci]` to the commit message. |
| `tag` | `"true"` | Create and push a git tag. |
| `create-github-release` | `"true"` | Create a GitHub Release. |
| `make-latest` | `"true"` | Mark the release as latest. |
| `prerelease` | `"false"` | Mark the release as a prerelease. |
| `token` | `${{ github.token }}` | Token for creating the GitHub Release (pass `CHANGELOG_TOKEN`). |

## Outputs

| Name | Description |
| --- | --- |
| `version` | The version that was released. |
| `released` | Whether a GitHub Release was created. |

## Notes

- The push/commit uses the credentials from `actions/checkout` in the caller, so
  check out with `token: ${{ secrets.CHANGELOG_TOKEN }}` to push past branch
  protection and trigger downstream release workflows.
- `insert-line: 7` assumes the standard 6-line Keep-a-Changelog header. Seed new
  projects' `CHANGELOG.md` with that header (see the suite README).
