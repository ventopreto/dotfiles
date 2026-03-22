# env.nu
#
# Installed by:
# version = "0.110.0"
#
# Previously, environment variables were typically configured in `env.nu`.
# In general, most configuration can and should be performed in `config.nu`
# or one of the autoload directories.
#
# This file is generated for backwards compatibility for now.
# It is loaded before config.nu and login.nu
#
# See https://www.nushell.sh/book/configuration.html
#
# Also see `help config env` for more options.
#
# You can remove these comments if you want or leave
# them for future reference.

$env.PATH = [
  $"($env.HOME)/bin",
  "/home/linuxbrew/.linuxbrew/bin",
  $"($env.HOME)/.local/bin",
  "/snap/bin",
  "/usr/local/bin",
  "/usr/bin",
  "/bin",
] | append $env.PATH


$"($env.HOME)/.asdf/bin",
$"($env.HOME)/.asdf/shims",

$env.BUN_INSTALL = $"($env.HOME)/.bun"
$env.PATH = ($env.PATH | prepend ($env.BUN_INSTALL | path join "bin"))


# $env.ASDF_DATA_DIR = $"($env.HOME)/.asdf"
$env.LC_TIME = "pt_BR.UTF-8"

$env.DISABLE_SPRING = "1"
$env.STARSHIP_SHELL = "nu"
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"

source ~/.config/nushell/scripts/bitwarden.nu

# Load secrets from the parent environment when present.
if ("GEMINI_API_KEY" in $env) {
    $env.GEMINI_API_KEY = $env.GEMINI_API_KEY
}
if ("PAT" in $env) {
    $env.PAT = $env.PAT
}

# Try Bitwarden as a secondary source when env vars are not already present.
if not ("GEMINI_API_KEY" in $env) or not ("PAT" in $env) {
    do -i { load-bitwarden-secrets }
}

# ^mise activate nu | save --force ~/.cache/mise.nu
zoxide init nushell | save -f ~/.zoxide.nu
