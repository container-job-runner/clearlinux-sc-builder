#!/bin/bash

# -- USER CREATE SCRIPT -------------------------------------------------------
# Adds a non root user and enables sudo permissions for entrypoint usermod 
# script. The script responds to the following environmental variables:
#
#     USER_ID           ID for new linux user
#     GROUP_ID          Group ID for new linux user
#     USER_NAME         username for new linux user
#     USER_PASSWORD     password for new linux user
#     GRANT_SUDO        if "PASSWORDLESS" or TRUE" then the new linux user will 
#                       have sudo privilages. PASSWORDLESS enables passwordless 
#                       sudo, TRUE enables password-based sudo unless password 
#                       is empty in which case it grades passwordless sudo.
# ------------------------------------------------------------------------------
#     EMPTYHOME       if "TRUE" then the user will be added to group "shared"
#     DYNAMIC_USER    if "TRUE" then passwordless execution is enabled for 
#                     usermod script "/opt/build-scripts/usermod.sh"
# ------------------------------------------------------------------------------

# Change Root Password or Docker/Podman cannot execute USER root after USER $USER_NAME
echo -e "$ROOT_PASSWORD\n$ROOT_PASSWORD" | passwd root

# -- Add User-------------------------------------------------------------------
if [ -z "$USER_ID" ] || [ -z "$GROUP_ID" ] ; then
    useradd -m -l -s /bin/bash $USER_NAME
else
    groupadd -o --gid $GROUP_ID $USER_NAME
    useradd -m -l -o -s /bin/bash --uid $USER_ID --gid $GROUP_ID $USER_NAME  
fi

# -- Set User Password ---------------------------------------------------------
if [ -n "$USER_PASSWORD" ] ; then
    echo -e "$USER_PASSWORD\n$USER_PASSWORD" | passwd $USER_NAME
fi 

# -- Grant sudo ----------------------------------------------------------------
# passwordless sudo granted if either condition is true:
#   (1) GRANT_SUDO=PASSWORDLESS
#   (2) GRANT_SUDO=TRUE and USER_PASSWORD empty
if [[ "$GRANT_SUDO" = "PASSWORDLESS" ||  ( "$GRANT_SUDO" = "TRUE" && -z "$USER_PASSWORD" ) ]] ; then    
    usermod -aG wheelnopw $USER_NAME
elif [ "$GRANT_SUDO" = "TRUE" ] ; then
    usermod -aG wheel $USER_NAME
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
    mkdir -p /etc/sudoers.d
    echo -e $SUDOCONFIG >> /etc/sudoers.d/config
    # note: clear linux stores system sudo config in "/usr/share/defaults/sudo/sudoers"
    # this file has "#includedir /etc/sudoers.d" for user modifications
fi