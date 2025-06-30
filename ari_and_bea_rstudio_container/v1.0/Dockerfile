FROM ghtrecontainers/rstudio-chainguard:latest

LABEL Description="CARDINAL DEA and SAFELD"
LABEL Author="Arianna Landini"
LABEL Contact="arianna.landini@fht.org"
LABEL version="v1.0" 

USER root
RUN apk add gsl-dev

USER rstudio-server

# Install R packages
WORKDIR /opt
COPY install.R /opt
COPY requirements.txt /opt
RUN Rscript /opt/install.R

# ratudio server entrypoint
ENTRYPOINT ["rserver"]
