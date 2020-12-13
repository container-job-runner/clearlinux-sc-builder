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
#     LANG_OCTAVE     TRUE => Octave programming language
#     LANG_LATEX      TRUE => Latex installed
#
# ---- Libraries ---------------------------------------------------------------
#     LIB_LINALG      TRUE => Linear algebra libraries BLAS, LAPACK and FFTW
#     LIB_OPENMPI     TRUE => openmpi (loaded using module load mpi)
#     LIB_X11         TRUE => basic x11 libraries and Xvfb
#     LIB_RAY         TRUE => python Ray library
#
# ---- Dev Environemnts --------------------------------------------------------
#     DEV_JUPYTER     TRUE => Jupyter Notebook And Jupyter Lab with support for
#                             all select languages.
#     DEV_THEIA       TRUE -> Theia IDE with support for selected languages.
#     DEV_CLI         TRUE => CLI development tools: git, tmux, vim, emac
#
# ---- Software ----------------------------------------------------------------
#     ASW_SPACK       TRUE => Spack
#     ASW_VNC         TRUE => Tiger VNC
#     ASW_SLURM       TRUE => Slurm
#     ASW_SSHD        TRUE => SSHD
#     ASW_CJR         TRUE => installs cjr inside the container
#
# ---- Additional options ------------------------------------------------------
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
pkg_lang_julia=('wget' 'qt5-dev')
pkg_lang_R=('R-basic' 'R-extras')
pkg_lang_octave=('octave' 'c-basic' 'devpkg-gnutls' 'texinfo') # devpkg-gnutls required for auth in parallel package
pkg_lang_latex=('texlive')

# -- 1.2 Packages: libraries  -------------------------------------------------
pkg_lib_linAlg=('openblas' 'devpkg-fftw')
pkg_lib_openMPI=('openmpi' 'devpkg-openmpi')
pkg_lib_matPlotLib=('python-data-science')
pkg_lib_x11=('x11-tools' 'x11-server')
pkg_lib_ray=('python-data-science' 'c-basic')

# -- 1.3 Packages: development environments   ----------------------------------
pkg_dev_jupyter=('jupyter' 'nodejs-basic')
pkg_dev_theia=('wget' 'git')
pkg_dev_cli=('vim' 'git' 'tmux' 'emacs')

# -- 1.4 Packages: additional software -----------------------------------------
pkg_asw_spack=('c-basic' 'python-basic' 'git' 'curl' 'patch' 'gnupg')
pkg_asw_vnc=('desktop-autostart vnc-server xfce4-desktop')
pkg_asw_sshd=('openssh-server')
pkg_asw_slurm=('cluster-tools')
pkg_asw_cjr=('wget' 'rsync')

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

if [ "$LANG_OCTAVE" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lang_octave[@]}") ; fi

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

if [ "$LIB_RAY" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_lib_ray[@]}") ; fi

# ----> development environments

if [ "$DEV_JUPYTER" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_dev_jupyter[@]}") ; fi

if [ "$DEV_THEIA" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_dev_theia[@]}") ; fi

if [ "$DEV_CLI" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_dev_cli[@]}") ; fi

# ----> additional software

if [ "$ASW_SPACK" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_asw_spack[@]}") ; fi

if [ "$ASW_VNC" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_asw_vnc[@]}") ; fi

if [ "$ASW_SLURM" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_asw_slurm[@]}") ; fi  

if [ "$ASW_CJR" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_asw_cjr[@]}") ; fi

if [ "$ASW_SSHD" = "TRUE" ] ; then
  pkgs=("${pkgs[@]}" "${pkg_asw_sshd[@]}") ; fi

# -- remove redundant elements then install (requires bash 4+) -----------------
declare -A pkgsUniq
for k in ${pkgs[@]} ; do pkgsUniq[$k]=1 ; done

# -- install dependencies ------------------------------------------------------
echo "$pkg_manager bundle-add ${!pkgsUniq[@]}"
eval $pkg_manager bundle-add ${!pkgsUniq[@]}

# == STEP 2: Install Additional Packages =======================================

# -----> Python
if [ "$LANG_PYTHON3" = "TRUE" ] && [ "$LIB_OPENMPI" = "TRUE" ] ; then
    pip3 install mpi4py
fi

# -- Julia ---------------------------------------------------------------------
if [ "$LANG_JULIA" = "TRUE" ] ; then
  mkdir -p /opt
  mkdir -p /usr/local/bin/
  cd /opt
  wget --quiet https://julialang-s3.julialang.org/bin/linux/x64/1.5/julia-1.5.3-linux-x86_64.tar.gz
  tar -xzf julia-1.5.3-linux-x86_64.tar.gz
  mkdir -p /usr/local/bin
  ln -s /opt/julia-1.5.3/bin/julia /usr/local/bin/julia
  rm julia-1.5.3-linux-x86_64.tar.gz
