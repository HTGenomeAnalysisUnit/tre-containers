FROM ghtrecontainers/python-chainguard:latest

LABEL Description="partipy environment"
LABEL Author="Giuditta Clerici"
LABEL Contact="giuditta.clerici@fht.org"
LABEL version="1.0"

COPY environment.yml /tmp/environment.yml

WORKDIR /opt
RUN micromamba install -y -n base -f /tmp/environment.yml && \
    micromamba run -n base pip install -e . && \
    micromamba clean --all --yes

ENTRYPOINT ["micromamba", "run", "-n", "base"]