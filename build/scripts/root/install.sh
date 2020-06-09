#!/bin/bash

# -- ROOT INSTALL SCRIPT -------------------------------------------------------
# Installs dependencies for Clear linux using the swupd package manager and 
# additional manual installations. This script will be executed by root.
# It responds to the following environmental variables:
#
# ---- Languages ---------------------------------------------------------------
#     LANG_C          TRUE => C language packages installed
#     LANG_FORTRAN    TRUE => Fortran language installed
#     LANG_PYTHON3    TRUE => Python3 language installed
#     LANG_JULIA      TRUE => Julia language installed
#     LANG_R          TRUE => R languag installed
#     LANG_LATEX      TRUE => Latex installed
#
# ---- Libraries ---------------------------------------------------------------
#     LIB_LINALG      TRUE => Linear algebra libraries BLAS, LAPACK and FFTW
#     LIB_OPENMPI     TRUE => openmpi (loaded using module load mpi)
#
# ---- Dev Environemnts --------------------------------------------------------
#     DEV_JUPYTER     TRUE => Jupyter Notebook And Jupyter Lab with support for
#                             all select languages.
#
# ---- Additional options ------------------------------------------------------
#      EMPTYHOME      TRUE => directories will be created for storing program
#                             data in the /opt/shared directory instead of ~/
#                             and a new group will be created for ownership.
#
# NOTE: To add extra dependancies for any language, library, or development
# environment that can be installed with swupd simply add an entry to the arrays
# in 1.1-1.3. More sophisticated dependancies can be placed in the script
# root_install_extra.sh or written within this bash script.
# ------------------------------------------------------------------------------

pkg_manager="swupd"

# == STEP 1: Install packages ==================================================

# -- 1.1 Packages: languages ---------------------------------------------------
pkg_lang_c=('c-basic' 'gdb');
pkg_lang_fortran=('c-basic' 'gdb');
pkg_lang_python3=('python3-basic' 'python-data-science')
pkg_lang_julia=('wget')
pkg_lang_R=('R-basic' 'R-extras')
pkg_lang_latex=('texlive')

# -- 1.2 Packages: libraries  -------------------------------------------------
pkg_lib_linAlg=('openblas' 'devpkg-fftw')
pkg_lib_openMPI=('openmpi')
pkg_lib_matPlotLib=('python-data-science')
pkg_lib_x11=('x11-tools')

# -- 1.3 Packages: development environments   ----------------------------------
pkg_dev_jupyter=('jupyter')
pkg_dev_theia=('wget' 'musl')
pkg_dev_cli=('vim' 'git' 'tmux' 'emacs')

# -- Add packages to pkgs array ------------------------------------------------
declare -a pkgs=('sudo' 'sysadmin-basic'); # basic packages required for usage

# ----> languages

if [ "$LANG_C" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lang_c[@]}") ; fi

if [ "$LANG_FORTRAN" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lang_fortran[@]}") ; fi

if [ "$LANG_PYTHON3" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lang_python3[@]}") ; fi

if [ "$LANG_JULIA" = "TRUE" ] ; then
pkgs=("${pkgs[@]}" "${pkg_lang_julia[@]}") ; fi

if [ "$LANG_R" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lang_R[@]}") ; fi

if [ "$LANG_LATEX" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lang_latex[@]}") ; fi

# ----> libraries

if [ "$LIB_LINALG" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lib_linAlg[@]}") ; fi

if [ "$LIB_OPENMPI" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lib_openMPI[@]}") ; fi

if [ "$LIB_MATPLOTLIB" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lib_matPlotLib[@]}") ; fi

if [ "$LIB_X11" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lib_x11[@]}") ; fi

# ----> development environments

if [ "$DEV_JUPYTER" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_dev_jupyter[@]}") ; fi

if [ "$DEV_THEIA" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_dev_theia[@]}") ; fi

if [ "$DEV_CLI" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_dev_cli[@]}") ; fi

# -- remove redundant elements then install (requires bash 4+) -----------------
declare -A pkgsUniq
for k in ${pkgs[@]} ; do pkgsUniq[$k]=1 ; done

