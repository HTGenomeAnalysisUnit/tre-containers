FROM ghtrecontainers/python-chainguard:latest

LABEL description="Multimil Python environment"
LABEL author="Edoardo Giacopuzzi"
LABEL version="0.2.0"

COPY environment.yml /tmp/environment.yml
RUN micromamba install -y -n base -f /tmp/environment.yml && \
    micromamba clean --all --yes

ENTRYPOINT ["micromamba", "run", "-n", "base"]