FROM cgr.dev/chainguard/conda:latest-dev

LABEL description="Standard Python environment for TRE"
LABEL author="Edoardo Giacopuzzi"
LABEL version="24.9.2"

RUN mkdir /mamba_envs
ENV MAMBA_ROOT_PREFIX=/mamba_envs

WORKDIR /opt
RUN wget https://github.com/mamba-org/micromamba-releases/releases/download/2.0.2-2/micromamba-linux-64 -O /usr/local/bin/micromamba && \
    chmod +x /usr/local/bin/micromamba

COPY environment.yml /tmp/environment.yml
RUN micromamba install -y -n base -f /tmp/environment.yml && \
    micromamba clean --all --yes

ENTRYPOINT ["micromamba", "run", "-n", "base"]