FROM ghtrecontainers/rstudio-chainguard:latest

LABEL Description="Rstudio with tidyverse, gridExtra and ggsci"
LABEL Author="Daniela Zanotti"
LABEL Contact="daniela.zanotti@fht.org"
LABEL Version="1.1.0"

# Install additional libs needed by R packages
USER root
RUN apk add pkgconf fontconfig-dev harfbuzz-dev fribidi-dev freetype-dev libpng-dev tiff-dev libjpeg-turbo-dev libwebp-dev

USER rstudio-server

# Install R packages using support script
WORKDIR /opt
COPY install.R /opt
COPY requirements.txt /opt
RUN Rscript /opt/install.R

ENTRYPOINT ["rserver"]
