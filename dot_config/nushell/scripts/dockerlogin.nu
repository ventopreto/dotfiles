def dockerlogin [] {
  if ($env.PAT | is-empty) {
    error make { msg: "PAT não definido no ambiente" }
  }

  echo $env.PAT | docker login ghcr.io --username $env.USER --password-stdin
}