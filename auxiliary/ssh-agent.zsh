# Initialize the SSH Agent

if [[ -d ~/devel/shell/ssh-agent ]]; then
    path+=(~/devel/shell/ssh-agent)
    source ssh-agent-startup.sh
fi
