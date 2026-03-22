# Dotfiles

Este repo esta sendo migrado para `chezmoi` como fonte unica de verdade para:

- WSL/Linux development config
- Windows desktop config

## Uso

Dentro da WSL/Linux:

```bash
chezmoi init git@github.com:ventopreto/dotfiles.git
chezmoi diff
chezmoi apply
```

Dentro do Windows:

```powershell
chezmoi init git@github.com:ventopreto/dotfiles.git
chezmoi diff
chezmoi apply
```

Se quiser instalar dependencias base primeiro:

```bash
./install.sh
```

O `install.sh` agora e um orquestrador:

- em Windows: chama o bootstrap Windows e aplica os dotfiles Windows
- em WSL: instala o stack Linux/WSL, aplica os dotfiles Linux e tenta acionar o bootstrap do host Windows
- em Linux: instala o stack Linux e aplica os dotfiles Linux

A aplicacao das configuracoes continua sendo feita com `chezmoi`, mas o bootstrap foi modularizado em `scripts/install/`.

## Estrutura

O layout alvo e o plano de migracao estao em [CHEZMOI_LAYOUT.md](./CHEZMOI_LAYOUT.md).

Arquivos Linux/WSL vivem principalmente em:

- `dot_config/nvim`
- `dot_config/nushell`
- `dot_config/zellij`
- `dot_config/yazi`
- `dot_local/bin`

Arquivos Windows vivem principalmente em:

- `private_dot_komorebi.json.tmpl`
- `dot_config/whkdrc`
- `dot_config/yasb`

## Yazi

Para `alacritty`, o `yazi` usa fallback de preview. Em `zellij`, este repo inclui `dot_local/bin/yazi-smart-preview`, que roda `TERM=xterm-kitty yazi` quando necessario.

Para validar:

```bash
yazi --debug
```

O ideal e ver `Adapter.matches: X11`, `Wayland` ou `Chafa`.
