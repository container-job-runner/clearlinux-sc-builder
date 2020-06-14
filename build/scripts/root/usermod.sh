#!/bin/bash
  
# ==============================================================================
# This script looks for the environment variables 
#   $DYNAMIC_USER  - user that should be dynamicall modified
#   $DYNAMIC_UID   - desired user id
#   $DYNAMIC_GID.  - desired group id
# If they are present, the script will:
#   1. Modifiy the user/group id of $DYNAMIC_USER to $DYNAMIC_UID and $DYNAMIC_GID
#   2. Execute a bash command as $DYNAMIC_USER using all passed args 
# NOTE: this script should be run by root
# ==============================================================================

USER_CHANGE="FALSE"

# -- modify user group id ------------------------------------------------------
if [ -n "$DYNAMIC_USER" ] && [ -n "$DYNAMIC_GID" ] && [ "$(id -g)" != "$DYNAMIC_GID" ] ; then
    groupmod -g $DYNAMIC_GID $DYNAMIC_USER
    USER_CHANGE="TRUE"
fi

# -- modify user id ------------------------------------------------------------
if [ -n "$DYNAMIC_USER" ] && [ -n "$DYNAMIC_UID" ] && [ "$(id -u)" != "$DYNAMIC_UID" ] ; then
    usermod -u $DYNAMIC_UID -g $DYNAMIC_GID $DYNAMIC_USER
    USER_CHANGE="TRUE"
fi

# -- chown files ---------------------------------------------------------------
# note: avoid recusive chown. Instead add any special directories manually since
# this will be faster, and it prevents chowning files in bound volumes
if [ "$USER_CHANGE" = "TRUE" ] && [ -n "$DYNAMIC_UID" ] && [ -n "$DYNAMIC_GID" ] ; then
    chown $DYNAMIC_UID:$DYNAMIC_GID /home/$DYNAMIC_USER
fi

# -- start new shell for user --------------------------------------------------
if [ -n "$DYNAMIC_USER" ] ; then
    exec sudo -E -u $DYNAMIC_USER bash -l -c "$@"
fi