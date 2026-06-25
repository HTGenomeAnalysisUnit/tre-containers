FROM cgr.dev/chainguard/conda:latest-dev

LABEL Description="Standard Python environment for TRE"
LABEL Author="Edoardo Giacopuzzi"
LABEL Contact="edoardo.giacopuzzi@fht.org"
LABEL version="24.9.2"

# Install dependencies useful for compiling
RUN apk add \
	cmake \
	pkgconf \
	glib-dev \
	glibc-dev \
	autoconf \
	automake \
	libstdc++ \
    gcc \
	git \
	wget

RUN mkdir /mamba_envs
ENV MAMBA_ROOT_PREFIX=/mamba_envs

WORKDIR /opt
RUN wget https://github.com/mamba-org/micromamba-releases/releases/download/2.0.2-2/micromamba-linux-64 -O /usr/bin/micromamba && \
    chmod +x /usr/bin/micromamba

ENTRYPOINT ["micromamba", "run", "-n", "base"]