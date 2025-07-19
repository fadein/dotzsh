# chicken-belt egg: support for a chicken coop
if [[ -d $HOME/build/chickens ]]; then
    export CHICKENS=$HOME/build/chickens
    PATH=$CHICKENS/use-this/bin:$PATH
fi
