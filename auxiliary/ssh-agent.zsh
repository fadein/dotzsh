# Initialize the SSH Agent in an anonymous function (for clean scope)

function {
    # print "Initializing the SSH Agent"
    local dir dirs=(~/devel/ssh-agent ~/devel/shell/ssh-agent ~/.local/ssh-agent ~/.ssh-agent FAILED-TO-FIND-SSH-AGENT)
    for dir in $dirs; do
        # print Trying $dir
        if [[ -d $dir ]]; then
            path+=($dir)
            source ssh-agent-startup.sh
            break
        fi
    done

    # if [[ $dir == FAILED-TO-FIND-SSH-AGENT ]]; then
    #     print SSH Agent was not initialized
    # else
    #     print SSH Agent was initialized
    # fi
}
