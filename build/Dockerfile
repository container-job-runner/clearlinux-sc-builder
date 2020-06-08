FROM clearlinux:latest

# ----> ARGS: languages
ARG LANG_C
ARG LANG_FORTRAN
ARG LANG_PYTHON3
ARG LANG_JULIA
ARG LANG_R
ARG LANG_LATEX
# ----> ARGS: libraries
ARG LIB_MATPLOTLIB
ARG LIB_LINALG
ARG LIB_OPENMPI
ARG LIB_X11
# ----> ARGS: dev environemnts
ARG DEV_JUPYTER
ARG DEV_THEIA
ARG DEV_CLI
# ----> ARGS: package managers
ARG PKGM_SPACK
# ----> ARGS: additional options
ARG EMPTYHOME

# -- copy root install files to /opt/build-scripts -----------------------------
RUN mkdir -p /opt/build-scripts/
WORKDIR /opt/build-scripts
COPY scripts/root/ ./
RUN chmod +x install.sh install-extra.sh user-create.sh 
# -- install root dependencies -------------------------------------------------
RUN ./install.sh

# ----> ARGS: user (placed here to prevent full rebuild)
ARG USER_NAME=user
ARG USER_PASSWORD=password
ARG GRANT_SUDO=false
ARG USER_ID
ARG GROUP_ID

# -- Generate restricted user account ------------------------------------------
RUN /opt/build-scripts/user-create.sh

# -- copy user install scripts to ~/.build-scripts -----------------------------
RUN mkdir "/home/$USER_NAME/.build-scripts"
WORKDIR "/home/$USER_NAME/.build-scripts"
COPY scripts/user/ ./
RUN chown $USER_ID:$GROUP_ID install.sh install-extra.sh
USER $USER_NAME
RUN chmod +x install.sh install-extra.sh
# -- install user dependencies -------------------------------------------------
RUN ./install.sh

# -- install extra root dependencies (placed here to prevent full rebuild) -----
USER 0
RUN /opt/build-scripts/install-extra.sh

# -- install extra user dependencies (placed here to prevent full rebuild) -----
USER $USER_NAME
RUN /home/$USER_NAME/.build-scripts/install-extra.sh

WORKDIR "/home/$USER_NAME"
ENTRYPOINT ["bash", "-l", "-c"]