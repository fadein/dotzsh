# Soft-set Zen as default browser
if [[ ${+BROWSER} == 0 ]]; then
    path=( /opt/zen $path )
    export BROWSER=zen
fi
