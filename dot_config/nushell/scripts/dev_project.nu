# ~/.config/nushell/scripts/dev_project.nu

def create_dev_session [] {
    let session_name = "dev_project"
    let attach_result = (tmux attach-session -t $"($session_name)" | complete)

    if ( ($attach_result.stderr | str contains "can't find session") or ($attach_result.stderr | str contains "no sessions") ) {
        print $"Sessão ($session_name) não encontrada. Criando..."

        tmux new-session -d -s $"($session_name)" -n "server"
        tmux send-keys -t $"($session_name):server" "bers" C-m
        tmux attach-session -t $"($session_name)"
mv ~/.cargo/bin/zellij ~/.local/bin/
        print $"Sessão ($session_name) criada e anexada com sucesso!"
    } else {
        print $"Sessão ($session_name) já existe. Anexando..."
        tmux switch-client -t $"($session_name)"
    }
}
