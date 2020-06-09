#!/bin/bash

# ==============================================================================
# This script is the default entrypoint for this image
# ==============================================================================

if [ -n "$DYNAMIC_USER" ] && [ -n "$DYNAMIC_UID" ] && [ -n "$DYNAMIC_GID" ] ; then
    exec sudo -E /opt/build-scripts/usermod-entrypoint.sh "$@"
else
    exec /bin/bash -l -c "$@" # equivalent to ENTRYPOINT ["/bin/bash", "-l", "-c"]
fi