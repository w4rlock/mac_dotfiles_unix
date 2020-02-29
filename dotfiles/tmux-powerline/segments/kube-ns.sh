run_segment() {
    export KUBE_TMUX_DIVIDER='--'
    export KUBE_TMUX_CONTEXT_ENABLE="true"

    bash $HOME/.tmux/kube-tmux/kube.tmux red red
	return 0
}
