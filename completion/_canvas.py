#compdef canvas.py
# Zsh completion for canvas.py
#
# Install:
#   1. Put this file in a directory on your $fpath, e.g. ~/.zsh/completions
#        mkdir -p ~/.zsh/completions
#        cp _canvas.py ~/.zsh/completions/
#   2. Make sure that directory is added to fpath BEFORE compinit runs, e.g. in ~/.zshrc:
#        fpath=(~/.zsh/completions $fpath)
#        autoload -Uz compinit && compinit
#   3. Start a new shell (or run `exec zsh`)

_canvas.py() {
    local -a entities
    entities=(courses all_courses quizzes assignments pages questions students dqs ann rubric)

    _arguments -s -C \
        '(-g --get --headers -d --delete)'{-g,--get}'[GET the resources at the URIs]' \
        '(-g --get --headers -d --delete)--headers[Retrieve HTTP headers from the given URIs]' \
        '(-g --get --headers -d --delete)'{-d,--delete}'[DELETE the resources at the URIs]' \
        '(--post --put --rest)--post[POST data from FILE to the URL]' \
        '(--post --put --rest)--put[PUT data from FILE to the URL]' \
        '(--post --put --rest)*--rest[a URL, then an optional filename]:URI or filename:_files' \
        {-c,--course}'[A Canvas course ID]:course ID:' \
        {-q,--quiz}'[A Canvas quiz ID]:quiz ID:' \
        {-a,--assignment}'[A Canvas assignment ID]:assignment ID:' \
        {-r,--rubric}'[A Canvas assignment ID to show its associated rubric]:assignment ID:' \
        {-s,--short-rubric}'[A Canvas assignment ID to show its associated rubric in brief]:assignment ID:' \
        '--description[Display assignment description with markdown rendering]' \
        '--navigation[Generate navigation script section for a Course]' \
        '--include-section[Combine section with course number in navigation script]' \
        '*--add-questions[Files containing POST-formatted quiz questions]:question file:_files' \
        '--nuke-questions[Delete all questions associated with a Quiz]' \
        '--create-quiz[Create a new quiz from a quiz file with a Quiz header block]:quiz file:_files' \
        '--update-quiz[Update an existing quiz (--quiz/$QUIZ) from a quiz file with a Quiz header block]:quiz file:_files' \
        {-l,--list}'[List a Canvas entity]:entity:(${entities})' \
        '*--dq[Award DQ points to A-numbers listed in file(s)]:DQ file:_files' \
        '*--del-ann[Delete announcements by ID; use "all" to remove everything]:announcement ID:(all)' \
        '--so3[SO3 report for CS 1440 of SDP and Sprint Signature scores]' \
        '--read[Mark discussion topic as read]:topic ID:' \
        '--unread[Mark discussion topic as unread]:topic ID:' \
        {-t,--topic}'[Specify a discussion topic ID]:topic ID:' \
        {-p,--participation}'[Assign points to unlocked Canvas discussions (use with --assignment)]' \
        '--lock[Lock discussion topic]:topic ID:' \
        '--unlock[Unlock discussion topic]:topic ID:' \
        {-P,--pdf}'[Render a PDF of --assignment N]' \
        '--set-due-date[Set assignment due date]:date (YYYY-MM-DDTHH\:MM\:SSZ):' \
        '(- *)'{-h,--help}'[show help message and exit]'
}

_canvas.py "$@"
