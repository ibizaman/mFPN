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

function at_least_one_variable_set
{
    one_is_set=1
    for var in $@
    do [ ! -z "${!var}" ] \
        && debug "Variable $var set" \
        && one_is_set=0
    done
    return $one_is_set
}

function all_variables_set
{
    all_are_set=0
    for var in $@
    do [ -z "${!var}" ] \
        && debug "Variable $var not set" \
        && all_are_set=1
    done
    return $all_are_set
}

function read_from_conf
{
    [ ! -f "$1" ] && error "The file $1 must exist to read conf"
    [ "${#@}" -le 1 ] && error "You want to at least get one variable from the conf file"
    at_least_one_variable_set ${@:2} && debug "Overriding existing variables"
    source "$1"
    all_variables_set ${@:2} || error "Not all variables are set"
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

function update_pacman
{
    debug "Upgrading all packages"
    pacman -Suy || error "Not able to update pacman"
}

function install_missing_packages
{
    debug "Installing missing packages"
    for package in $@
    do
        if ! package_exists $package
        then update_pacman
             debug "installing "$package
             package_install $package || error "$package installation failed"
        else debug "skipping already installed "$package
        fi      
    done
}

function package_exists
{
    pacman -Q $1 >/dev/null 2>&1
}

function package_install
{
    pacman -S --noconfirm $@
}

function sed_from_vars
{
    [ ${#@} -eq 0 ] && echo "sed -e s/a/a/" && return 0
    cmd="sed"
    for name in "${@}"
    do
        cmd="$cmd -e s/\${${name}}/${!name//\//\/}/"
    done
    echo "$cmd"
}

# replaces variables ($3) in template ($1) and create
# move it to required location ($2)
function deploy_template
{
    [ ! -f "$1" ] && error "Trying to deploy a non-existing template $1"
    debug "Deploys template $1 to $2"
    mkdir -p "$(dirname $2)" && cat "$1" | $(sed_from_vars ${@:3}) > "$2"
}

# replaces variables ($3) in template ($1) and create
# append it to required location ($2)
function append_template
{
    [ ! -f "$1" ] && error "Trying to deploy a non-existing template $1"
    debug "Appends template $1 to $2"
    mkdir -p "$(dirname $2)" && cat "$1" | $(sed_from_vars ${@:3}) >> "$2"
}

function install_systemd_service
{
    debug "Reloading systemd, enabling and starting new $1 service"
    systemctl --quiet daemon-reload \
    && systemctl --quiet enable "$1" \
    && systemctl --quiet reload-or-restart "$1" \
    || error "Unable to install $1 service"
}

function disable_systemd_service
{
    systemctl --quiet disable "$1" && \
        debug "Disabling $1 service" || \
        error "Unable to disable $1 service"
}
