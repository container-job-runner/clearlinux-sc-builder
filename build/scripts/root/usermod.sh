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

if [ -n "$DYNAMIC_USER" ] && [ -n "$DYNAMIC_UID" ] && [ -n "$DYNAMIC_GID" ] ; then
    groupmod -g $DYNAMIC_GID $DYNAMIC_USER
    usermod -u $DYNAMIC_UID -g $DYNAMIC_GID $DYNAMIC_USER
    chown $DYNAMIC_UID:$DYNAMIC_GID /home/$DYNAMIC_USER # note: avoid recusive chown and add any special directories manually. (this will be faster, and we prevent attempting to chown files in bound volumes)
    exec sudo -E -u $DYNAMIC_USER bash -l -c "$@"
fi