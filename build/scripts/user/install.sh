#!/bin/bash

# -- USER INSTALL SCRIPT -------------------------------------------------------
# Installs dependencies for Fedora using the dnf package manager and additional
# manual installations. This script installs all the dependancies as a standard
# user. It responds to the following environmental variables:
#
# ---- languages ---------------------------------------------------------------
#     LANG_C          TRUE => C language packages installed
#     LANG_FORTRAN    TRUE => Fortran language installed
#     LANG_PYTHON3    TRUE => Python3 language installed
#     LANG_JULIA      TRUE => Julia language installed
#     LANG_R          TRUE => R languag installed
#     LANG_LATEX      TRUE => Latex installed
#
# ---- libraries ---------------------------------------------------------------
#
# ---- Dev Environemnts --------------------------------------------------------
#     DEV_JUPYTER     TRUE => Jupyter Notebook And Jupyter Lab with support for
#                             all select languages.
#     DEV_THEIA       TRUE -> Theia IDE with support for selected languages.
#     DEV_CLI         TRUE => CLI development tools: git, tmux, vim, emac
# ---- Package Managers --------------------------------------------------------
#     ASW_SPACK      TRUE => Spack
#
# NOTE: Additional dependancies can be placed in the script
# user_install_extra.sh or written directly within this bash script.
# ------------------------------------------------------------------------------

# -- Julia packages ------------------------------------------------------------
if [ "$LANG_JULIA" = "TRUE" ] && [ "$EMPTYHOME" = "TRUE" ] ; then
    export JULIA_DEPOT_PATH=/opt/shared/julia-depot # change default package install directory
fi

if [ "$LANG_JULIA" = "TRUE" ] ; then
    # ----> plotters
    if [ "$LIB_MATPLOTLIB" = "TRUE" ] ; then
        julia -e 'import Pkg; Pkg.add("PyPlot"); using PyPlot'
    fi
    julia -e 'import Pkg; Pkg.add("GR"); using GR'
    julia -e 'import Pkg; Pkg.add("UnicodePlots"); using UnicodePlots'
    julia -e 'import Pkg; Pkg.add("Plots"); using Plots'
    julia -e 'import Pkg; Pkg.add("LaTeXStrings"); using LaTeXStrings'
    # ----> debug and language server
    julia -e 'import Pkg; Pkg.add("LanguageServer"); using LanguageServer'
    julia -e 'import Pkg; Pkg.add("JuliaInterpreter"); using JuliaInterpreter'

    # ----> fix permissions for non-local folders (see: https://github.com/JuliaLang/julia/issues/12876)
    if [ "$EMPTYHOME" = "TRUE" ] ; then
        chmod -R g+w $JULIA_DEPOT_PATH/*
    fi
fi

# -- Juputer Kernels -----------------------------------------------------------
if [ "$DEV_JUPYTER" = "TRUE" ] ; then
  # ----> Julia
  if [ "$LANG_JULIA" = "TRUE" ] ; then
    julia -e 'import Pkg; Pkg.add("IJulia")'
  fi
  # ----> R
  if [ "$LANG_R" = "TRUE" ] ; then
    R -e "IRkernel::installspec()"
  fi
fi

# -- Spack ---------------------------------------------------------------------
if [ "$ASW_SPACK" = "TRUE" ] ; then
  mkdir -p ~/.local
  mkdir -p ~/.local/bin
  git clone https://github.com/spack/spack.git ~/.local/spack
  ln -s ~/.local/spack/bin/spack ~/.local/bin/spack
  echo 'PATH=$PATH:~/.local/bin/' >> ~/.bashrc
fi

# -- Theia ---------------------------------------------------------------------
if [ "$DEV_THEIA" = "TRUE" ] ; then
    if [ "$EMPTYHOME" = "TRUE" ] ; then
        export NVM_DIR=/opt/shared/nvm # change default package install directory
    fi    
    # ----> install nvm (https://github.com/nvm-sh/nvm)
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
    source ~/.bashrc
    # ---> install nvm
    nvm install lts/dubnium
    nvm use lts/dubnium
    # ---> install yarn
    if [ "$EMPTYHOME" = "TRUE" ] ; then
        npm config set cache /opt/shared/npm
    fi
    npm install -g yarn
    # ----> fix permissions for non-local folders (see: https://github.com/JuliaLang/julia/issues/12876)
    if [ "$EMPTYHOME" = "TRUE" ] ; then
        chmod -R g+w $NVM_DIR/* /opt/shared/npm/*
    fi
fi