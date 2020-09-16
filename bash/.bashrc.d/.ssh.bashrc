# config to simplify SSH tasks

## autorun SSH agent
ssh_env=~/.ssh/agent.env

agent_is_running() {
    if [ "$SSH_AUTH_SOCK" ]; then
        # ssh-add returns:
        #   0 = agent running, has keys
        #   1 = agent running, no keys
        #   2 = agent not running
        ssh-add -l >/dev/null 2>&1 || [ $? -eq 1 ]
    else
        false
    fi
}

agent_has_keys() {
    ssh-add -l >/dev/null 2>&1
}

agent_load_env() {
    . "$ssh_env" >/dev/null
}

agent_start() {
    (umask 077; ssh-agent >"$ssh_env")
    . "$ssh_env" >/dev/null
}

if ! agent_is_running; then
    agent_load_env
fi

### if your keys are not stored in ~/.ssh/id_rsa or ~/.ssh/id_dsa, you'll need
### to paste the proper path after ssh-add
if ! agent_is_running; then
    agent_start
    ssh-add
elif ! agent_has_keys; then
    ssh-add
fi

unset ssh_env

## ssh always uses -X
alias ssh='ssh -X '
