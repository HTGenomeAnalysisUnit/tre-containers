FROM ghtrecontainers/rstudio-chainguard:latest

LABEL Description="snpboost container for tWAS"
LABEL Author="Edoardo Giacopuzzi"
LABEL Contact="edoardo.giacopuzzi@fht.org"
# Match the version label to the container version tag
LABEL version="0.1" 

# Install R packages
# Copy the install.R and requirements.txt files to the container
WORKDIR /opt
COPY install.R /opt
COPY requirements.txt /opt
RUN Rscript /opt/install.R

WORKDIR /opt
COPY snpboost.tar.gz .
RUN tar -xvzf snpboost.tar.gz

ENTRYPOINT ["rserver"]