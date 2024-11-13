FROM ghtrecontainers/rstudio-chainguard:latest

LABEL Description="Short env description"
LABEL Author="Andrei Cristea"
LABEL Contact="andrei.cristea@fht.org"
# Match the version label to the container version tag
LABEL version="0.1" 

# Install R packages
# Copy the install.R and requirements.txt files to the container
WORKDIR /opt
COPY install.R /opt
COPY requirements.txt /opt
RUN Rscript /opt/install.R

ENTRYPOINT ["rserver"]
