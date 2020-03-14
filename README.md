# stack-clear-basic
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/gitbucket/gitbucket/blob/master/LICENSE)

A cjr stack based on Clear Linux and swupd.

## Installation

To use use this stack with cjr simply run the command
`cjr stack:pull https://github.com/container-job-runner/stack-ubuntu-basic.git`
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
3. **dev environments**
   - Jupyter notebook, Jupyter lab
   - vim, git, vim, emacs, tmux
4. **Package Managers**
   - spack

Note: configuration for Jupyter is stored in a bound folder inside the stack directory.

## Customization

**By default this stack does not install any dependencies**. By editing the args in config.yml and setting fields to `TRUE` you can enable any of the items listed above. After changing the params you will need to rebuild the stack (e.g. `cjr stack:build stack-clear-basic`)

Additional dependencies can be installed by modifying the files
- build-scripts/root_install_extra.sh
- build-scripts/user_install_extra.sh

To modify the package install process, modify the files
- build-scripts/root_install.sh
- build-scripts/user_install.sh

Finally, the non-root user's username, password, and sudo privileges can be modified by adjusting the user args in config.yml
