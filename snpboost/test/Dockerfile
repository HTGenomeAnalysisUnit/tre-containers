FROM ghtrecontainers/rstudio-chainguard:latest

LABEL Description="snpboost container for tWAS"
LABEL Author="Edoardo Giacopuzzi"
LABEL Contact="edoardo.giacopuzzi@fht.org"
# Match the version label to the container version tag
LABEL version="1.0"
LABEL help="snpboost.R is in /opt/snpboost" 

# Install some support library and the snpboost scripts
USER root
RUN apk add zlib-dev zstd-dev glibc gsl-dev zstd

USER rstudio-server