FROM ghtrecontainers/rstudio-chainguard:latest

LABEL Description="snpboost container for tWAS"
LABEL Author="Edoardo Giacopuzzi"
LABEL Contact="edoardo.giacopuzzi@fht.org"
# Match the version label to the container version tag
LABEL version="1.1.3"
LABEL help="snpboost.R is in /opt/snpboost" 

# Install some support library and the snpboost scripts
USER root
RUN apk add zlib-dev zstd-dev glibc gsl-dev zstd

# Install plink2
WORKDIR /opt
RUN wget https://s3.amazonaws.com/plink2-assets/alpha6/plink2_linux_avx2_20241206.zip \
    && unzip -q plink2_linux_avx2_20241206.zip \
    && rm plink2_linux_avx2_20241206.zip \
    && chmod a+x plink2 \
    && mv plink2 /usr/bin/plink2

WORKDIR /opt/snpboost
COPY snpboost.R .

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