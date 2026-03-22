source ~/.config/nushell/aliases.nu

use ~/.config/nushell/completions/curl-completions.nu *
use ~/.config/nushell/completions/docker-completions.nu *
use ~/.config/nushell/completions/git-completions.nu *
use ~/.config/nushell/completions/vscode-completions.nu *

# ASDF shims (versão moderna)
let shims_dir = (
  ($env.ASDF_DATA_DIR? | default ($env.HOME | path join '.asdf'))
  | path join 'shims'
)

# PATH handling mais idiomático
use std/util "path add"

path add $shims_dir

# Starship (forma moderna e mais simples)
mkdir ($nu.data-dir | path join "vendor/autoload")

starship init nu
| save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

#mise
# source ~/.cache/mise.nu

# Scripts
source ~/.config/nushell/scripts/dev_project.nu
source ~/.config/nushell/scripts/payments.nu
source ~/.config/nushell/scripts/dockerlogin.nu
source ~/.zoxide.nu
