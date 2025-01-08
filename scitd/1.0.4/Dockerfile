FROM ghtrecontainers/rstudio-chainguard:latest

LABEL Description="scITD container for multicellular programs"
LABEL Author="Edoardo Giacopuzzi"
LABEL Contact="edoardo.giacopuzzi@fht.org"
# Match the version label to the container version tag
LABEL version="1.0.4"

# Install some support library and the snpboost scripts
USER root
RUN apk add zlib-dev zstd-dev glibc gsl-dev zstd

USER rstudio-server

# Install R packages
# Copy the install.R and requirements.txt files to the container
WORKDIR /opt
COPY install.R /opt
COPY requirements.txt /opt
RUN Rscript /opt/install.R

# Ensure we are reading the packages from the container first
ENV R_LIBS="/usr/lib/R/library"

ENTRYPOINT ["rserver"]