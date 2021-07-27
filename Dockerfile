FROM ubuntu:bionic
LABEL maintainer="bthaleproductions@gmail.com"

# Variables the dockerfile needs
ENV DEBIAN_FRONTEND=noninteractive
ENV QUICKLISP_DIR=/root/quicklisp/local-projects
ENV SBCLRC_LOCATION=/root/.sbclrc

# Update apt
RUN apt update -y
# Install dependencies
RUN apt-get install -yq git sbcl jack rtkit libportaudio2 libportaudiocpp0 portaudio19-dev libportmidi-dev libportmidi0 libsndfile1 libsndfile1-dev libfftw3-dev libfftw3-3 gsl-bin libgsl-dbg libgsl-dev libclthreads2 libclthreads-dev pd lilypond lilypond-data curl

WORKDIR /root/

## Everything below is taken from install-cm-incudine
# Install quicklisp and get it working
RUN pwd && \
    git clone https://github.com/brandflake11/install-cm-incudine.git && \
    ls && \
    cd install-cm-incudine && \
    git checkout docker && \
    curl -O https://beta.quicklisp.org/quicklisp.lisp && \
    sbcl --script install-quicklisp.lisp

# Get incudine installed
RUN git clone git://git.code.sf.net/p/incudine/incudine $QUICKLISP_DIR/incudine && \
    cat /root/.sbclrc && \
    sbcl --quit --eval '(ql::without-prompting (ql:quickload "incudine"))' && \
    cp -v /root/install-cm-incudine/incudinerc ~/.incudinerc

# Get the rest of the cm/orm packages installed
RUN git clone https://github.com/ormf/fudi-incudine.git $QUICKLISP_DIR/fudi-incudine && \
    git clone https://github.com/ormf/cm.git $QUICKLISP_DIR/cm && \
    git clone https://github.com/ormf/cm-incudine.git $QUICKLISP_DIR/cm-incudine && \
    git clone https://github.com/ormf/cm-fomus.git $QUICKLISP_DIR/cm-fomus && \
    git clone https://github.com/ormf/fomus.git $QUICKLISP_DIR/fomus && \
    git clone https://github.com/ormf/cm-utils.git $QUICKLISP_DIR/cm-utils && \
    git clone https://github.com/ormf/orm-utils.git $QUICKLISP_DIR/orm-utils && \
    sbcl --quit --eval '(ql:quickload "cm-incudine")' && \
    echo '(ql:quickload "cm-incudine")' >> $SBCLRC_LOCATION && \
    echo '(ql:quickload "asdf")' >> $SBCLRC_LOCATION && \
    echo '(ql:quickload "fudi")' >> $SBCLRC_LOCATION && \
    echo '(ql:quickload "cl-coroutine")' >> $SBCLRC_LOCATION && \
    echo '(ql:quickload "orm-utils")' >> $SBCLRC_LOCATION && \
    echo "(require 'orm-utils)" >> $SBCLRC_LOCATION && \
    echo '(ql:quickload "fomus")' >> $SBCLRC_LOCATION && \
    echo "(require 'cm-fomus)" >> $SBCLRC_LOCATION && \
    echo '(cm:rts)' >> $SBCLRC_LOCATION && \
    echo '(in-package :scratch)' >> $SBCLRC_LOCATION && \
    sbcl --quit --eval '(cm:rts)'

# Setup FOMUS
RUN ls /root/ && \
    cp -v /root/install-cm-incudine/fomus /root/.fomus

WORKDIR /root/

RUN sbcl

