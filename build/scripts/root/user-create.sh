#!/bin/bash

# Change Root Password or Docker/Podman cannot execute USER root after USER $USER_NAME
echo -e "$ROOT_PASSWORD\n$ROOT_PASSWORD" | passwd root

# -- Add User-------------------------------------------------------------------
if [ -z "$USER_ID" ] || [ -z "$GROUP_ID" ] ; then
    useradd -m -l -s /bin/bash $USER_NAME
else
    groupadd -o --gid $GROUP_ID $USER_NAME
    useradd -m -l -o -s /bin/bash --uid $USER_ID --gid $GROUP_ID $USER_NAME
    if [ -n "$USER_PASSWORD" ] ; then
        echo -e "$USER_PASSWORD\n$USER_PASSWORD" | passwd $USER_NAME
    fi    
fi

# -- Grant sudo ----------------------------------------------------------------
if [ "$GRANT_SUDO" = "TRUE" ] ; then
    if [ -n "$USER_PASSWORD" ] ; then
        (usermod -aG wheel $USER_NAME)
    else
        (usermod -aG wheelnopw $USER_NAME)
    fi
    # fix output error for rootless containers: See https://github.com/sudo-project/sudo/issues/42
    echo "Set disable_coredump false" >> /etc/sudo.conf # should be removed once sudo > v1.8.31
fi

# -- add user to shared group --------------------------------------------------
if [ "$EMPTYHOME" = "TRUE" ] ; then
    usermod -aG shared $USER_NAME
fi

# -- add passwordless sudo for special entrypoint  ------------------------------
if [ "$DYNAMIC_USERMOD" = "TRUE" ] ; then
    # allow user to run usermod with passwordless sudo and full environment
    USERMODSCRIPT="/opt/build-scripts/usermod.sh"
    SUDOCONFIG="Defaults!"$USERMODSCRIPT" setenv\n$USER_NAME ALL=(root) NOPASSWD: $USERMODSCRIPT"
    echo -e $SUDOCONFIG >> /usr/share/defaults/sudo/sudoers.d/config
    # note: clear linux stores sudo config in  "/usr/share/defaults/sudo/" instead of "/etc" 
fi