FROM ghtrecontainers/python-chainguard:latest

LABEL Description="partipy container"
LABEL Author="Giuditta Clerici"
LABEL Contact="giuditta.clerici@fht.org"
LABEL version="2.0"

COPY environment.yml /tmp/environment.yml

WORKDIR /opt
RUN micromamba install -y -n base -f /tmp/environment.yml && \
    micromamba clean --all --yes

ENTRYPOINT ["micromamba", "run", "-n", "base"]
