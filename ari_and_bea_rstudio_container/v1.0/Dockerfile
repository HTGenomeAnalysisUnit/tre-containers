FROM ghtrecontainers/rstudio-chainguard:latest

LABEL Description="Cardinal DEA and SAFELD"
LABEL Author="Arianna Landini"
LABEL Contact="arianna.landini@fht.org"
# Match the version label to the container version tag
LABEL version="v1.0" 

# Install R packages
# Copy the install.R and requirements.txt files to the container
WORKDIR /opt
COPY install.R /opt
COPY requirements.txt /opt
RUN Rscript /opt/install.R

ENTRYPOINT ["rserver"]
