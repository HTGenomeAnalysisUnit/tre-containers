FROM ghtrecontainers/python-chainguard:latest

LABEL Description="partipy 0.2.0 container"
LABEL Author="Giuditta Clerici"
LABEL Contact="giuditta.clerici@fht.org"
LABEL version="1.0"

COPY environment.yml /tmp/environment.yml

WORKDIR /opt
RUN micromamba install -y -n base -f /tmp/environment.yml && \
    micromamba clean --all --yes

ENTRYPOINT ["micromamba", "run", "-n", "base"]
