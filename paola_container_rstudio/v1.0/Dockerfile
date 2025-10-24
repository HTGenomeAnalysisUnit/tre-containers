FROM ghtrecontainers/ari_and_bea_rstudio_container:v1.0

LABEL Description="Multi-purpose R env for ATAC and GH analysis"
LABEL Author="Paola Benaglio"
LABEL Contact="paola.benaglio@fht.org"
LABEL version="v1.0" 

# Install additional support libraries
USER root
RUN apk add hdf5 hdf5-dev hdf5-tools libaec libaec-dev

USER rstudio-server

# Install R packages
WORKDIR /opt
COPY install.R /opt
COPY requirements.txt /opt
RUN Rscript /opt/install.R

ENTRYPOINT ["rserver"]
