# Exo Package Registry

Official curated list of approved Exo packages.

## Using the Registry

Install packages by short name:

```bash
exo install bmad
```

Exo resolves `bmad` → `tl-nguyen/exo-pkg-bmad` via this registry.

You can always use the full `owner/repo` to install any package, even ones not in the registry:

```bash
exo install some-org/their-package
```

## Available Packages

| Name | Repository | Category | Description |
|------|-----------|----------|-------------|
| `bmad` | [tl-nguyen/exo-pkg-bmad](https://github.com/tl-nguyen/exo-pkg-bmad) | Framework | BMAD Method — AI-driven agile development |
| `caveman` | [tl-nguyen/exo-pkg-caveman](https://github.com/tl-nguyen/exo-pkg-caveman) | Tool | Caveman — terse-response mode that cuts agent output tokens |

## Adding a Package

1. Create a GitHub repo with an `exo-package.json` at the root
2. Create a GitHub release with a tarball
3. Submit a PR to this repo adding your package to `registry.json`

### Requirements

- Must have a valid `exo-package.json`
- Must have at least one GitHub release
- Must include a README
- Install must be non-destructive and reversible

## Registry URL

Exo fetches the registry from:
```
https://raw.githubusercontent.com/tl-nguyen/exo-registry/main/registry.json
```