# -- install dependencies ------------------------------------------------------
echo "$pkg_manager bundle-add ${!pkgsUniq[@]}"
eval $pkg_manager bundle-add ${!pkgsUniq[@]}

# == STEP 2: Install Additional Packages =======================================

# -- create folder and associated group for storing app files ------------------
# This allows for rapid user id manipulation using usermod, since files are not
# stored in home directory
if [ "$EMPTYHOME" = "TRUE" ] ; then
    mkdir -p /opt/shared/
    mkdir -p /opt/shared/julia-depot # directory that will be used in place of ~/.julia
    mkdir -p /opt/shared/{nvm,npm} # directory that will be used in place of ~/.nvm and ~/.npm
    groupadd shared
    chgrp -R shared /opt/shared/
    chmod -R 2775 /opt/shared/
fi

# -- Julia ---------------------------------------------------------------------
if [ "$LANG_JULIA" = "TRUE" ] ; then
  mkdir -p /opt
  mkdir -p /usr/local/bin/
  cd /opt
  wget --quiet https://julialang-s3.julialang.org/bin/linux/x64/1.4/julia-1.4.2-linux-x86_64.tar.gz
  tar -xzf julia-1.4.2-linux-x86_64.tar.gz
  ln -s /opt/julia-1.4.2/bin/julia /usr/local/bin/julia
  rm julia-1.4.2-linux-x86_64.tar.gz
fi

# -- Jupyter -------------------------------------------------------------------
if [ "$DEV_JUPYTER" = "TRUE" ] ; then
  pip3 install jupyterlab # Jupyter Lab
  # --> install atom dark theme (https://github.com/container-job-runner/jupyter-atom-theme.git)
  cd /opt
  git clone https://github.com/container-job-runner/jupyter-atom-theme.git
  jupyter labextension install jupyter-atom-theme
  # --> matplotlib Widgets for JupiterLab (https://github.com/matplotlib/jupyter-matplotlib)
  if [ "$LIB_MATPLOTLIB" = "TRUE" ] ; then
    pip3 install ipympl
    jupyter labextension install @jupyter-widgets/jupyterlab-manager
    jupyter labextension install jupyter-matplotlib
  fi
  if [ "$LANG_LATEX" = "TRUE" ] ; then
    # --> Latex for JupyterLab (https://github.com/jupyterlab/jupyterlab-latex)
    pip3 install jupyterlab_latex
    jupyter labextension install @jupyterlab/latex
  fi
  if [ "$LANG_C" = "TRUE" ] ; then
    # --> C Kernel for Jypyter https://github.com/brendan-rius/jupyter-c-kernel
    pip3 install jupyter-c-kernel
    install_c_kernel --user
  fi
  if [ "$LANG_R" = "TRUE" ] ; then
    # --> R Kernel for Jupyter (https://irkernel.github.io/installation/)
    R -e 'r = getOption("repos"); r["CRAN"] = "https://cloud.r-project.org/"; install.packages(c("repr", "IRdisplay", "IRkernel"), repos = r, type = "source");'
  fi
  # if [ "$LANG_FORTRAN" = "TRUE" ] ; then
  #   # possible options to add later:
  #   # 1. fortran coarrays   https://github.com/sourceryinstitute/OpenCoarrays/blob/master/INSTALL.md
  #   # 2. lfortran:          https://lfortran.org/ https://docs.lfortran.org/installation/
  #   # 3. fortran_magic      https://github.com/mgaitan/fortran_magic
  # fi
fi

# -- Theia ---------------------------------------------------------------------
if [ "$DEV_THEIA" = "TRUE" ] ; then
    # add symbolic link for standard muscl library location, then install python2 libs
    # for the moment, it appers that python2-basic must be installed after creating symbolic link or theia will start with error
    ln -s /usr/lib64/musl/lib64/libc.so /lib/libc.musl-x86_64.so.1
    swupd bundle-add python2-basic
    # --> create launcher
    THEIA_INSTALL_DIR=/opt/theia # assumed location of theia
    mkdir -p /usr/local/bin/
    echo -e '#!/bin/bash\nyarn --cwd '$THEIA_INSTALL_DIR' start $@' > /usr/local/bin/theia
    chmod a+x "/usr/local/bin/theia"
fi