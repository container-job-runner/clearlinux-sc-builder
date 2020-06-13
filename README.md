# stack-clear-basic
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/gitbucket/gitbucket/blob/master/LICENSE)

A cjr stack based on Clear Linux and swupd.

## Installation

To use use this stack with cjr simply run the command
`cjr stack:pull https://github.com/container-job-runner/stack-clear-basic.git`
or manually clone the repository into your cjr stacks directory.

## Description

This stack creates a non-root user with matching user id and group id as the host user, and uses swupd to install basic support for any subset of the following:

1. **Languages**
   - c, c++
   - Fortran
   - Python 3
   - Julia
   - R
   - latex
2. **Libraries**
   - Matplotlib
   - BLAS, LAPACK
   - OPENMPI
   - X11
3. **dev environments**
   - Jupyter notebook, JupyterLab
   - Theia
   - vim, git, vim, emacs, tmux
4. **Package Managers**
   - spack

Configurations for Jupyter and Theia are respectively stored the directories config/jupyter and config/theia which are bound to ~/.jupyter and ~/.theia in the container.

## Customization

**By default this stack does not install any dependencies**. By editing the args in config.yml and setting fields to `TRUE` you can enable any of the items listed above. After changing the params you will need to rebuild the stack (e.g. `cjr stack:build stack-clear-basic`)

Additional dependencies can be installed by modifying the files
- build/scripts/root/install-extra.sh
- build/scripts/user/install-extra.sh

To modify the package install process, modify the files
- build/scripts/root/install.sh
- build/scripts/user/install.sh

**Profiles:** 
This stack contains the following profiles:
- all : installs everything.
- dynamic: enables dynamic uid and gid on container startup to match host user.
- *LANGUAGE*-*IDE* where LANGUAGE can be either 'fortran', 'python', or 'julia' and IDE can be 'jupyter' or 'theia'.

**Theia Plugins:**  
Additional plugins can be installed by adding .vsix extension files to the directory config/theia/plugins. VS Code Python, C/C++, and Fortran plugins are already included.

**Container User Settings:**
Finally, the container user's username, password, and sudo privileges can be modified by adjusting the user args in config.yml