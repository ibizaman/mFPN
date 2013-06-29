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

function backup_file
{
    [ ! -f $1 ] && debug "Not backing up non existing file $1" && return 0

    bck="$1".bck
    orig="$1".orig
    if [ ! -f "$orig" ]
    then
        debug "Saving original file $1"
        cp "$1" "$orig"
    fi
    debug "Saving last version of file $1"
    cp "$1" "$bck"
}

function same_file
{
    if [ ! -f "$1" ] || [ ! -f "$2" ]
    then return 1
    else return $(diff "$1" "$2" > /dev/null)
    fi
}

function delete_backup_if_obsolete
{
    [ ! -f "$1" ] && error "File $1 does not exist"
    bck="$1".bck
    if same_file "$1" "$bck"
    then rm "$bck" && debug "Deleting backup $bck"
    fi
    return 0
}

function update_pacman
{
    debug "Upgrading all packages"
    pacman -Suy --noconfirm || error "Not able to update pacman"
}

function install_missing_packages
{
    debug "Installing missing packages"
    update_pacman
    for package in $@
    do
        if ! package_exists $package
        then debug "installing "$package
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

function ensure_directory_existence
{
    if [ ! -d "$1" ] 
    then mkdir -p "$1" \
        || error "Cannot create directory $1"
    fi
}

# generates temporary file from generator file ($1).generate and move it to
# destination ($2)
function deploy_generated_file
{
    generator="$1".generate
    generated="$1"
    destination="$2"

    [ ! -f "$generator" ] && error "Cannot generate a non-existing file $generator"

    #ensure_directory_existence $(dirname "$destination")

    debug "Generating file from $generator and moving it to $destination"
    source ./"$generator"
    #source "$generator" > "$generated" && mv "$generated" "$destination" \
    #    || ( rm "$generated"; error "Cannot move file to $destination" )
}

# replaces variables ($3) in template ($1) and create move it to required
# location ($2) while saving existing file
function deploy_template
{
    template="$1"
    destination="$2"

    [ ! -f "$template" ] && error "Trying to deploy a non-existing template $template"

    ensure_directory_existence $(dirname "$destination")

    backup_file "$destination"
    debug "Deploys template $template to $destination"
    cat "$template" | $(sed_from_vars ${@:3}) > "$destination"
    delete_backup_if_obsolete "$destination"
}

# copy file ($2) to location ($3) and append a template ($1) where variables
# ($4) are replaced
function append_template
{
    template="$1"
    original="$2"
    destination="$3"

    [ ! -f "$template" ] && error "Cannot deploy a non-existing template $template"
    [ ! -f "$original" ] && error "Cannot append to a non-existing file $original"

    ensure_directory_existence $(dirname "$destination")

    backup_file "$destination"
    debug "Copying file $original to $destination"
    cp $original $destination || error "Cannot copy to $destination"
    debug "Appends template $template to file $original in $destination"
    cat "$template" | $(sed_from_vars ${@:4}) >> "$destination"
    delete_backup_if_obsolete "$destination"
}

function stop_systemd_service
{
    debug "Stopping $1 service"
    systemctl --quiet stop "$1"
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
    if systemctl --quiet is-enabled "$1"
    then systemctl --quiet disable "$1" && \
        debug "Disabling $1 service" || \
        error "Unable to disable $1 service"
    fi
}
