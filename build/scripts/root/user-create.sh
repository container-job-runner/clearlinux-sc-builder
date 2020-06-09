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
fi

# -- add user to shared group --------------------------------------------------
if [ "$EMPTYHOME" = "TRUE" ] ; then
    usermod -aG shared $USER_NAME
fi