FROM ghtrecontainers/python-chainguard:latest

LABEL Description="MixMIL environment"
LABEL Author="Giuditta Clerici"
LABEL Contact="giuditta.clerici@fht.org"
LABEL version="1.0"

COPY environment.yml /tmp/environment.yml
RUN micromamba install -y -n base -f /tmp/environment.yml && \
    micromamba clean --all --yes

ENTRYPOINT ["micromamba", "run", "-n", "base"]