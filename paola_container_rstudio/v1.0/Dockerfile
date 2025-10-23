FROM ghtrecontainers/ari_and_bea_rstudio_container:v1.0

LABEL Description="Paola's multipurpose R env for ATAC and GH analysis"
LABEL Author="Paola Benaglio"
LABEL Contact="paola.benaglio@fht.org"
LABEL version="v1.0" 

USER root
RUN apk add hdf5-dev

USER rstudio-server

# Install R packages
# Copy the install.R and requirements.txt files to the container
WORKDIR /opt
COPY install.R /opt
COPY requirements.txt /opt
RUN Rscript /opt/install.R

ENTRYPOINT ["rserver"]
