ARG DEV_THEIA
ARG THEIA_INSTALL_DIR=/opt/theia

# == 1. build stage: Theia =====================================================
FROM clearlinux:latest as theia_builder
ARG DEV_THEIA
ARG THEIA_INSTALL_DIR
WORKDIR /root/theia
RUN if [ "$DEV_THEIA" = "TRUE" ] ; then \
    swupd bundle-add 'wget' 'curl' 'python-basic' 'c-basic' ; \
    # --> install nvm (note there is no .bashrc in clearlinux for root, so manually load nvm)
    export HOME=/root ; \
    export NVM_DIR="${HOME}/.nvm" ; \
    curl --silent -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash ; \
    # ----> load nvm
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" ; \
    # --> install latest node 10 (dubnium)
    nvm install lts/dubnium ; \
    nvm use lts/dubnium ; \
    # --> install yarn
    npm install -g yarn ; \
    wget https://github.com/container-job-runner/stack-config-files/releases/download/0.1.4-alpha/package.json ; \
    wget https://github.com/container-job-runner/stack-config-files/releases/download/0.1.4-alpha/yarn.lock ; \
    yarn --cache-folder ./ycache ; \
    rm -rf ./ycache ; \
    yarn theia build ; \
    yarn theia download:plugins ; \
    fi
RUN echo -e '#!/bin/bash\nyarn --cwd '$THEIA_INSTALL_DIR' start $@' > /root/theia_launcher ; \
    chmod a+x /root/theia_launcher ;

# == 2. build stage: Octave Dev Libraries ======================================
FROM clearlinux:latest as octave_devel_builder
ARG LANG_OCTAVE
COPY octave-5.2.0.tar.gz /usr/include
WORKDIR /usr/include
RUN if [ "$LANG_OCTAVE" = "TRUE" ] ; then \
    tar -xzf /usr/include/octave-5.2.0.tar.gz ; \
    rm /usr/include/octave-5.2.0.tar.gz ; \
    fi

# == 3. main Dockerfile: Clear Linux ===========================================
FROM clearlinux:latest

# ----> ARGS: languages
ARG LANG_C
ARG LANG_FORTRAN
ARG LANG_PYTHON3
ARG LANG_JULIA
ARG LANG_R
ARG LANG_OCTAVE
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
# ----> ARGS: additional software
ARG ASW_SPACK
ARG ASW_VNC
ARG ASW_CJR
# ----> ARGS: additional options
ARG EMPTYHOME
ARG THEIA_INSTALL_DIR

# -- copy root install files to /opt/build-scripts -----------------------------
RUN mkdir -p /opt/build-scripts/
WORKDIR /opt/build-scripts
COPY scripts/root/ ./
RUN chmod -R +x ./
# -- install root dependencies -------------------------------------------------
COPY --from=octave_devel_builder /usr/include/octave-5.2.0 /usr/include/octave-5.2.0
RUN ./install.sh
COPY --from=theia_builder /root/theia $THEIA_INSTALL_DIR
COPY --from=theia_builder /root/theia_launcher /usr/local/bin/theia

# ----> ARGS: user (placed here to prevent full rebuild)
ARG USER_NAME=user
ARG USER_PASSWORD
ARG GRANT_SUDO=false
ARG USER_ID
ARG GROUP_ID
ARG ROOT_PASSWORD
ARG DYNAMIC_USERMOD

# -- Generate restricted user account ------------------------------------------
RUN /opt/build-scripts/user-create.sh

# -- copy user install scripts to ~/.build-scripts -----------------------------
RUN mkdir "/home/$USER_NAME/.build-scripts"
WORKDIR "/home/$USER_NAME/.build-scripts"
COPY scripts/user/ ./
RUN chown -R $USER_ID:$GROUP_ID ./
USER $USER_NAME
RUN chmod -R +x ./
# -- install user dependencies -------------------------------------------------
RUN ./install.sh

# -- install extra root dependencies (placed here to prevent full rebuild) -----
USER 0
RUN /opt/build-scripts/install-extra.sh

# -- install extra user dependencies (placed here to prevent full rebuild) -----
USER $USER_NAME
RUN /home/$USER_NAME/.build-scripts/install-extra.sh

WORKDIR "/home/$USER_NAME"
ENTRYPOINT [ "/opt/build-scripts/entrypoint.sh"]