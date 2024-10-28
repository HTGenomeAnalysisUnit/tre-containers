FROM mambaorg/micromamba:2.0.2

LABEL description="Standard Python environment for TRE"
LABEL author="Edoardo Giacopuzzi"
LABEL version="20241011"

ARG DEBIAN_FRONTEND=noninteractive
ARG VERSION="20241011"

COPY --chown=$MAMBA_USER:$MAMBA_USER environment.yml /tmp/environment.yml
RUN micromamba install -y -n base -f /tmp/environment.yml && \
    micromamba clean --all --yes

ENTRYPOINT ["micromamba", "run", "-n", "base"]