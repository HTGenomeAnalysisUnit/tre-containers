FROM ghtrecontainers/rstudio-chainguard:latest

LABEL Description="snpboost container for tWAS"
LABEL Author="Edoardo Giacopuzzi"
LABEL Contact="edoardo.giacopuzzi@fht.org"
# Match the version label to the container version tag
LABEL version="1.0"
LABEL help="snpboost.R is in /opt/snpboost" 

# Install some support library and the snpboost scripts
USER root
RUN apk add zlib-dev zstd-dev glibc gsl-dev

WORKDIR /opt
COPY snpboost.tar.gz .
RUN tar -xvzf snpboost.tar.gz

USER rstudio-server

# Install R packages
# Copy the install.R and requirements.txt files to the container
WORKDIR /opt
COPY install.R /opt
COPY requirements.txt /opt
RUN Rscript /opt/install.R

ENTRYPOINT ["rserver"]