FROM ghtrecontainers/rstudio-chainguard:latest

LABEL Description="Rstudio with tidyverse, gridExtra and ggsci"
LABEL Author="Daniela Zanotti"
LABEL Contact="daniela.zanotti@fht.org"
LABEL Version="1.0"

# Install R packages
# Copy the install.R and requirements.txt files to the container
WORKDIR /opt
COPY install.R /opt
COPY requirements.txt /opt
RUN Rscript /opt/install.R

ENTRYPOINT ["rserver"]
