FROM mambaorg/micromamba:2.0.2

LABEL description="Basic Python environment for TRE"
LABEL author="Edoardo Giacopuzzi"
LABEL version="0.2.0"

ARG DEBIAN_FRONTEND=noninteractive
ARG VERSION="20241011"

USER root
RUN mkdir -p /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log
RUN apt-get update && \
    apt-get -y install build-essential \
    && apt-get -y clean all \
    && rm -rf /var/cache

USER $MAMBA_USER
COPY --chown=$MAMBA_USER:$MAMBA_USER environment.yml /tmp/environment.yml
RUN micromamba install -y -n base -f /tmp/environment.yml && \
    micromamba clean --all --yes

ENTRYPOINT ["micromamba", "run", "-n", "base"]