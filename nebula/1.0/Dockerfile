FROM ubuntu:20.04

LABEL Description="Nebula package for single-cell RNA-seq data analysis"
LABEL Author="Edoardo Giacopuzzi"
LABEL Contact="edoardo.giacopuzzi@fht.org"
LABEL version="1.0"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    ca-certificates \
    git \
    libgsl-dev \
    libhdf5-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    cmake \
    libboost-dev \
    && rm -rf /var/lib/apt/lists/*
    
RUN mkdir /mamba_envs
ENV MAMBA_ROOT_PREFIX=/mamba_envs

WORKDIR /opt
RUN wget https://github.com/mamba-org/micromamba-releases/releases/download/2.0.2-2/micromamba-linux-64 -O /usr/bin/micromamba && \
    chmod +x /usr/bin/micromamba

COPY environment.yml /tmp/environment.yml
RUN micromamba install -y -n base -f /tmp/environment.yml && \
    micromamba clean --all --yes

RUN micromamba run -n base Rscript -e "\
    options(repos = c(CRAN = 'https://cloud.r-project.org')); \
    install.packages('nebula'); \
    if (!requireNamespace('nebula', quietly = TRUE)) stop('nebula install failed'); \
    cat('nebula version:', as.character(packageVersion('nebula')), '\n'); \
    if (!requireNamespace('BPCells', quietly = TRUE)) stop('BPCells install failed'); \
    cat('BPCells version:', as.character(packageVersion('BPCells')), '\n'); \
"

COPY nebula_run_sep.r /usr/local/bin/nebula_run_sep.r
RUN chmod +x /usr/local/bin/nebula_run_sep.r

ENTRYPOINT ["micromamba", "run", "-n", "base"]