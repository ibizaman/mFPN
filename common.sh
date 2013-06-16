function debug
{
    if ${verbose:=false}
    then echo "$@"
    fi
    return 0
}

function error
{
    echo "$@, aborting..." && exit 1
}

function save_once
{
    if [ -z $2 ]
    then error "second argument to save_once must be non empty"
    fi

    if [ ! -f "$1"."$2" ] && [ -f "$1" ]
    then
        debug "Saving $1 to $1.$2"
        cp "$1" "$1"."$2"
    fi
}

function same_file
{
    if [ ! -f "$1" ] || [ ! -f "$2" ]
    then return 1
    else return $(diff "$1" "$2" > /dev/null)
    fi
}

function delete_bck_if_same
{
    if same_file $1 $1.$2 
    then rm $1.$2 && debug "Deleting backup $1.$2"
    fi
    return 0
}
