# Chezmoi Layout Proposal

## Goal

Use a single `chezmoi` repository as the source of truth for:

- WSL/Linux development config
- Windows desktop config

The same repo should be applied in two places:

- inside WSL: `chezmoi apply`
- inside Windows: `chezmoi apply`

No manual `cp`. No parallel `stow` flow.

## Final Usage

Inside WSL:

```bash
chezmoi init git@github.com:ventopreto/dotfiles.git
chezmoi apply
```

Inside Windows PowerShell:

```powershell
chezmoi init git@github.com:ventopreto/dotfiles.git
chezmoi apply
```

For edits:

```bash
chezmoi edit ~/.config/nvim/init.lua
chezmoi diff
chezmoi apply
```

```powershell
chezmoi edit ~/.config/whkdrc
chezmoi diff
chezmoi apply
```

## Proposed Source Layout

This is the target structure for a single repo:

```text
dotfiles/
├── dot_aprc
├── dot_gitconfig
├── dot_irbrc
├── dot_pryrc
├── dot_tmux.conf
├── dot_config/
│   ├── nushell/
│   │   ├── aliases.nu
│   │   ├── config.nu
│   │   ├── env.nu
│   │   ├── login.nu
│   │   ├── completions/
│   │   ├── nu-themes/
│   │   └── scripts/
│   ├── nvim/
│   ├── zellij/
│   ├── yazi/
│   ├── alacritty/
│   ├── starship.toml
│   ├── whkdrc
│   └── yasb/
│       ├── config.yaml.tmpl
│       └── styles.css
├── dot_local/
│   └── bin/
│       └── yazi-smart-preview
├── private_komorebi.json.tmpl
├── .chezmoiignore.tmpl
└── .chezmoi.toml.tmpl
```

## Why This Layout

`chezmoi` source format already matches what you need:

- `dot_aprc` becomes `~/.aprc`
- `dot_config/nvim` becomes `~/.config/nvim`
- `dot_local/bin/yazi-smart-preview` becomes `~/.local/bin/yazi-smart-preview`
- `private_komorebi.json.tmpl` becomes `~/komorebi.json`

This removes the current ambiguity between:

- `config/.config/...`
- `.config/...`
- `~/.local/share/chezmoi/...`

Only one tree should exist.

## Platform Split

Use one repo, but let `chezmoi` decide what to apply.

### WSL/Linux managed files

- `dot_config/nvim/**`
- `dot_config/nushell/**`
- `dot_config/zellij/**`
- `dot_config/yazi/**`
- `dot_config/starship.toml`
- `dot_tmux.conf`
- `dot_aprc`
- `dot_irbrc`
- `dot_pryrc`
- `dot_local/bin/yazi-smart-preview`

### Windows managed files

- `private_komorebi.json.tmpl`
- `dot_config/whkdrc`
- `dot_config/yasb/**`
- `dot_config/alacritty/**` if Windows Alacritty is the one you use

## Suggested Ignore Rules

Use `.chezmoiignore.tmpl` to keep each environment clean:

```tmpl
{{- if eq .chezmoi.os "linux" }}
komorebi.json
dot_config/whkdrc
dot_config/yasb/**
{{- end }}

{{- if eq .chezmoi.os "windows" }}
dot_config/nvim/**
dot_config/nushell/**
dot_config/zellij/**
dot_config/yazi/**
dot_tmux.conf
dot_local/bin/yazi-smart-preview
{{- end }}
```

If you want Neovim on Windows too, remove `dot_config/nvim/**` from the Windows ignore block.

## Suggested Data File

Use `.chezmoi.toml.tmpl` or `chezmoi data` for flags like WSL:

```toml
[data]
is_wsl = true
```

Better than hard-coding WSL-only behavior in shell scripts.

## Migration Map From Current State

Current Linux repo files:

- `config/.aliases` -> `dot_aliases`
- `config/.aprc` -> `dot_aprc`
- `config/.gitconfig` -> `dot_gitconfig`
- `config/.irbrc` -> `dot_irbrc`
- `config/.pry/` -> `dot_pry/`
- `config/.pryrc` -> `dot_pryrc`
- `config/.tmux.conf` -> `dot_tmux.conf`
- `config/.config/nushell/**` -> `dot_config/nushell/**`
- `.config/nvim/**` -> `dot_config/nvim/**`
- `.config/zellij/**` -> `dot_config/zellij/**`
- `.config/yazi/**` -> `dot_config/yazi/**`
- `.local/bin/yazi-smart-preview` -> `dot_local/bin/yazi-smart-preview`

Current Windows-ish repo files:

- `dot_config/whkdrc` -> keep as `dot_config/whkdrc`
- `dot_config/yasb/**` -> keep as `dot_config/yasb/**`
- `komorebi.json.tmpl` -> `private_komorebi.json.tmpl`

Current loose `chezmoi` source:

- `~/.local/share/chezmoi/dot_aprc` -> merge into `dot_aprc`
- `~/.local/share/chezmoi/dot_irbrc` -> merge into `dot_irbrc`
- `~/.local/share/chezmoi/dot_pryrc` -> merge into `dot_pryrc`
- `~/.local/share/chezmoi/dot_config/nushell/**` -> merge into `dot_config/nushell/**`
- `~/.local/share/chezmoi/dot_config/starship.toml` -> merge into `dot_config/starship.toml`
- `~/.local/share/chezmoi/dot_config/zellij/**` -> merge into `dot_config/zellij/**`

## Important Rule

Do not keep both of these:

- `config/.config/...`
- `.config/...`

Pick one format only. For `chezmoi`, the correct format is:

- `dot_config/...`

## Recommended End State

- `dotfiles` becomes the only repo
- `dotfiles-windows` is archived after migration
- `~/.local/share/chezmoi` stops being a manual unmanaged tree
- `install.sh` becomes optional bootstrap only, not the source-of-truth mechanism

## Next Migration Step

Implement this in phases:

1. Move current files to native `chezmoi` names.
2. Import the loose `~/.local/share/chezmoi` tree.
3. Add `.chezmoiignore.tmpl`.
4. Test `chezmoi apply --dry-run` in WSL.
5. Test `chezmoi apply --dry-run` in Windows.
