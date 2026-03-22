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

def --env load-bitwarden-secrets [] {
  let gemini = (bw-get-secret "gemini-api-key")
  if $gemini != null {
    $env.GEMINI_API_KEY = $gemini
  }

  let github_pat = (bw-get-secret "github-pat")
  if $github_pat != null {
    $env.PAT = $github_pat
  }
}
