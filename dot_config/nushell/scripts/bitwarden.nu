const BW_CACHE = "~/.cache/bw-secrets.nuon"

def bw-session-active [] {
  if ((which bw | length) == 0) {
    return false
  }

  let status = (do -i { bw status } | complete)
  if $status.exit_code != 0 {
    return false
  }

  let parsed = (do -i { $status.stdout | from json })
  ($parsed.status? | default "unauthenticated") == "unlocked"
}

def bw-get-secret [item_name: string] {
  if not (bw-session-active) {
    return null
  }

  let result = (do -i { bw get password $item_name } | complete)
  if $result.exit_code != 0 {
    return null
  }

  let secret = ($result.stdout | str trim)
  if ($secret | is-empty) {
    null
  } else {
    $secret
  }
}

# Load secrets from cache file (instant).
def --env load-cached-secrets [] {
  let cache = ($BW_CACHE | path expand)
  if not ($cache | path exists) { return }

  let secrets = (do -i { open $cache } | default {})
  if ($secrets.GEMINI_API_KEY? != null) {
    $env.GEMINI_API_KEY = $secrets.GEMINI_API_KEY
  }
  if ($secrets.PAT? != null) {
    $env.PAT = $secrets.PAT
  }
}

# Fetch secrets from Bitwarden and write cache for next shell start.
def --env refresh-bw-secrets [] {
  mut secrets = {}

  let gemini = (bw-get-secret "gemini-api-key")
  if $gemini != null { $secrets = ($secrets | merge {GEMINI_API_KEY: $gemini}) }

  let github_pat = (bw-get-secret "github-pat")
  if $github_pat != null { $secrets = ($secrets | merge {PAT: $github_pat}) }

  if not ($secrets | is-empty) {
    $secrets | to nuon | save -f ($BW_CACHE | path expand)
  }

  # Also set in current session
  for entry in ($secrets | transpose key value) {
    load-env {($entry.key): $entry.value}
  }
}
