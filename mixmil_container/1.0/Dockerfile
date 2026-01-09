FROM ghtrecontainers/python-chainguard:latest

LABEL Description="MixMIL environment"
LABEL Author="Giuditta Clerici"
LABEL Contact="giuditta.clerici@fht.org"
# Match the version label to the container version tag
LABEL version="1.0"

COPY environment.yml /tmp/environment.yml
RUN micromamba install -y -n base -f /tmp/environment.yml && \
    conda activate mixmil_envf3 \
    git clone https://github.com/AIH-SGML/mixmil.git && cd mixmil && git checkout jan-dev && pip install -e . && cd .. \
    micromamba clean --all --yes

ENTRYPOINT ["micromamba", "run", "-n", "base"]