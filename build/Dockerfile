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
RUN mkdir -p /opt/build-scripts
WORKDIR /opt/build-scripts
COPY scripts/root-install.sh scripts/root-install-extra.sh scripts/user-create.sh ./
RUN chmod +x root-install.sh root-install-extra.sh user-create.sh
# -- install root dependencies -------------------------------------------------
RUN ./root-install.sh

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
COPY scripts/user-install.sh scripts/user-install-extra.sh ./
RUN chown $USER_ID:$GROUP_ID user-install.sh user-install-extra.sh
USER $USER_NAME
RUN chmod +x user-install.sh user-install-extra.sh
# -- install user dependencies -------------------------------------------------
RUN ./user-install.sh

# -- install extra root dependencies (placed here to prevent full rebuild) -----
USER 0
RUN /opt/build-scripts/root-install-extra.sh

# -- install extra user dependencies (placed here to prevent full rebuild) -----
USER $USER_NAME
RUN /home/$USER_NAME/.build-scripts/user-install-extra.sh

WORKDIR "/home/$USER_NAME"
ENTRYPOINT ["bash", "-l", "-c"]