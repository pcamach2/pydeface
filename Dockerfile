# Generated by: Neurodocker version 0.7.0
# Latest release: Neurodocker version 0.7.0
# Timestamp: 2022/03/02 21:12:44 UTC
# 
# Thank you for using Neurodocker. If you discover any issues
# or ways to improve this software, please submit an issue or
# pull request on our GitHub repository:
# 
#     https://github.com/ReproNim/neurodocker

FROM debian:stretch

USER root

ARG DEBIAN_FRONTEND="noninteractive"

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    ND_ENTRYPOINT="/neurodocker/startup.sh"
RUN export ND_ENTRYPOINT="/neurodocker/startup.sh" \
    && apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           apt-utils \
           bzip2 \
           ca-certificates \
           curl \
           locales \
           unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG="en_US.UTF-8" \
    && chmod 777 /opt && chmod a+s /opt \
    && mkdir -p /neurodocker \
    && if [ ! -f "$ND_ENTRYPOINT" ]; then \
         echo '#!/usr/bin/env bash' >> "$ND_ENTRYPOINT" \
    &&   echo 'set -e' >> "$ND_ENTRYPOINT" \
    &&   echo 'export USER="${USER:=`whoami`}"' >> "$ND_ENTRYPOINT" \
    &&   echo 'if [ -n "$1" ]; then "$@"; else /usr/bin/env bash; fi' >> "$ND_ENTRYPOINT"; \
    fi \
    && chmod -R 777 /neurodocker && chmod a+s /neurodocker

ENTRYPOINT ["/neurodocker/startup.sh"]

RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           git \
           vim \
           nano \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV FSLDIR="/opt/fsl-6.0.2" \
    PATH="/opt/fsl-6.0.2/bin:$PATH" \
    FSLOUTPUTTYPE="NIFTI_GZ" \
    FSLMULTIFILEQUIT="TRUE" \
    FSLTCLSH="/opt/fsl-6.0.2/bin/fsltclsh" \
    FSLWISH="/opt/fsl-6.0.2/bin/fslwish" \
    FSLLOCKDIR="" \
    FSLMACHINELIST="" \
    FSLREMOTECALL="" \
    FSLGECUDAQ="cuda.q"
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           bc \
           dc \
           file \
           libfontconfig1 \
           libfreetype6 \
           libgl1-mesa-dev \
           libgl1-mesa-dri \
           libglu1-mesa-dev \
           libgomp1 \
           libice6 \
           libxcursor1 \
           libxft2 \
           libxinerama1 \
           libxrandr2 \
           libxrender1 \
           libxt6 \
           sudo \
           wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && echo "Downloading FSL ..." \
    && mkdir -p /opt/fsl-6.0.2 \
    && curl -fsSL --retry 5 https://fsl.fmrib.ox.ac.uk/fsldownloads/fsl-6.0.2-centos6_64.tar.gz \
    | tar -xz -C /opt/fsl-6.0.2 --strip-components 1 \
    && sed -i '$iecho Some packages in this Docker container are non-free' $ND_ENTRYPOINT \
    && sed -i '$iecho If you are considering commercial use of this container, please consult the relevant license:' $ND_ENTRYPOINT \
    && sed -i '$iecho https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/Licence' $ND_ENTRYPOINT \
    && sed -i '$isource $FSLDIR/etc/fslconf/fsl.sh' $ND_ENTRYPOINT \
    && echo "Installing FSL conda environment ..." \
    && bash /opt/fsl-6.0.2/etc/fslconf/fslpython_install.sh -f /opt/fsl-6.0.2

ENV CONDA_DIR="/opt/miniconda-py37_4.11.0" \
    PATH="/opt/miniconda-py37_4.11.0/bin:$PATH"
RUN export PATH="/opt/miniconda-py37_4.11.0/bin:$PATH" \
    && echo "Downloading Miniconda installer ..." \
    && conda_installer="/tmp/miniconda.sh" \
    && curl -fsSL --retry 5 -o "$conda_installer" https://repo.continuum.io/miniconda/Miniconda3-py37_4.11.0-Linux-x86_64.sh \
    && bash "$conda_installer" -b -p /opt/miniconda-py37_4.11.0 \
    && rm -f "$conda_installer" \
    && conda config --system --prepend channels conda-forge \
    && conda config --system --set auto_update_conda false \
    && conda config --system --set show_channel_urls true \
    && sync && conda clean -y --all && sync \
    && conda create -y --channel conda-forge --name neuro \
    && conda install -y --channel conda-forge --name neuro \
           "python=3.7.3" \
           "nipype=1.3.0-rc1" \
           "nibabel=2.5.1" \
           "pytest" \
           "numpy=1.17.1" \
    && sync && conda clean -y --all && sync \
    && bash -c "source activate neuro \
    &&   pip install --no-cache-dir  \
             "pydeface=2.0.0"" \
    && rm -rf ~/.cache/pip/* \
    && sync \
    && sed -i '$isource activate neuro' $ND_ENTRYPOINT

WORKDIR /home/neuro

RUN echo '{ \
    \n  "pkg_manager": "apt", \
    \n  "instructions": [ \
    \n    [ \
    \n      "base", \
    \n      "debian:stretch" \
    \n    ], \
    \n    [ \
    \n      "install", \
    \n      [ \
    \n        "git", \
    \n        "vim", \
    \n        "nano" \
    \n      ] \
    \n    ], \
    \n    [ \
    \n      "fsl", \
    \n      { \
    \n        "version": "6.0.2" \
    \n      } \
    \n    ], \
    \n    [ \
    \n      "miniconda", \
    \n      { \
    \n        "create_env": "neuro", \
    \n        "version": "py37_4.11.0", \
    \n        "env_name": "neuro", \
    \n        "conda_opts": "--channel conda-forge", \
    \n        "conda_install": [ \
    \n          "python=3.7.3", \
    \n          "nipype=1.3.0-rc1", \
    \n          "nibabel=2.5.1", \
    \n          "pytest", \
    \n          "numpy=1.17.1" \
    \n        ], \
    \n        "pip_install": [ \
    \n          "pydeface=2.0.0" \
    \n        ], \
    \n        "activate": true \
    \n      } \
    \n    ], \
    \n    [ \
    \n      "workdir", \
    \n      "/home/neuro" \
    \n    ] \
    \n  ] \
    \n}' > /neurodocker/neurodocker_specs.json