fi

# -- Jupyter -------------------------------------------------------------------
if [ "$DEV_JUPYTER" = "TRUE" ] ; then
  # --> install atom dark theme (https://github.com/container-job-runner/jupyter-atom-theme.git)
  cd /opt
  git clone https://github.com/container-job-runner/jupyter-atom-theme.git
  jupyter labextension install jupyter-atom-theme
  # --> matplotlib Widgets for JupiterLab (https://github.com/matplotlib/jupyter-matplotlib)
  if [ "$LIB_MATPLOTLIB" = "TRUE" ] ; then
    pip3 install ipympl
    pip3 uninstall -y PyQt5 # remove dev version provided with clear linux
    pip3 install PyQt5 # install standard package
    jupyter labextension install @jupyter-widgets/jupyterlab-manager
  fi
  # --> matplotlib Widgets for JupiterLab (https://github.com/matplotlib/jupyter-matplotlib)
  if [ "$LANG_LATEX" = "TRUE" ] ; then
    # --> Latex for JupyterLab (https://github.com/jupyterlab/jupyterlab-latex)
    pip3 install jupyterlab_latex                     # remove fix and uncomment once extension is fixed
    jupyter labextension install @jupyterlab/latex    # remove fix and uncomment once extension is fixed
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
  if [ "$DEV_CLI" = "TRUE" ] ; then
    pip3 install --upgrade jupyterlab jupyterlab-git
    jupyter lab build
  fi
  # if [ "$LANG_FORTRAN" = "TRUE" ] ; then
  #   # possible options to add later:
  #   # 1. fortran coarrays   https://github.com/sourceryinstitute/OpenCoarrays/blob/master/INSTALL.md
  #   # 2. lfortran:          https://lfortran.org/ https://docs.lfortran.org/installation/
  #   # 3. fortran_magic      https://github.com/mgaitan/fortran_magic
  # fi
fi

# -----> Octave
if [ "$LANG_OCTAVE" = "TRUE" ] ; then
    octave --no-gui --no-window-system --eval 'pkg install -global -forge struct'
    octave --no-gui --no-window-system --eval 'pkg install -global -forge parallel' 
    if [ "$LIB_OPENMPI" = "TRUE" ] ; then  
        # Once https://github.com/carlodefalco/octave-mpi/issues/4 is resolved
        # --> Update url and uncomment:        
        # octave --eval 'pkg install -global https://github.com/carlodefalco/octave-mpi/releases/download/v3.1.0/mpi-3.1.0.tar.gz'        
        # --> remove section below ---------------------------------------------
        cd /opt
        OCTAVE_MPI_DIR="octave-mpi"
        git clone https://github.com/carlodefalco/octave-mpi.git $OCTAVE_MPI_DIR
        cd $OCTAVE_MPI_DIR
        git checkout d220cdd824cb6f757a6af513ee470a8e60a14153
        rm -rf .git
        cd ../
        tar czf "$OCTAVE_MPI_DIR.tar.gz" $OCTAVE_MPI_DIR
        rm -rf $OCTAVE_MPI_DIR
        octave --no-gui --no-window-system --eval "pkg install -global octave-mpi.tar.gz"
        # ----------------------------------------------------------------------
    fi
fi

# -----> Ray
if [ "$LIB_RAY" = "TRUE" ] ; then
    pip3 install ray
fi

# -- Theia ---------------------------------------------------------------------
if [ "$DEV_THEIA" = "TRUE" ] ; then
    # --> On Clear linux, Theia looks for git in /usr/bin/bin/git
    mkdir -p /usr/bin/bin/
    ln -s /usr/bin/git /usr/bin/bin/git

    if [ "$LANG_PYTHON3" = "TRUE" ] ; then
        pip3 install pylint
    fi
fi

# -- cjr -----------------------------------------------------------------------
if [ "$ASW_CJR" = "TRUE" ] ; then
    cd /opt
    wget --quiet https://github.com/container-job-runner/cjr/releases/download/v0.4.1-alpha/cjr-v0.4.1-linux-x64.tar.gz
    tar -xzf cjr-v0.4.1-linux-x64.tar.gz
    mkdir -p /usr/local/bin
    ln -s /opt/cjr/bin/cjr /usr/local/bin/cjr
    rm cjr-v0.4.1-linux-x64.tar.gz
fi