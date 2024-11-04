FROM cgr.dev/chainguard/conda:latest-dev

LABEL description="Standard Python environment for TRE"
LABEL author="Edoardo Giacopuzzi"
LABEL version="24.9.2"

ARG DEBIAN_FRONTEND=noninteractive
ARG VERSION="24.9.2"

COPY environment.yml /tmp/environment.yml
RUN conda install -y -n base -f /tmp/environment.yml && \
    conda clean --all --yes

ENTRYPOINT ["conda", "run", "-n", "base"]