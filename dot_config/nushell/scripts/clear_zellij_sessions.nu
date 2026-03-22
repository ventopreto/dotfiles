def clear_zellij_sessions [] {
  zellij list-sessions |
  lines |
  where { |line| not ($line | str contains "server") } |
  ansi strip |
  parse "{name} {_}" |
  each { |s| zellij delete-session $s.name }
}