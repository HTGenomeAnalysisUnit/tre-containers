FROM ghtrecontainers/rstudio-chainguard:latest

LABEL Description="Cardinal DEA and SAFELD"
LABEL Author="Arianna Landini"
LABEL Contact="arianna.landini@fht.org"
LABEL version="v1.0" 

# Install R packages
WORKDIR /opt
COPY install.R /opt
COPY requirements.txt /opt
RUN Rscript /opt/install.R

ENTRYPOINT ["rserver"]
