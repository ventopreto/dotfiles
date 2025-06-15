# env.nu
#
# Installed by:
# version = "0.103.0"
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
  $"($env.HOME)/.asdf/bin",
  $"($env.HOME)/.asdf/shims",
  "/snap/bin",
  "/usr/local/bin",
  "/usr/bin",
  "/bin"
] | append $env.PATH

$env.ASDF_DATA_DIR = $"($env.HOME)/.asdf"

$env.DISABLE_SPRING = "1"
$env.STARSHIP_SHELL = "nu"

zoxide init nushell | save -f ~/.zoxide.nu
